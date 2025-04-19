import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';

void main() {
  group('DetailedFoodTracking', () {
    // Positive Cases
    group('constructor', () {
      test('should create instance with valid parameters', () {
        // Arrange & Act
        final tracking = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
          currentProtein: 75.5,
          currentCarb: 200.0,
          currentFat: 50.2,
          userId: 'test_user_123',
        );

        // Assert
        expect(tracking.caloriesNeeded, 2000);
        expect(tracking.currentCaloriesConsumed, 1500);
        expect(tracking.currentProtein, 75.5);
        expect(tracking.currentCarb, 200.0);
        expect(tracking.currentFat, 50.2);
        expect(tracking.userId, 'test_user_123');
      });

      test('should handle zero values', () {
        // Arrange & Act
        final tracking = DetailedFoodTracking(
          caloriesNeeded: 0,
          currentCaloriesConsumed: 0,
          currentProtein: 0.0,
          currentCarb: 0.0,
          currentFat: 0.0,
          userId: null,
        );

        // Assert
        expect(tracking.caloriesNeeded, 0);
        expect(tracking.currentCaloriesConsumed, 0);
        expect(tracking.currentProtein, 0.0);
        expect(tracking.currentCarb, 0.0);
        expect(tracking.currentFat, 0.0);
        expect(tracking.userId, null);
      });

      test('should inherit properties from SimpleFoodTracking', () {
        // Arrange
        final tracking = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1000,
          currentProtein: 50.0,
          currentCarb: 100.0,
          currentFat: 30.0,
        );

        // Act & Assert
        expect(tracking.percentageConsumed, 50.0); // Inherited computed property
        expect(tracking.remainingCalories, 1000); // Inherited computed property
      });
    });

    group('toMap', () {
      test('should convert model to map correctly including parent fields and userId', () {
        // Arrange
        final tracking = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
          currentProtein: 75.5,
          currentCarb: 200.0,
          currentFat: 50.2,
          userId: 'test_user_123',
        );

        // Act
        final map = tracking.toMap();

        // Assert
        expect(map, {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): 2000,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): 1500,
          FoodTrackingKey.userId.toStorageKey(): 'test_user_123',
          FoodTrackingKey.currentProtein.toStorageKey(): 75.5,
          FoodTrackingKey.currentCarb.toStorageKey(): 200.0,
          FoodTrackingKey.currentFat.toStorageKey(): 50.2,
        });
      });

      test('should convert model to map correctly with null userId', () {
        // Arrange
        final tracking = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
          currentProtein: 75.5,
          currentCarb: 200.0,
          currentFat: 50.2,
          userId: null,
        );

        // Act
        final map = tracking.toMap();

        // Assert
        expect(map, {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): 2000,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): 1500,
          FoodTrackingKey.userId.toStorageKey(): null,
          FoodTrackingKey.currentProtein.toStorageKey(): 75.5,
          FoodTrackingKey.currentCarb.toStorageKey(): 200.0,
          FoodTrackingKey.currentFat.toStorageKey(): 50.2,
        });
      });
    });

    group('fromMap', () {
      test('should create instance from valid map with userId', () {
        // Arrange
        final map = {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): 2000,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): 1500,
          FoodTrackingKey.currentProtein.toStorageKey(): 75.5,
          FoodTrackingKey.currentCarb.toStorageKey(): 200.0,
          FoodTrackingKey.currentFat.toStorageKey(): 50.2,
          FoodTrackingKey.userId.toStorageKey(): 'test_user_123',
        };

        // Act
        final tracking = DetailedFoodTracking.fromMap(map);

        // Assert
        expect(tracking.caloriesNeeded, 2000);
        expect(tracking.currentCaloriesConsumed, 1500);
        expect(tracking.currentProtein, 75.5);
        expect(tracking.currentCarb, 200.0);
        expect(tracking.currentFat, 50.2);
        expect(tracking.userId, 'test_user_123');
      });

      test('should create instance from valid map without userId', () {
        // Arrange
        final map = {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): 2000,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): 1500,
          FoodTrackingKey.currentProtein.toStorageKey(): 75.5,
          FoodTrackingKey.currentCarb.toStorageKey(): 200.0,
          FoodTrackingKey.currentFat.toStorageKey(): 50.2,
        };

        // Act
        final tracking = DetailedFoodTracking.fromMap(map);

        // Assert
        expect(tracking.caloriesNeeded, 2000);
        expect(tracking.currentCaloriesConsumed, 1500);
        expect(tracking.currentProtein, 75.5);
        expect(tracking.currentCarb, 200.0);
        expect(tracking.currentFat, 50.2);
        expect(tracking.userId, null);
      });

      test('should handle integer values for double fields', () {
        // Arrange
        final map = {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): 2000,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): 1500,
          FoodTrackingKey.currentProtein.toStorageKey(): 75,
          FoodTrackingKey.currentCarb.toStorageKey(): 200,
          FoodTrackingKey.currentFat.toStorageKey(): 50,
        };

        // Act
        final tracking = DetailedFoodTracking.fromMap(map);

        // Assert
        expect(tracking.currentProtein, 75.0);
        expect(tracking.currentCarb, 200.0);
        expect(tracking.currentFat, 50.0);
      });

      test('should handle missing keys by using defaults', () {
        // Arrange
        final map = <String, dynamic>{};

        // Act
        final tracking = DetailedFoodTracking.fromMap(map);

        // Assert
        expect(tracking.caloriesNeeded, 0);
        expect(tracking.currentCaloriesConsumed, 0);
        expect(tracking.currentProtein, 0.0);
        expect(tracking.currentCarb, 0.0);
        expect(tracking.currentFat, 0.0);
      });

      test('should handle null values by using defaults', () {
        // Arrange
        final map = {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): null,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): null,
          FoodTrackingKey.currentProtein.toStorageKey(): null,
          FoodTrackingKey.currentCarb.toStorageKey(): null,
          FoodTrackingKey.currentFat.toStorageKey(): null,
        };

        // Act
        final tracking = DetailedFoodTracking.fromMap(map);

        // Assert
        expect(tracking.caloriesNeeded, 0);
        expect(tracking.currentCaloriesConsumed, 0);
        expect(tracking.currentProtein, 0.0);
        expect(tracking.currentCarb, 0.0);
        expect(tracking.currentFat, 0.0);
      });

      test('should handle partial map with some missing fields', () {
        // Arrange
        final map = {
          FoodTrackingKey.caloriesNeeded.toStorageKey(): 2000,
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): 1500,
          // No protein, carb, fat fields
        };

        // Act
        final tracking = DetailedFoodTracking.fromMap(map);

        // Assert
        expect(tracking.caloriesNeeded, 2000);
        expect(tracking.currentCaloriesConsumed, 1500);
        expect(tracking.currentProtein, 0.0); // Default value
        expect(tracking.currentCarb, 0.0); // Default value
        expect(tracking.currentFat, 0.0); // Default value
      });
    });

    group('empty', () {
      test('should create instance with all values set to 0 and null userId', () {
        // Act
        final tracking = DetailedFoodTracking.empty();

        // Assert
        expect(tracking.caloriesNeeded, 0);
        expect(tracking.currentCaloriesConsumed, 0);
        expect(tracking.currentProtein, 0.0);
        expect(tracking.currentCarb, 0.0);
        expect(tracking.currentFat, 0.0);
        expect(tracking.percentageConsumed, 0.0);
        expect(tracking.remainingCalories, 0);
        expect(tracking.userId, null);
      });
    });

    group('toSimpleFoodTracking', () {
      test('should convert to SimpleFoodTracking correctly with userId', () {
        // Arrange
        final detailedTracking = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
          currentProtein: 75.5,
          currentCarb: 200.0,
          currentFat: 50.2,
          userId: 'test_user_123',
        );

        // Act
        final simpleTracking = detailedTracking.toSimpleFoodTracking();

        // Assert
        expect(simpleTracking, isA<SimpleFoodTracking>());
        expect(simpleTracking.caloriesNeeded, 2000);
        expect(simpleTracking.currentCaloriesConsumed, 1500);
        expect(simpleTracking.percentageConsumed, 75.0);
        expect(simpleTracking.remainingCalories, 500);
        expect(simpleTracking.userId, 'test_user_123'); // userId should be transferred
      });

      test('should convert to SimpleFoodTracking correctly with null userId', () {
        // Arrange
        final detailedTracking = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
          currentProtein: 75.5,
          currentCarb: 200.0,
          currentFat: 50.2,
          userId: null,
        );

        // Act
        final simpleTracking = detailedTracking.toSimpleFoodTracking();

        // Assert
        expect(simpleTracking, isA<SimpleFoodTracking>());
        expect(simpleTracking.caloriesNeeded, 2000);
        expect(simpleTracking.currentCaloriesConsumed, 1500);
        expect(simpleTracking.percentageConsumed, 75.0);
        expect(simpleTracking.remainingCalories, 500);
        expect(simpleTracking.userId, null); // null userId should be transferred
      });
    });

    // Edge Cases
    group('edge cases', () {
      test('should handle very large values', () {
        // Arrange
        final tracking = DetailedFoodTracking(
          caloriesNeeded: 999999,
          currentCaloriesConsumed: 888888,
          currentProtein: 9999.9,
          currentCarb: 8888.8,
          currentFat: 7777.7,
        );

        // Act & Assert
        expect(tracking.caloriesNeeded, 999999);
        expect(tracking.currentCaloriesConsumed, 888888);
        expect(tracking.currentProtein, 9999.9);
        expect(tracking.currentCarb, 8888.8);
        expect(tracking.currentFat, 7777.7);
      });

      test('should handle more consumed than needed (> 100%)', () {
        // Arrange
        final tracking = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 3000,
          currentProtein: 120.0,
          currentCarb: 300.0,
          currentFat: 100.0,
        );

        // Act & Assert
        expect(tracking.percentageConsumed, 150.0);
        expect(tracking.remainingCalories, -1000);
      });

      test('should handle negative values (although not realistic)', () {
        // Arrange
        final tracking = DetailedFoodTracking(
          caloriesNeeded: -1000,
          currentCaloriesConsumed: -500,
          currentProtein: -10.0,
          currentCarb: -20.0,
          currentFat: -5.0,
        );

        // Act & Assert
        expect(tracking.caloriesNeeded, -1000);
        expect(tracking.currentCaloriesConsumed, -500);
        expect(tracking.currentProtein, -10.0);
        expect(tracking.currentCarb, -20.0);
        expect(tracking.currentFat, -5.0);
        expect(tracking.remainingCalories, -500);
        // With negative caloriesNeeded, the percentage would be 0 per implementation
        // The implementation returns 0 when caloriesNeeded <= 0
        expect(tracking.percentageConsumed, 0.0);
      });
    });
  });
}
