// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';

void main() {
  group('WeeklyAnalysis', () {
    test('should create an instance with the given values', () {
      // Arrange
      const String testWeightChange = '-1.5 kg';
      const String testCaloriesBurned = '2,500 kcal';
      const String testProgressRate = 'Good';
      const double testWeeklyGoalPercentage = 0.75;
      
      // Act
      final weeklyAnalysis = WeeklyAnalysis(
        weightChange: testWeightChange,
        caloriesBurned: testCaloriesBurned,
        progressRate: testProgressRate,
        weeklyGoalPercentage: testWeeklyGoalPercentage,
      );
      
      // Assert
      expect(weeklyAnalysis, isNotNull);
      expect(weeklyAnalysis, isA<WeeklyAnalysis>());
      expect(weeklyAnalysis.weightChange, equals(testWeightChange));
      expect(weeklyAnalysis.caloriesBurned, equals(testCaloriesBurned));
      expect(weeklyAnalysis.progressRate, equals(testProgressRate));
      expect(weeklyAnalysis.weeklyGoalPercentage, equals(testWeeklyGoalPercentage));
    });

    test('should handle empty strings for text fields', () {
      // Arrange
      const String emptyString = '';
      const double testWeeklyGoalPercentage = 0.5;
      
      // Act
      final weeklyAnalysis = WeeklyAnalysis(
        weightChange: emptyString,
        caloriesBurned: emptyString,
        progressRate: emptyString,
        weeklyGoalPercentage: testWeeklyGoalPercentage,
      );
      
      // Assert
      expect(weeklyAnalysis.weightChange, equals(emptyString));
      expect(weeklyAnalysis.caloriesBurned, equals(emptyString));
      expect(weeklyAnalysis.progressRate, equals(emptyString));
      expect(weeklyAnalysis.weeklyGoalPercentage, equals(testWeeklyGoalPercentage));
    });
    
    test('should handle zero weekly goal percentage', () {
      // Arrange
      const String testWeightChange = 'No change';
      const String testCaloriesBurned = '0 kcal';
      const String testProgressRate = 'None';
      const double testWeeklyGoalPercentage = 0.0;
      
      // Act
      final weeklyAnalysis = WeeklyAnalysis(
        weightChange: testWeightChange,
        caloriesBurned: testCaloriesBurned,
        progressRate: testProgressRate,
        weeklyGoalPercentage: testWeeklyGoalPercentage,
      );
      
      // Assert
      expect(weeklyAnalysis.weeklyGoalPercentage, equals(0.0));
    });
    
    test('should handle 100% weekly goal percentage', () {
      // Arrange
      const String testWeightChange = '-2.0 kg';
      const String testCaloriesBurned = '3,000 kcal';
      const String testProgressRate = 'Excellent';
      const double testWeeklyGoalPercentage = 1.0;
      
      // Act
      final weeklyAnalysis = WeeklyAnalysis(
        weightChange: testWeightChange,
        caloriesBurned: testCaloriesBurned,
        progressRate: testProgressRate,
        weeklyGoalPercentage: testWeeklyGoalPercentage,
      );
      
      // Assert
      expect(weeklyAnalysis.weeklyGoalPercentage, equals(1.0));
    });
    
    test('should handle negative weekly goal percentage', () {
      // Arrange - Even though negative percentage doesn't make logical sense, 
      // the model should accept it to avoid runtime errors
      const String testWeightChange = '+0.5 kg';
      const String testCaloriesBurned = '1,000 kcal';
      const String testProgressRate = 'Poor';
      const double testWeeklyGoalPercentage = -0.25;
      
      // Act
      final weeklyAnalysis = WeeklyAnalysis(
        weightChange: testWeightChange,
        caloriesBurned: testCaloriesBurned,
        progressRate: testProgressRate,
        weeklyGoalPercentage: testWeeklyGoalPercentage,
      );
      
      // Assert
      expect(weeklyAnalysis.weeklyGoalPercentage, equals(-0.25));
    });
    
    test('should handle weekly goal percentage greater than 1.0', () {
      // Arrange - Although percentage should typically be between 0 and 1,
      // the model should handle values beyond this range
      const String testWeightChange = '-3.0 kg';
      const String testCaloriesBurned = '4,500 kcal';
      const String testProgressRate = 'Outstanding';
      const double testWeeklyGoalPercentage = 1.25;
      
      // Act
      final weeklyAnalysis = WeeklyAnalysis(
        weightChange: testWeightChange,
        caloriesBurned: testCaloriesBurned,
        progressRate: testProgressRate,
        weeklyGoalPercentage: testWeeklyGoalPercentage,
      );
      
      // Assert
      expect(weeklyAnalysis.weeklyGoalPercentage, equals(1.25));
    });
    
    test('should handle long strings for text fields', () {
      // Arrange
      const String longWeightChange = 'Lost a significant amount of weight (-5.5 kg) over the past week';
      const String longCaloriesBurned = 'Burned approximately 7,850 calories through intense daily workouts';
      const String longProgressRate = 'Making extremely good progress toward weight loss goals with consistent effort';
      const double testWeeklyGoalPercentage = 0.85;
      
      // Act
      final weeklyAnalysis = WeeklyAnalysis(
        weightChange: longWeightChange,
        caloriesBurned: longCaloriesBurned,
        progressRate: longProgressRate,
        weeklyGoalPercentage: testWeeklyGoalPercentage,
      );
      
      // Assert
      expect(weeklyAnalysis.weightChange, equals(longWeightChange));
      expect(weeklyAnalysis.caloriesBurned, equals(longCaloriesBurned));
      expect(weeklyAnalysis.progressRate, equals(longProgressRate));
      expect(weeklyAnalysis.weeklyGoalPercentage, equals(testWeeklyGoalPercentage));
    });
  });
}
