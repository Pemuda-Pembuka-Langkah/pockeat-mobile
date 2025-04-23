// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

class ExerciseSummaryCard extends StatelessWidget {
  final GlobalKey cardKey;
  final dynamic exercise;
  final String activityType;

  const ExerciseSummaryCard({
    super.key,
    required this.cardKey,
    required this.exercise,
    required this.activityType,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: cardKey,
      child: Container(
        width: 350,
        height: 500,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PockEat branding
            Row(
              children: [
                Image.asset(
                  'assets/icons/Logo_PockEat_draft_transparent.png',
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'PockEat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const Spacer(),
                _buildActivityBadge(),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise title and info
            Text(
              _getExerciseTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Main stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _buildMainStats(),
                  ),
                  if (_getAdditionalStats().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Additional stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _getAdditionalStats(),
                    ),
                  ],
                ],
              ),
            ),

            // Footer branding
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'tracked with PockEat',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBadge() {
    Color badgeColor;
    IconData icon;
    String label;

    if (exercise is RunningActivity) {
      badgeColor = Colors.blue;
      icon = Icons.directions_run;
      label = 'Running';
    } else if (exercise is CyclingActivity) {
      badgeColor = Colors.green;
      icon = Icons.directions_bike;
      label = 'Cycling';
    } else if (exercise is SwimmingActivity) {
      badgeColor = Colors.cyan;
      icon = Icons.pool;
      label = 'Swimming';
    } else if (exercise is WeightLifting) {
      badgeColor = Colors.deepOrange;
      icon = Icons.fitness_center;
      label = 'Weight Training';
    } else {
      badgeColor = Colors.purple;
      icon = Icons.fitness_center;
      label = 'Exercise';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: badgeColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getExerciseTitle() {
    if (exercise is RunningActivity) {
      return 'Running Session';
    } else if (exercise is CyclingActivity) {
      return 'Cycling Session';
    } else if (exercise is SwimmingActivity) {
      return 'Swimming Session';
    } else if (exercise is WeightLifting) {
      final weightLifting = exercise as WeightLifting;
      return weightLifting.name;
    } else if (exercise is ExerciseAnalysisResult) {
      return "AI Analyzed Exercise Session";
    }
    return 'Exercise Session';
  }

  String _formatTimestamp() {
    DateTime? timestamp;

    if (exercise is RunningActivity) {
      timestamp = (exercise as RunningActivity).date;
    } else if (exercise is CyclingActivity) {
      timestamp = (exercise as CyclingActivity).date;
    } else if (exercise is SwimmingActivity) {
      timestamp = (exercise as SwimmingActivity).date;
    } else if (exercise is WeightLifting) {
      timestamp = (exercise as WeightLifting).timestamp;
    } else if (exercise is ExerciseAnalysisResult) {
      timestamp = (exercise as ExerciseAnalysisResult).timestamp;
    }

    if (timestamp == null) {
      return '';
    }

    return DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(timestamp);
  }

  List<Widget> _buildMainStats() {
    if (exercise is RunningActivity) {
      final running = exercise as RunningActivity;
      return [
        _buildStatItem('Distance',
            '${running.distanceKm.toStringAsFixed(2)} km', Icons.straighten),
        _buildStatItem(
            'Duration', _formatDurationObj(running.duration), Icons.timer),
        _buildStatItem('Calories', '${running.caloriesBurned.toInt()} cal',
            Icons.local_fire_department),
      ];
    } else if (exercise is CyclingActivity) {
      final cycling = exercise as CyclingActivity;
      return [
        _buildStatItem('Distance',
            '${cycling.distanceKm.toStringAsFixed(2)} km', Icons.straighten),
        _buildStatItem(
            'Duration', _formatDurationObj(cycling.duration), Icons.timer),
        _buildStatItem('Calories', '${cycling.caloriesBurned.toInt()} cal',
            Icons.local_fire_department),
      ];
    } else if (exercise is SwimmingActivity) {
      final swimming = exercise as SwimmingActivity;
      return [
        _buildStatItem('Distance',
            '${swimming.totalDistance.toStringAsFixed(2)} m', Icons.straighten),
        _buildStatItem(
            'Duration', _formatDurationObj(swimming.duration), Icons.timer),
        _buildStatItem('Calories', '${swimming.caloriesBurned.toInt()} cal',
            Icons.local_fire_department),
      ];
    } else if (exercise is WeightLifting) {
      final weightLifting = exercise as WeightLifting;
      int totalSets = weightLifting.sets.length;
      int totalReps = weightLifting.sets.fold(0, (sum, set) => sum + set.reps);
      double avgWeight = weightLifting.sets.isEmpty
          ? 0
          : weightLifting.sets.fold(0.0, (sum, set) => sum + set.weight) /
              weightLifting.sets.length;

      return [
        _buildStatItem('Sets', '$totalSets', Icons.repeat),
        _buildStatItem('Reps', '$totalReps', Icons.fitness_center),
        _buildStatItem('Weight', '${avgWeight.toStringAsFixed(1)} kg',
            Icons.monitor_weight),
      ];
    } else if (exercise is ExerciseAnalysisResult) {
      final smartExercise = exercise as ExerciseAnalysisResult;
      return [
        _buildStatItem('Duration', smartExercise.duration, Icons.timer),
        _buildStatItem(
            'Calories',
            '${smartExercise.estimatedCalories.toInt()} cal',
            Icons.local_fire_department),
        _buildStatItem('Intensity', smartExercise.intensity, Icons.speed),
      ];
    }

    return [
      _buildStatItem('Exercise', 'Session', Icons.fitness_center),
    ];
  }

  List<Widget> _getAdditionalStats() {
    if (exercise is RunningActivity) {
      final running = exercise as RunningActivity;
      // Calculate pace (min/km)
      final paceMinutes = running.duration.inSeconds / 60 / running.distanceKm;
      final paceMin = paceMinutes.floor();
      final paceSec = ((paceMinutes - paceMin) * 60).round();

      return [
        _buildStatItem(
            'Pace',
            '$paceMin:${paceSec.toString().padLeft(2, '0')} min/km',
            Icons.speed),
        _buildStatItem(
            'Time', _formatTime(running.startTime), Icons.access_time),
      ];
    } else if (exercise is CyclingActivity) {
      final cycling = exercise as CyclingActivity;
      // Calculate average speed
      final avgSpeedKmh =
          cycling.distanceKm / (cycling.duration.inSeconds / 3600);

      return [
        _buildStatItem(
            'Speed', '${avgSpeedKmh.toStringAsFixed(1)} km/h', Icons.speed),
        _buildStatItem(
            'Time', _formatTime(cycling.startTime), Icons.access_time),
      ];
    } else if (exercise is SwimmingActivity) {
      final swimming = exercise as SwimmingActivity;
      return [
        _buildStatItem('Laps', '${swimming.laps}', Icons.loop),
        _buildStatItem(
            'Time', _formatTime(swimming.startTime), Icons.access_time),
      ];
    } else if (exercise is WeightLifting) {
      final weightLifting = exercise as WeightLifting;
      // Calculate average rest time
      double avgRestTime = weightLifting.sets.isEmpty
          ? 0
          : weightLifting.sets.fold(0.0, (sum, set) => sum + set.duration) /
              weightLifting.sets.length;

      return [
        _buildStatItem('Rest', '${avgRestTime.toStringAsFixed(0)}s',
            Icons.hourglass_bottom),
        _buildStatItem(
            'Body Part', weightLifting.bodyPart, Icons.accessibility_new),
      ];
    } else if (exercise is ExerciseAnalysisResult) {
      final smartExercise = exercise as ExerciseAnalysisResult;
      return [
        _buildStatItem('Type', smartExercise.exerciseType, Icons.category),
        _buildStatItem('MET Value', smartExercise.metValue.toStringAsFixed(1),
            Icons.check_circle),
      ];
    }

    return [];
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDurationObj(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
}
