// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';

void main() {
  group('WorkoutStat', () {
    test('should create a WorkoutStat instance with the provided values', () {
      // Arrange
      const String label = 'Duration';
      const String value = '45 min';
      const int colorValue = 0xFF4ECDC4;

      // Act
      final workoutStat = WorkoutStat(
        label: label,
        value: value,
        colorValue: colorValue,
      );

      // Assert
      expect(workoutStat.label, equals(label));
      expect(workoutStat.value, equals(value));
      expect(workoutStat.colorValue, equals(colorValue));
    });

    test('should handle calories with kcal suffix', () {
      // Arrange
      const String label = 'Calories';
      const String value = '320 kcal';
      const int colorValue = 0xFFFF6B6B;

      // Act
      final workoutStat = WorkoutStat(
        label: label,
        value: value,
        colorValue: colorValue,
      );

      // Assert
      expect(workoutStat.label, equals(label));
      expect(workoutStat.value, equals(value));
      expect(workoutStat.value, contains('kcal'));
      expect(workoutStat.colorValue, equals(colorValue));
    });

    test('should handle empty strings', () {
      // Arrange
      const String label = '';
      const String value = '';
      const int colorValue = 0xFFFF6B6B;

      // Act
      final workoutStat = WorkoutStat(
        label: label,
        value: value,
        colorValue: colorValue,
      );

      // Assert
      expect(workoutStat.label, isEmpty);
      expect(workoutStat.value, isEmpty);
      expect(workoutStat.colorValue, equals(colorValue));
    });

    test('should handle different color values', () {
      // Arrange
      const String label = 'Calories';
      const String value = '320 kcal';
      const int colorValue = 0xFFFFB946;  // Yellow

      // Act
      final workoutStat = WorkoutStat(
        label: label,
        value: value,
        colorValue: colorValue,
      );

      // Assert
      expect(workoutStat.colorValue, equals(colorValue));
    });
  });
}
