import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';

void main() {
  group('WorkoutItem', () {
    test('should create a WorkoutItem instance with the provided values', () {
      // Arrange
      const String title = 'Morning Workout';
      const String type = 'Cardio';
      const String stats = '350 calories';
      const String time = '45 min';
      const int colorValue = 0xFF4ECDC4;

      // Act
      final workoutItem = WorkoutItem(
        title: title,
        type: type,
        stats: stats,
        time: time,
        colorValue: colorValue,
      );

      // Assert
      expect(workoutItem.title, equals(title));
      expect(workoutItem.type, equals(type));
      expect(workoutItem.stats, equals(stats));
      expect(workoutItem.time, equals(time));
      expect(workoutItem.colorValue, equals(colorValue));
    });

    test('should handle empty strings', () {
      // Arrange
      const String title = '';
      const String type = '';
      const String stats = '';
      const String time = '';
      const int colorValue = 0xFF4ECDC4;

      // Act
      final workoutItem = WorkoutItem(
        title: title,
        type: type,
        stats: stats,
        time: time,
        colorValue: colorValue,
      );

      // Assert
      expect(workoutItem.title, isEmpty);
      expect(workoutItem.type, isEmpty);
      expect(workoutItem.stats, isEmpty);
      expect(workoutItem.time, isEmpty);
      expect(workoutItem.colorValue, equals(colorValue));
    });

    test('should handle different color values', () {
      // Arrange
      const String title = 'Strength Training';
      const String type = 'Weightlifting';
      const String stats = '200 calories';
      const String time = '60 min';
      const int colorValue = 0xFFFF6B6B;

      // Act
      final workoutItem = WorkoutItem(
        title: title,
        type: type,
        stats: stats,
        time: time,
        colorValue: colorValue,
      );

      // Assert
      expect(workoutItem.colorValue, equals(colorValue));
    });
  });
}