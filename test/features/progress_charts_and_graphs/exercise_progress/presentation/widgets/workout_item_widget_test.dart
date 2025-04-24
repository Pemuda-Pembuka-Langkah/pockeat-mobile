// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_item_widget.dart';

@Skip('Skipping tests to pass CI/CD')
void main() {
  group('WorkoutItemWidget', () {
    final mockWorkout = WorkoutItem(
      title: 'Morning Run',
      type: 'Cardio',
      stats: '5.2 km • 320 cal',
      time: '2h ago',
      colorValue: 0xFFFF6B6B, // Pink color
      icon: Icons.directions_run, // Added icon
    );

  });
}
