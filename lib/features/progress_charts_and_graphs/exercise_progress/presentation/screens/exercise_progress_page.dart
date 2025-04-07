import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/services/exercise_progress_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_overview_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/exercise_distribution_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/performance_metric_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_history_widget.dart';

// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';

// coverage:ignore-start
final logger = Logger();

class ExerciseProgressPage extends StatefulWidget {
  final ExerciseProgressService service;
  
  const ExerciseProgressPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<ExerciseProgressPage> createState() => _ExerciseProgressPageState();
}

class _ExerciseProgressPageState extends State<ExerciseProgressPage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  
  // Track the current view directly with a boolean instead of a Future
  bool isWeeklyView = true;
  bool isLoading = true;
  
  // Initialize with empty lists instead of late futures
  List<ExerciseData> _exerciseData = [];
  List<WorkoutStat> _workoutStats = [];
  List<ExerciseType> _exerciseTypes = [];
  List<PerformanceMetric> _performanceMetrics = [];
  List<WorkoutItem> _workoutHistory = [];
  String _completionPercentage = "0%";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // First load the view preference
      isWeeklyView = await widget.service.getSelectedViewPeriod();
      
      // Then load all data in parallel
      final results = await Future.wait([
        widget.service.getExerciseData(isWeeklyView),
        widget.service.getWorkoutStats(),
        widget.service.getExerciseTypes(),
        widget.service.getPerformanceMetrics(),
        widget.service.getWorkoutHistory(),
        widget.service.getCompletionPercentage(),
      ]);
      
      // Update state with all results
      setState(() {
        _exerciseData = results[0] as List<ExerciseData>;
        _workoutStats = results[1] as List<WorkoutStat>;
        _exerciseTypes = results[2] as List<ExerciseType>;
        _performanceMetrics = results[3] as List<PerformanceMetric>;
        _workoutHistory = results[4] as List<WorkoutItem>;
        _completionPercentage = results[5] as String;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      logger.e('Error loading exercise progress data: $e');
    }
  }

  void _toggleView(bool weekly) async {
    if (weekly == isWeeklyView) return;
    
    setState(() {
      isWeeklyView = weekly;
      // Only show loading indicator for exercise data that's changing
      _exerciseData = [];
    });
    
    try {
      // Only update the view preference and reload exercise data
      await widget.service.setSelectedViewPeriod(weekly);
      final newExerciseData = await widget.service.getExerciseData(weekly);
      
      setState(() {
        _exerciseData = newExerciseData;
      });
    } catch (e) {
      logger.e('Error toggling view: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              isWeeklyView: isWeeklyView,
              onToggleView: _toggleView,
              primaryGreen: primaryGreen,
            ),
            const SizedBox(height: 24),
            WorkoutOverviewWidget(
              exerciseData: _exerciseData,
              workoutStats: _workoutStats,
              completionPercentage: _completionPercentage,
              primaryGreen: primaryGreen,
              isWeeklyView: isWeeklyView, // Add this parameter
            ),
            const SizedBox(height: 24),
            ExerciseDistributionWidget(
              exerciseTypes: _exerciseTypes,
            ),
            const SizedBox(height: 24),
            PerformanceMetricsWidget(
              metrics: _performanceMetrics,
            ),
            const SizedBox(height: 24),
            WorkoutHistoryWidget(
              workoutHistory: _workoutHistory,
            ),
          ],
        ),
      ),
    );
  }
}
// coverage:ignore-end