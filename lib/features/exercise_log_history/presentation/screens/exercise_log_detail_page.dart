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
import 'package:pockeat/features/exercise_log_history/presentation/widgets/weight_lifting_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

/// Detail page for exercise logs with widget composition based on type
class ExerciseLogDetailPage extends StatefulWidget {
  final String exerciseId;
  final String activityType;
  final CardioRepository cardioRepository;
  final SmartExerciseLogRepository smartExerciseRepository;
  final WeightLiftingRepository weightLiftingRepository;

  const ExerciseLogDetailPage({
    super.key,
    required this.exerciseId,
    required this.activityType,
    required this.cardioRepository,
    required this.smartExerciseRepository,
    required this.weightLiftingRepository,
  });

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
      weightLiftingRepository: widget.weightLiftingRepository,
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
    if (widget.activityType == ExerciseLogHistoryItem.typeSmartExercise) {
      return _detailService.getSmartExerciseDetail(widget.exerciseId);
    } else if (widget.activityType == ExerciseLogHistoryItem.typeCardio) {
      return _loadCardioExerciseData();
    } else if (widget.activityType ==
        ExerciseLogHistoryItem.typeWeightlifting) {
      return _detailService.getWeightLiftingDetail(widget.exerciseId);
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
        title: Text(_getPageTitle()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Delete',
          ),
        ],
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
    if (widget.activityType == ExerciseLogHistoryItem.typeSmartExercise) {
      return 'Smart Exercise Details';
    } else if (widget.activityType == ExerciseLogHistoryItem.typeCardio) {
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
    } else if (widget.activityType ==
        ExerciseLogHistoryItem.typeWeightlifting) {
      return 'Weight Training Details';
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
    if (widget.activityType == ExerciseLogHistoryItem.typeSmartExercise) {
      return SmartExerciseDetailWidget(exercise: exercise);
    } else if (widget.activityType == ExerciseLogHistoryItem.typeCardio) {
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
    } else if (widget.activityType ==
        ExerciseLogHistoryItem.typeWeightlifting) {
      if (exercise is WeightLifting) {
        return WeightLiftingDetailWidget(weightLifting: exercise);
      } else {
        return const Center(child: Text('Invalid weight lifting data'));
      }
    } else {
      return const Center(
          child: Text(
        'Unsupported activity type',
        style: TextStyle(color: Colors.red),
      ));
    }
  }

  // Method untuk menampilkan dialog konfirmasi delete
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: const Text(
            'Are you sure you want to delete this exercise log? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteExercise(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Method untuk menghapus exercise log
  Future<void> _deleteExercise(BuildContext context) async {
    // Menampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Panggil service untuk menghapus exercise log
      final result = await _detailService.deleteExerciseLog(
        widget.exerciseId,
        widget.activityType,
      );

      // Menghilangkan loading indicator
      Navigator.of(context).pop();

      // Cek hasil delete
      if (result) {
        // Success case - kembali ke halaman sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise log deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true sebagai indikator sukses
      } else {
        // Failure case - tetap di halaman dan tampilkan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete exercise log'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Error case - tetap di halaman dan tampilkan error
      Navigator.of(context).pop(); // Menghilangkan loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting exercise log: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
