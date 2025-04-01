import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/repositories/nutrition_repository.dart';

// Import the generated mock file
@GenerateMocks([NutritionRepository])
import 'nutrition_repository_test.mocks.dart';

void main() {
  late MockNutritionRepository mockRepository;

  // Sample test data
  final weeklyCalorieData = [
    CalorieData('M', 2100),
    CalorieData('T', 2300),
    CalorieData('W', 1950),
  ];

  final monthlyCalorieData = [
    CalorieData('Week 1', 2150),
    CalorieData('Week 2', 2250),
  ];

  final nutrientStats = [
    NutritionStat(
      label: 'Consumed',
      value: '1,850',
      color: Colors.blue,
    ),
    NutritionStat(
      label: 'Burned',
      value: '450',
      color: Colors.red,
    ),
  ];

  final macroNutrients = [
    MacroNutrient(
      label: 'Protein',
      percentage: 25,
      detail: '75g/120g',
      color: Colors.blue,
    ),
    MacroNutrient(
      label: 'Carbs',
      percentage: 60,
      detail: '180g/300g',
      color: Colors.green,
    ),
  ];

  final microNutrients = [
    MicroNutrient(
      nutrient: 'Fiber',
      current: '12g',
      target: '25g',
      progress: 0.48,
      color: Colors.green,
    ),
    MicroNutrient(
      nutrient: 'Vitamin C',
      current: '80mg',
      target: '90mg',
      progress: 0.89,
      color: Colors.orange,
    ),
  ];

  final meals = [
    Meal(
      name: 'Breakfast',
      calories: 450,
      totalCalories: 2000,
      time: '8:00 AM',
      color: Colors.blue,
    ),
    Meal(
      name: 'Lunch',
      calories: 650,
      totalCalories: 2000,
      time: '1:00 PM',
      color: Colors.green,
    ),
  ];

  setUp(() {
    mockRepository = MockNutritionRepository();
  });

  group('NutritionRepository', () {
    test('getCalorieData should return weekly data when isWeeklyView is true', () async {
      // Arrange
      when(mockRepository.getCalorieData(true))
          .thenAnswer((_) async => weeklyCalorieData);

      // Act
      final result = await mockRepository.getCalorieData(true);

      // Assert
      expect(result, equals(weeklyCalorieData));
      verify(mockRepository.getCalorieData(true)).called(1);
    });

    test('getCalorieData should return monthly data when isWeeklyView is false', () async {
      // Arrange
      when(mockRepository.getCalorieData(false))
          .thenAnswer((_) async => monthlyCalorieData);

      // Act
      final result = await mockRepository.getCalorieData(false);

      // Assert
      expect(result, equals(monthlyCalorieData));
      verify(mockRepository.getCalorieData(false)).called(1);
    });

    test('getNutrientStats should return list of nutrition stats', () async {
      // Arrange
      when(mockRepository.getNutrientStats())
          .thenAnswer((_) async => nutrientStats);

      // Act
      final result = await mockRepository.getNutrientStats();

      // Assert
      expect(result, equals(nutrientStats));
      verify(mockRepository.getNutrientStats()).called(1);
    });

    test('getMacroNutrients should return list of macro nutrients', () async {
      // Arrange
      when(mockRepository.getMacroNutrients())
          .thenAnswer((_) async => macroNutrients);

      // Act
      final result = await mockRepository.getMacroNutrients();

      // Assert
      expect(result, equals(macroNutrients));
      verify(mockRepository.getMacroNutrients()).called(1);
    });

    test('getMicroNutrients should return list of micro nutrients', () async {
      // Arrange
      when(mockRepository.getMicroNutrients())
          .thenAnswer((_) async => microNutrients);

      // Act
      final result = await mockRepository.getMicroNutrients();

      // Assert
      expect(result, equals(microNutrients));
      verify(mockRepository.getMicroNutrients()).called(1);
    });

    test('getMeals should return list of meals', () async {
      // Arrange
      when(mockRepository.getMeals())
          .thenAnswer((_) async => meals);

      // Act
      final result = await mockRepository.getMeals();

      // Assert
      expect(result, equals(meals));
      verify(mockRepository.getMeals()).called(1);
    });

    test('methods should handle empty results', () async {
      // Arrange
      when(mockRepository.getCalorieData(any))
          .thenAnswer((_) async => []);
      when(mockRepository.getNutrientStats())
          .thenAnswer((_) async => []);
      when(mockRepository.getMacroNutrients())
          .thenAnswer((_) async => []);
      when(mockRepository.getMicroNutrients())
          .thenAnswer((_) async => []);
      when(mockRepository.getMeals())
          .thenAnswer((_) async => []);

      // Act & Assert
      expect(await mockRepository.getCalorieData(true), isEmpty);
      expect(await mockRepository.getNutrientStats(), isEmpty);
      expect(await mockRepository.getMacroNutrients(), isEmpty);
      expect(await mockRepository.getMicroNutrients(), isEmpty);
      expect(await mockRepository.getMeals(), isEmpty);
    });

    test('methods should propagate exceptions', () async {
      // Arrange
      final exception = Exception('Network error');
      when(mockRepository.getCalorieData(any)).thenThrow(exception);
      when(mockRepository.getNutrientStats()).thenThrow(exception);
      when(mockRepository.getMacroNutrients()).thenThrow(exception);
      when(mockRepository.getMicroNutrients()).thenThrow(exception);
      when(mockRepository.getMeals()).thenThrow(exception);

      // Act & Assert
      expect(() => mockRepository.getCalorieData(true), throwsException);
      expect(() => mockRepository.getNutrientStats(), throwsException);
      expect(() => mockRepository.getMacroNutrients(), throwsException);
      expect(() => mockRepository.getMicroNutrients(), throwsException);
      expect(() => mockRepository.getMeals(), throwsException);
    });
  });
}