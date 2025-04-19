import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_nutrient_calculation_strategy.dart';

void main() {
  late DefaultNutrientCalculationStrategy strategy;

  setUp(() {
    strategy = DefaultNutrientCalculationStrategy();
  });

  group('DefaultNutrientCalculationStrategy', () {
    test('should calculate protein from food logs correctly', () {
      // Arrange
      final now = DateTime.now();
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Chicken Breast',
          subtitle: '31g protein',
          timestamp: now,
          calories: 165,
          protein: 31,
          carbs: 0,
          fat: 3.6,
        ),
        FoodLogHistoryItem(
          id: '2',
          title: 'Protein Shake',
          subtitle: '24g protein',
          timestamp: now,
          calories: 120,
          protein: 24,
          carbs: 3,
          fat: 1,
        ),
      ];

      // Act
      final result = strategy.calculateNutrientFromLogs(logs, 'protein');

      expect(result, 55.0); // 31 + 24 = 55
    });

    test('should calculate carbs from food logs correctly', () {
      final now = DateTime.now();
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Rice',
          subtitle: '45g carbs',
          timestamp: now,
          calories: 200,
          protein: 4,
          carbs: 45,
          fat: 0.5,
        ),
        FoodLogHistoryItem(
          id: '2',
          title: 'Apple',
          subtitle: '25g carbs',
          timestamp: now,
          calories: 95,
          protein: 0.5,
          carbs: 25,
          fat: 0.3,
        ),
      ];

      final result = strategy.calculateNutrientFromLogs(logs, 'carbs');

      expect(result, 70.0); // 45 + 25 = 70
    });

    test('should calculate fat from food logs correctly', () {
      final now = DateTime.now();
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Avocado',
          subtitle: '22g fat',
          timestamp: now,
          calories: 240,
          protein: 3,
          carbs: 12,
          fat: 22,
        ),
        FoodLogHistoryItem(
          id: '2',
          title: 'Olive Oil',
          subtitle: '14g fat',
          timestamp: now,
          calories: 120,
          protein: 0,
          carbs: 0,
          fat: 14,
        ),
      ];

      final result = strategy.calculateNutrientFromLogs(logs, 'fat');

      expect(result, 36.0); // 22 + 14 = 36
    });

    test('should return 0 for unknown nutrient type', () {
      final now = DateTime.now();
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Avocado',
          subtitle: '22g fat',
          timestamp: now,
          calories: 240,
          protein: 3,
          carbs: 12,
          fat: 22,
        ),
      ];

      final result = strategy.calculateNutrientFromLogs(logs, 'fiber');

      expect(result, 0.0);
    });

    test('should return 0 when logs are empty', () {
      final logs = <FoodLogHistoryItem>[];

      final result = strategy.calculateNutrientFromLogs(logs, 'protein');

      expect(result, 0.0);
    });

    test('should handle null nutrient values correctly', () {
      final now = DateTime.now();
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Unknown Food',
          subtitle: 'No nutrition data',
          timestamp: now,
          calories: 100,
          protein: null,
          carbs: null,
          fat: null,
        ),
        FoodLogHistoryItem(
          id: '2',
          title: 'Protein Shake',
          subtitle: '24g protein',
          timestamp: now,
          calories: 120,
          protein: 24,
          carbs: 3,
          fat: 1,
        ),
      ];

      final proteinResult = strategy.calculateNutrientFromLogs(logs, 'protein');
      final carbsResult = strategy.calculateNutrientFromLogs(logs, 'carbs');
      final fatResult = strategy.calculateNutrientFromLogs(logs, 'fat');

      expect(proteinResult, 24.0);
      expect(carbsResult, 3.0);
      expect(fatResult, 1.0);
    });

    test('should sum nutrients from multiple logs correctly', () {
      final now = DateTime.now();
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Food 1',
          subtitle: '5g protein',
          timestamp: now,
          calories: 100,
          protein: 5,
          carbs: 10,
          fat: 2,
        ),
        FoodLogHistoryItem(
          id: '2',
          title: 'Food 2',
          subtitle: '15g protein',
          timestamp: now,
          calories: 200,
          protein: 15,
          carbs: 20,
          fat: 8,
        ),
        FoodLogHistoryItem(
          id: '3',
          title: 'Food 3',
          subtitle: '25g protein',
          timestamp: now,
          calories: 300,
          protein: 25,
          carbs: 30,
          fat: 12,
        ),
      ];

      // Act
      final proteinResult = strategy.calculateNutrientFromLogs(logs, 'protein');
      final carbsResult = strategy.calculateNutrientFromLogs(logs, 'carbs');
      final fatResult = strategy.calculateNutrientFromLogs(logs, 'fat');

      // Assert
      expect(proteinResult, 45.0); // 5 + 15 + 25 = 45
      expect(carbsResult, 60.0); // 10 + 20 + 30 = 60
      expect(fatResult, 22.0); // 2 + 8 + 12 = 22
    });
  });
}
