import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_type.dart';

void main() {
  group('ExerciseType', () {
    test('should create an instance with the given parameters', () {
      // Arrange
      const String testName = 'Running';
      const int testPercentage = 30;
      const int testColorValue = 0xFF4ECDC4;
      
      // Act
      final exerciseType = ExerciseType(
        name: testName,
        percentage: testPercentage,
        colorValue: testColorValue,
      );
      
      // Assert
      expect(exerciseType, isNotNull);
      expect(exerciseType, isA<ExerciseType>());
      expect(exerciseType.name, equals(testName));
      expect(exerciseType.percentage, equals(testPercentage));
      expect(exerciseType.colorValue, equals(testColorValue));
    });

    test('should handle boundary percentage values', () {
      // Arrange & Act - Zero percentage
      final zeroPercentage = ExerciseType(
        name: 'Zero',
        percentage: 0,
        colorValue: 0xFF000000,
      );
      
      // Arrange & Act - 100% percentage
      final fullPercentage = ExerciseType(
        name: 'Full',
        percentage: 100,
        colorValue: 0xFFFFFFFF,
      );
      
      // Assert
      expect(zeroPercentage.percentage, equals(0));
      expect(fullPercentage.percentage, equals(100));
    });

    test('should handle different color values', () {
      // Arrange & Act
      final redColor = ExerciseType(
        name: 'Red',
        percentage: 25,
        colorValue: 0xFFFF0000,
      );
      
      final blueColor = ExerciseType(
        name: 'Blue',
        percentage: 25,
        colorValue: 0xFF0000FF,
      );
      
      // Assert
      expect(redColor.colorValue, equals(0xFFFF0000));
      expect(blueColor.colorValue, equals(0xFF0000FF));
      expect(redColor.colorValue, isNot(equals(blueColor.colorValue)));
    });

    test('should handle empty string as name', () {
      // Arrange & Act
      final emptyName = ExerciseType(
        name: '',
        percentage: 50,
        colorValue: 0xFFAAAAAA,
      );
      
      // Assert
      expect(emptyName.name, equals(''));
      expect(emptyName.name.isEmpty, isTrue);
    });

    test('same properties should not make instances equal', () {
      // Arrange
      final firstInstance = ExerciseType(
        name: 'Cycling',
        percentage: 40,
        colorValue: 0xFF9B6BFF,
      );
      
      final secondInstance = ExerciseType(
        name: 'Cycling',
        percentage: 40,
        colorValue: 0xFF9B6BFF,
      );
      
      // Assert - in Dart, instances are only equal if they're the same object
      expect(identical(firstInstance, firstInstance), isTrue);
      expect(identical(firstInstance, secondInstance), isFalse);
      
      // Two different instances with the same properties are not equal
      // unless you override == operator (which ExerciseType doesn't)
      expect(firstInstance == secondInstance, isFalse);
    });

    test('should accept large integer values for color and percentage', () {
      // Arrange & Act
      final largeValues = ExerciseType(
        name: 'Large Values',
        percentage: 999999,  // Extremely large percentage
        colorValue: 0xFFFFFFFF,  // Maximum color value
      );
      
      // Assert
      expect(largeValues.percentage, equals(999999));
      expect(largeValues.colorValue, equals(0xFFFFFFFF));
    });

    test('should accept negative values for percentage', () {
      // Arrange & Act - Even though negative percentages don't make logical sense,
      // the model should still handle them to avoid runtime errors
      final negativePercentage = ExerciseType(
        name: 'Negative',
        percentage: -10,
        colorValue: 0xFF333333,
      );
      
      // Assert
      expect(negativePercentage.percentage, equals(-10));
    });
  });
}