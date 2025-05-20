// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/analysis_result_widget.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/workout_form_widget.dart';
import '../../../health_metrics/domain/models/health_metrics_model.dart';
import '../../../health_metrics/domain/service/health_metrics_service.dart';

class SmartExerciseLogPage extends StatefulWidget {
  final SmartExerciseLogRepository repository;
  final FirebaseAuth?
      auth; // Add optional auth parameter for dependency injection
  final HealthMetricsService healthMetricsService;

  const SmartExerciseLogPage({
    super.key,
    required this.repository,
    this.auth,
    required this.healthMetricsService,
  });

  @override
  State<SmartExerciseLogPage> createState() => _SmartExerciseLogPageState();
}

class _SmartExerciseLogPageState extends State<SmartExerciseLogPage> {
  late final HealthMetricsService _healthMetricsService;
  HealthMetricsModel? _healthMetrics;
  bool _isLoadingHealthMetrics = true;
  // Theme colors - matching homepage style
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPurple = const Color(0xFF9B6BFF);
  final Color primaryPink = const Color(0xFFFF6B6B);

  // State variables
  bool isAnalyzing = false;
  bool isCorrectingAnalysis = false;
  ExerciseAnalysisResult? analysisResult;

  final ExerciseAnalysisService _exerciseAnalysisService =
      getIt<ExerciseAnalysisService>();
  late final SmartExerciseLogRepository _repository;
  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository;
    _auth = widget.auth ?? FirebaseAuth.instance;
    _healthMetricsService = widget.healthMetricsService;
    _loadHealthMetrics();
  }

  Future<void> _loadHealthMetrics() async {
    try {
      setState(() => _isLoadingHealthMetrics = true);
      _healthMetrics = await _healthMetricsService.getUserHealthMetrics();
    } catch (e) {
      debugPrint('Error loading health metrics: $e');
      _healthMetrics = _getDefaultHealthMetrics();
    } finally {
      setState(() => _isLoadingHealthMetrics = false);
    }
  }

  HealthMetricsModel _getDefaultHealthMetrics() {
    return HealthMetricsModel(
      userId: _getCurrentUserId(),
      height: 175.0,
      weight: 70.0,
      age: 30,
      gender: 'Male',
      activityLevel: 'moderate',
      fitnessGoal: 'maintain',
      bmi: 22.9,
      bmiCategory: 'Normal weight',
      desiredWeight: 70.0,
    );
  }

  // Get current user ID with a helper method
  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      // Handle the case where user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('User not logged in. Please log in to save exercise logs.'),
          backgroundColor: Colors.red,
        ),
      );
      return ''; // Return empty string if user is not logged in
    }
    return user.uid;
  }

  Future<void> analyzeWorkout(String workoutDescription) async {
    setState(() => isAnalyzing = true);

    try {
      // Pass all health metrics to API
      final result = await _exerciseAnalysisService.analyze(
        workoutDescription,
        userId: _getCurrentUserId(),
        userWeightKg: _healthMetrics?.weight,
        userHeightCm: _healthMetrics?.height,
        userAge: _healthMetrics?.age,
        userGender: _healthMetrics?.gender.toLowerCase(),
      );

      // Get user ID
      final String userId = _getCurrentUserId();

      // Create result with user ID
      final resultWithUserId =
          result.userId.isEmpty ? result.copyWith(userId: userId) : result;

      setState(() {
        analysisResult = resultWithUserId;
        isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze workout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> correctAnalysis(String userComment) async {
    if (analysisResult == null) return;

    setState(() => isCorrectingAnalysis = true);

    try {
      // Embed original input within user comment
      final fullComment =
          "Original: ${analysisResult!.originalInput}. Koreksi: $userComment";

      // Call API with combined comment
      final correctedResult = await _exerciseAnalysisService.correctAnalysis(
        analysisResult!,
        fullComment,
        userWeightKg: _healthMetrics?.weight,
        userHeightCm: _healthMetrics?.height,
        userAge: _healthMetrics?.age,
        userGender: _healthMetrics?.gender.toLowerCase(),
      );

      // Rest of the method remains the same
      final finalCorrectedResult = correctedResult.userId.isEmpty
          ? correctedResult.copyWith(userId: _getCurrentUserId())
          : correctedResult;

      setState(() {
        analysisResult = finalCorrectedResult;
        isCorrectingAnalysis = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis corrected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error handling remains the same
      setState(() {
        isCorrectingAnalysis = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to correct analysis: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void resetAnalysis() {
    setState(() {
      analysisResult = null;
    });
  }

  Future<void> saveExerciseLog() async {
    if (analysisResult == null || !analysisResult!.isComplete) return;

    try {
      // Get current user ID
      final userId = _getCurrentUserId();

      // Validate that user is logged in
      if (userId.isEmpty) {
        // Error message already shown in _getCurrentUserId
        return;
      }

      // Ensure the analysis result has the user ID before saving
      final resultToSave = analysisResult!.userId.isEmpty
          ? analysisResult!.copyWith(userId: userId)
          : analysisResult!;

      await _repository.saveAnalysisResult(resultToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout log saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pushNamed(
          '/analytic',
          arguments: {
            'initialTabIndex': 1,
            'initialSubTabIndex': 1,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save log: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Exercise Log',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Workout Form - using your WorkoutFormWidget component
            if (analysisResult == null)
              WorkoutFormWidget(
                onAnalyzePressed: analyzeWorkout,
                isLoading: isAnalyzing,
              ),

            // Analysis Result - using your AnalysisResultWidget component
            if (analysisResult != null && !isAnalyzing) ...[
              const SizedBox(height: 24),
              if (isCorrectingAnalysis)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Correcting analysis...'),
                    ],
                  ),
                )
              else
                AnalysisResultWidget(
                  analysisResult: analysisResult!,
                  onRetry: resetAnalysis,
                  onSave: saveExerciseLog,
                  onCorrect: (comment) => correctAnalysis(comment),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
