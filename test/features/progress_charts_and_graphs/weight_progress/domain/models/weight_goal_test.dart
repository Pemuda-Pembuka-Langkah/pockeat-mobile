// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';

void main() {
  group('WeightGoal', () {
    test('should properly initialize all fields with normal values', () {
      // Arrange
      const String startingWeight = '75.5 kg';
      const String startingDate = 'Dec 1, 2024';
      const String targetWeight = '70.0 kg';
      const String targetDate = 'Mar 1, 2025';
      const String remainingWeight = '3.0 kg';
      const String daysLeft = '35 days left';
      const bool isOnTrack = true;
      const String insightMessage = 'You are on track to reach your goal!';

      // Act
      final weightGoal = WeightGoal(
        startingWeight: startingWeight,
        startingDate: startingDate,
        targetWeight: targetWeight,
        targetDate: targetDate,
        remainingWeight: remainingWeight,
        daysLeft: daysLeft,
        isOnTrack: isOnTrack,
        insightMessage: insightMessage,
      );

      // Assert
      expect(weightGoal.startingWeight, equals(startingWeight));
      expect(weightGoal.startingDate, equals(startingDate));
      expect(weightGoal.targetWeight, equals(targetWeight));
      expect(weightGoal.targetDate, equals(targetDate));
      expect(weightGoal.remainingWeight, equals(remainingWeight));
      expect(weightGoal.daysLeft, equals(daysLeft));
      expect(weightGoal.isOnTrack, equals(isOnTrack));
      expect(weightGoal.insightMessage, equals(insightMessage));
    });

    test('should properly initialize all fields with empty strings', () {
      // Arrange
      const String startingWeight = '';
      const String startingDate = '';
      const String targetWeight = '';
      const String targetDate = '';
      const String remainingWeight = '';
      const String daysLeft = '';
      const bool isOnTrack = false;
      const String insightMessage = '';

      // Act
      final weightGoal = WeightGoal(
        startingWeight: startingWeight,
        startingDate: startingDate,
        targetWeight: targetWeight,
        targetDate: targetDate,
        remainingWeight: remainingWeight,
        daysLeft: daysLeft,
        isOnTrack: isOnTrack,
        insightMessage: insightMessage,
      );

      // Assert
      expect(weightGoal.startingWeight, equals(startingWeight));
      expect(weightGoal.startingDate, equals(startingDate));
      expect(weightGoal.targetWeight, equals(targetWeight));
      expect(weightGoal.targetDate, equals(targetDate));
      expect(weightGoal.remainingWeight, equals(remainingWeight));
      expect(weightGoal.daysLeft, equals(daysLeft));
      expect(weightGoal.isOnTrack, equals(isOnTrack));
      expect(weightGoal.insightMessage, equals(insightMessage));
    });

    test('should properly initialize with special characters and long strings', () {
      // Arrange
      const String startingWeight = '75.5 kg (165.5 lbs)';
      const String startingDate = 'December 1st, 2024 - Monday';
      const String targetWeight = '70.0 kg ±0.5';
      const String targetDate = 'Mar-01-2025';
      const String remainingWeight = '~3.0 kg left!';
      const String daysLeft = '35 days & 2 hours left';
      const bool isOnTrack = true;
      const String insightMessage = 'You\'re doing great! Keep up the good work! 💪';

      // Act
      final weightGoal = WeightGoal(
        startingWeight: startingWeight,
        startingDate: startingDate,
        targetWeight: targetWeight,
        targetDate: targetDate,
        remainingWeight: remainingWeight,
        daysLeft: daysLeft,
        isOnTrack: isOnTrack,
        insightMessage: insightMessage,
      );

      // Assert
      expect(weightGoal.startingWeight, equals(startingWeight));
      expect(weightGoal.startingDate, equals(startingDate));
      expect(weightGoal.targetWeight, equals(targetWeight));
      expect(weightGoal.targetDate, equals(targetDate));
      expect(weightGoal.remainingWeight, equals(remainingWeight));
      expect(weightGoal.daysLeft, equals(daysLeft));
      expect(weightGoal.isOnTrack, equals(isOnTrack));
      expect(weightGoal.insightMessage, equals(insightMessage));
    });
  });
}
