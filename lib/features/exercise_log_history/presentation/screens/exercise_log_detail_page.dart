import 'package:flutter/material.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/cycling_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/running_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/smart_exercise_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/swimming_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';

/// Detail page for exercise logs with widget composition based on type
class ExerciseLogDetailPage extends StatefulWidget {
  final String exerciseId;
  final String activityType;
  final CardioRepository cardioRepository;
  final SmartExerciseLogRepository smartExerciseRepository;

  const ExerciseLogDetailPage({
    Key? key,
    required this.exerciseId,
    required this.activityType,
    required this.cardioRepository,
    required this.smartExerciseRepository,
  }) : super(key: key);

  @override
  State<ExerciseLogDetailPage> createState() => _ExerciseLogDetailPageState();
}

class _ExerciseLogDetailPageState extends State<ExerciseLogDetailPage> {
  late ExerciseDetailService _detailService;
  late Future<dynamic> _exerciseFuture;
  String? _cardioType;

  @override
  void initState() {
    super.initState();
    _detailService = ExerciseDetailServiceImpl(
      cardioRepository: widget.cardioRepository,
      smartExerciseRepository: widget.smartExerciseRepository,
    );
    // Initialize with a Future that includes all loading processes
    _exerciseFuture = _loadExerciseData();
  }

  // Function to load all exercise data and return a Future
  Future<dynamic> _loadExerciseData() async {
    // Step 1: Get the actual activity type first
    _cardioType = await _detailService.getActualActivityType(
        widget.exerciseId, widget.activityType);

    // Step 2: Load data based on the activity type
    if (widget.activityType == ExerciseLogHistoryItem.TYPE_SMART_EXERCISE) {
      return _detailService.getSmartExerciseDetail(widget.exerciseId);
    } else if (widget.activityType == ExerciseLogHistoryItem.TYPE_CARDIO) {
      return _loadCardioExerciseData();
    } else {
      return null;
    }
  }

  // Function to load cardio exercise data based on its type
  Future<dynamic> _loadCardioExerciseData() async {
    switch (_cardioType) {
      case 'running':
        return _detailService
            .getCardioActivityDetail<RunningActivity>(widget.exerciseId);
      case 'cycling':
        return _detailService
            .getCardioActivityDetail<CyclingActivity>(widget.exerciseId);
      case 'swimming':
        return _detailService
            .getCardioActivityDetail<SwimmingActivity>(widget.exerciseId);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Details'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: FutureBuilder<dynamic>(
          future: _exerciseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: const Color(0xFFFF6B6B),
                        size: 64.0,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Error loading data',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      color: Colors.grey,
                      size: 64.0,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'An error occurred while loading exercise data',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              );
            }

            return _buildDetailWidget(snapshot.data);
          },
        ),
      ),
    );
  }

  String _getPageTitle() {
    if (widget.activityType == ExerciseLogHistoryItem.TYPE_SMART_EXERCISE) {
      return 'Smart Exercise Details';
    } else if (widget.activityType == ExerciseLogHistoryItem.TYPE_CARDIO) {
      switch (_cardioType) {
        case 'running':
          return 'Running Details';
        case 'cycling':
          return 'Cycling Details';
        case 'swimming':
          return 'Swimming Details';
        default:
          return 'Cardio Details';
      }
    } else {
      return 'Exercise Details';
    }
  }

  Widget _buildDetailWidget(dynamic exercise) {
    if (exercise == null) {
      return const Center(
          child: Text(
        'Data not found',
        style: TextStyle(color: Colors.red),
      ));
    }

    // Determine the correct widget based on the exercise type
    if (widget.activityType == ExerciseLogHistoryItem.TYPE_SMART_EXERCISE) {
      return SmartExerciseDetailWidget(exercise: exercise);
    } else if (widget.activityType == ExerciseLogHistoryItem.TYPE_CARDIO) {
      if (exercise is RunningActivity) {
        return RunningDetailWidget(activity: exercise);
      } else if (exercise is CyclingActivity) {
        return CyclingDetailWidget(activity: exercise);
      } else if (exercise is SwimmingActivity) {
        return SwimmingDetailWidget(activity: exercise);
      } else {
        // If the type is not recognized but still cardio, display a generic message
        return const Center(child: Text('Unsupported cardio type'));
      }
    } else {
      return const Center(
          child: Text(
        'Unsupported activity type',
        style: TextStyle(color: Colors.red),
      ));
    }
  }
}
