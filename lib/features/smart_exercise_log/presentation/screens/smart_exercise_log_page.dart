import 'package:flutter/material.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/analysis_result_widget.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/workout_form_widget.dart';

class SmartExerciseLogPage extends StatefulWidget {
  // Required dependencies for full DI
  final GeminiService geminiService;
  final SmartExerciseLogRepository repository;

  const SmartExerciseLogPage({
    super.key, 
    required this.geminiService,
    required this.repository,
  });

  @override
  State<SmartExerciseLogPage> createState() => _SmartExerciseLogPageState();
}

class _SmartExerciseLogPageState extends State<SmartExerciseLogPage> {
  // Consistent theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPurple = const Color(0xFF9B6BFF);
  
  // State variables
  bool isAnalyzing = false;
  bool isCorrectingAnalysis = false;
  ExerciseAnalysisResult? analysisResult;
  
  // Dependencies
  late final GeminiService _geminiService;
  late final SmartExerciseLogRepository _repository;
  
  @override
  void initState() {
    super.initState();
    // Use injected dependencies
    _geminiService = widget.geminiService;
    _repository = widget.repository;
  }
  
  Future<void> analyzeWorkout(String workoutDescription) async {
    setState(() => isAnalyzing = true);
    
    try {
      // Use Gemini service for AI analysis
      final result = await _geminiService.analyzeExercise(workoutDescription);
      
      setState(() {
        analysisResult = result;
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
      // Use GeminiService for correcting analysis
      final correctedResult = await _geminiService.correctExerciseAnalysis(
        analysisResult!,
        userComment,
      );
      
      setState(() {
        analysisResult = correctedResult;
        isCorrectingAnalysis = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Analysis corrected successfully!'),
            backgroundColor: primaryPurple,
          ),
        );
      }
    } catch (e) {
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
      await _repository.saveAnalysisResult(analysisResult!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Workout log saved successfully!'),
            backgroundColor: primaryPurple,
          ),
        );
        
        // Navigate back
        Navigator.pop(context);
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
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Workout Log',
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