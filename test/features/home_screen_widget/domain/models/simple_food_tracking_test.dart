import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';

void main() {
  group('SimpleFoodTracking', () {
    // Positive Cases
    group('constructor', () {
      test('should create instance with valid parameters', () {
        // Arrange & Act
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
        );

        // Assert
        expect(tracking.caloriesNeeded, 2000);
        expect(tracking.currentCaloriesConsumed, 1500);
      });

      test('should handle zero values', () {
        // Arrange & Act
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 0,
          currentCaloriesConsumed: 0,
        );

        // Assert
        expect(tracking.caloriesNeeded, 0);
        expect(tracking.currentCaloriesConsumed, 0);
      });
    });

    group('computed properties', () {
      test('percentageConsumed should return correct percentage when caloriesNeeded > 0', () {
        // Arrange
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1000,
        );

        // Act & Assert
        expect(tracking.percentageConsumed, 50.0);
      });

      test('percentageConsumed should return 0 when caloriesNeeded is 0', () {
        // Arrange
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 0,
          currentCaloriesConsumed: 1000,
        );

        // Act & Assert
        expect(tracking.percentageConsumed, 0.0);
      });

      test('remainingCalories should return correct value', () {
        // Arrange
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 800,
        );

        // Act & Assert
        expect(tracking.remainingCalories, 1200);
      });

      test('remainingCalories can be negative if consumption exceeds needed', () {
        // Arrange
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 2500,
        );

        // Act & Assert
        expect(tracking.remainingCalories, -500);
      });
    });

    group('toMap', () {
      test('should convert model to map correctly', () {
        // Arrange
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
        );

        // Act
        final map = tracking.toMap();

        // Assert
        expect(map, {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): 2000,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): 1500,
        });
      });
    });

    group('fromMap', () {
      test('should create instance from valid map', () {
        // Arrange
        final map = {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): 2000,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): 1500,
        };

        // Act
        final tracking = SimpleFoodTracking.fromMap(map);

        // Assert
        expect(tracking.caloriesNeeded, 2000);
        expect(tracking.currentCaloriesConsumed, 1500);
      });

      test('should handle missing keys by using defaults', () {
        // Arrange
        final map = <String, dynamic>{};

        // Act
        final tracking = SimpleFoodTracking.fromMap(map);

        // Assert
        expect(tracking.caloriesNeeded, 0);
        expect(tracking.currentCaloriesConsumed, 0);
      });

      test('should handle null values by using defaults', () {
        // Arrange
        final map = {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): null,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): null,
        };

        // Act
        final tracking = SimpleFoodTracking.fromMap(map);

        // Assert
        expect(tracking.caloriesNeeded, 0);
        expect(tracking.currentCaloriesConsumed, 0);
      });
    });

    group('empty', () {
      test('should create instance with all values set to 0', () {
        // Act
        final tracking = SimpleFoodTracking.empty();

        // Assert
        expect(tracking.caloriesNeeded, 0);
        expect(tracking.currentCaloriesConsumed, 0);
        expect(tracking.percentageConsumed, 0.0);
        expect(tracking.remainingCalories, 0);
      });
    });

    // Edge Cases
    group('edge cases', () {
      test('should handle very large values', () {
        // Arrange
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 999999,
          currentCaloriesConsumed: 888888,
        );

        // Act & Assert
        expect(tracking.caloriesNeeded, 999999);
        expect(tracking.currentCaloriesConsumed, 888888);
        expect(tracking.remainingCalories, 111111);
        expect(tracking.percentageConsumed, closeTo(88.89, 0.01));
      });

      test('should handle more consumed than needed (> 100%)', () {
        // Arrange
        final tracking = SimpleFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 3000,
        );

        // Act & Assert
        expect(tracking.percentageConsumed, 150.0);
        expect(tracking.remainingCalories, -1000);
      });
    });
  });
}
