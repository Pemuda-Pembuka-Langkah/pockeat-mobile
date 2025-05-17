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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header image
              _buildExerciseHeader(),

              // Content padding
              Padding(
                padding: const EdgeInsets.all(16),
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatTimestamp(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Exercise stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Main stats row
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _buildMainStats(),
                            ),
                          ),
                          if (_getAdditionalStats().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            // Additional stats
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: _getAdditionalStats(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Exercise intensity visualization
                    if (_shouldShowIntensityBar()) _buildIntensityBar(),

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
            ],
          ),
        ),
      ),
    );
  }

  // New method to display exercise header image
  Widget _buildExerciseHeader() {
    return Container(
      height: 160,
      child: Container(
        decoration: BoxDecoration(
          gradient: _getExerciseGradient(),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Exercise type illustration
            Center(
              child: Icon(
                _getExerciseIcon(),
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),

            // Stats overlay
            Positioned(
              bottom: 12,
              left: 12,
              child: _buildHeaderStats(),
            ),
          ],
        ),
      ),
    );
  }

  // Get gradient colors based on exercise type
  LinearGradient _getExerciseGradient() {
    if (exercise is RunningActivity) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
      );
    } else if (exercise is CyclingActivity) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
      );
    } else if (exercise is SwimmingActivity) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
      );
    } else if (exercise is WeightLifting) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      );
    }
  }

  // Get icon based on exercise type
  IconData _getExerciseIcon() {
    if (exercise is RunningActivity) {
      return Icons.directions_run;
    } else if (exercise is CyclingActivity) {
      return Icons.directions_bike;
    } else if (exercise is SwimmingActivity) {
      return Icons.pool;
    } else if (exercise is WeightLifting) {
      return Icons.fitness_center;
    } else {
      return Icons.fitness_center;
    }
  }

  // Build header stats overlay
  Widget _buildHeaderStats() {
    String mainStat = '';
    String mainStatLabel = '';

    if (exercise is RunningActivity) {
      final running = exercise as RunningActivity;
      mainStat = '${running.distanceKm.toStringAsFixed(2)} km';
      mainStatLabel = 'Distance';
    } else if (exercise is CyclingActivity) {
      final cycling = exercise as CyclingActivity;
      mainStat = '${cycling.distanceKm.toStringAsFixed(2)} km';
      mainStatLabel = 'Distance';
    } else if (exercise is SwimmingActivity) {
      final swimming = exercise as SwimmingActivity;
      mainStat = '${swimming.laps}';
      mainStatLabel = 'Laps';
    } else if (exercise is WeightLifting) {
      final weightLifting = exercise as WeightLifting;
      int totalSets = weightLifting.sets.length;
      mainStat = '$totalSets';
      mainStatLabel = 'Sets';
    } else if (exercise is ExerciseAnalysisResult) {
      final smartExercise = exercise as ExerciseAnalysisResult;
      mainStat = '${smartExercise.estimatedCalories.toInt()}';
      mainStatLabel = 'Calories';
    }

    if (mainStat.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            mainStat,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            mainStatLabel,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
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
        border: Border.all(color: badgeColor.withOpacity(0.3)),
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
    return Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColorForIcon(icon).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getColorForIcon(icon).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: _getColorForIcon(icon),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // Get color for icon based on icon type
  Color _getColorForIcon(IconData icon) {
    if (icon == Icons.straighten) {
      return Colors.blue;
    } else if (icon == Icons.timer || icon == Icons.access_time) {
      return Colors.purple;
    } else if (icon == Icons.local_fire_department) {
      return Colors.orange;
    } else if (icon == Icons.speed) {
      return Colors.red;
    } else if (icon == Icons.monitor_weight || icon == Icons.fitness_center) {
      return Colors.deepOrange;
    } else if (icon == Icons.repeat) {
      return Colors.green;
    } else if (icon == Icons.loop) {
      return Colors.cyan;
    } else if (icon == Icons.hourglass_bottom) {
      return Colors.amber;
    } else if (icon == Icons.accessibility_new) {
      return Colors.teal;
    } else if (icon == Icons.category) {
      return Colors.indigo;
    } else if (icon == Icons.check_circle) {
      return Colors.green;
    }
    return Colors.grey;
  }

  // Check if we should show intensity bar
  bool _shouldShowIntensityBar() {
    if (exercise is ExerciseAnalysisResult) {
      return true;
    } else if (exercise is RunningActivity) {
      return true;
    } else if (exercise is CyclingActivity) {
      return true;
    }
    return false;
  }

  // Build intensity visualization bar
  Widget _buildIntensityBar() {
    String intensityText = "Moderate";
    double intensityValue = 0.5;
    Color intensityColor = Colors.amber;

    if (exercise is ExerciseAnalysisResult) {
      final smartExercise = exercise as ExerciseAnalysisResult;
      intensityText = smartExercise.intensity;

      // Convert intensity text to value
      switch (intensityText.toLowerCase()) {
        case 'light':
          intensityValue = 0.3;
          intensityColor = Colors.green;
          break;
        case 'moderate':
          intensityValue = 0.5;
          intensityColor = Colors.amber;
          break;
        case 'vigorous':
        case 'high':
          intensityValue = 0.8;
          intensityColor = Colors.orange;
          break;
        case 'intense':
        case 'very high':
          intensityValue = 1.0;
          intensityColor = Colors.red;
          break;
      }
    } else if (exercise is RunningActivity) {
      final running = exercise as RunningActivity;
      // Calculate intensity based on pace
      final pace = running.duration.inSeconds / running.distanceKm;
      if (pace < 240) {
        // Under 4 min/km - intense
        intensityValue = 0.9;
        intensityText = "Intense";
        intensityColor = Colors.red;
      } else if (pace < 300) {
        // 4-5 min/km - vigorous
        intensityValue = 0.7;
        intensityText = "Vigorous";
        intensityColor = Colors.orange;
      } else if (pace < 360) {
        // 5-6 min/km - moderate
        intensityValue = 0.5;
        intensityText = "Moderate";
        intensityColor = Colors.amber;
      } else {
        // Over 6 min/km - light
        intensityValue = 0.3;
        intensityText = "Light";
        intensityColor = Colors.green;
      }
    } else if (exercise is CyclingActivity) {
      final cycling = exercise as CyclingActivity;
      // Calculate intensity based on speed
      final speed = cycling.distanceKm / (cycling.duration.inSeconds / 3600);
      if (speed > 30) {
        // Over 30 km/h - intense
        intensityValue = 0.9;
        intensityText = "Intense";
        intensityColor = Colors.red;
      } else if (speed > 25) {
        // 25-30 km/h - vigorous
        intensityValue = 0.7;
        intensityText = "Vigorous";
        intensityColor = Colors.orange;
      } else if (speed > 18) {
        // 18-25 km/h - moderate
        intensityValue = 0.5;
        intensityText = "Moderate";
        intensityColor = Colors.amber;
      } else {
        // Under 18 km/h - light
        intensityValue = 0.3;
        intensityText = "Light";
        intensityColor = Colors.green;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(
              Icons.speed,
              size: 16,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              'Intensity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: intensityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: intensityColor.withOpacity(0.3)),
              ),
              child: Text(
                intensityText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: intensityColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Flexible(
                flex: (intensityValue * 100).toInt(),
                child: Container(
                  decoration: BoxDecoration(
                    color: intensityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Flexible(
                flex: 100 - (intensityValue * 100).toInt(),
                child: Container(),
              ),
            ],
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
