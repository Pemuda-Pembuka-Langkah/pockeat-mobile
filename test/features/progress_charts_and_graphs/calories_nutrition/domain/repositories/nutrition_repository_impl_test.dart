import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/repositories/nutrition_repository_impl.dart';

void main() {
  late NutritionRepositoryImpl repository;

  setUp(() {
    repository = NutritionRepositoryImpl();
  });

  group('NutritionRepositoryImpl', () {
    test('should initialize with correct color constants', () {
      expect(repository.primaryPink, equals(const Color(0xFFFF6B6B)));
      expect(repository.primaryGreen, equals(const Color(0xFF4ECDC4)));
      expect(repository.primaryYellow, equals(const Color(0xFFFFB946)));
    });

    group('getCalorieData', () {
      test('should return weekly data when isWeeklyView is true', () async {
        // Act
        final result = await repository.getCalorieData(true);

        // Assert
        expect(result, isA<List<CalorieData>>());
        expect(result.length, 7); // 7 days in a week
        
        // Verify day labels for weekly view
        expect(result[0].day, equals('M'));
        expect(result[1].day, equals('T'));
        expect(result[2].day, equals('W'));
        expect(result[3].day, equals('T'));
        expect(result[4].day, equals('F'));
        expect(result[5].day, equals('S'));
        expect(result[6].day, equals('S'));
        
        // Verify some calorie values
        expect(result[0].calories, equals(2100));
        expect(result[1].calories, equals(2300));
      });

      test('should return monthly data when isWeeklyView is false', () async {
        // Act
        final result = await repository.getCalorieData(false);

        // Assert
        expect(result, isA<List<CalorieData>>());
        expect(result.length, 4); // 4 weeks in a month
        
        // Verify week labels for monthly view
        expect(result[0].day, equals('Week 1'));
        expect(result[1].day, equals('Week 2'));
        expect(result[2].day, equals('Week 3'));
        expect(result[3].day, equals('Week 4'));
        
        // Verify some calorie values
        expect(result[0].calories, equals(2150));
        expect(result[1].calories, equals(2250));
      });
    });

    test('getNutrientStats should return correct nutrition stats', () async {
      // Act
      final result = await repository.getNutrientStats();

      // Assert
      expect(result, isA<List<NutritionStat>>());
      expect(result.length, 3);
      
      // Verify labels and values
      expect(result[0].label, equals('Consumed'));
      expect(result[0].value, equals('1,850'));
      expect(result[0].color, equals(repository.primaryPink));
      
      expect(result[1].label, equals('Burned'));
      expect(result[1].value, equals('450'));
      expect(result[1].color, equals(repository.primaryGreen));
      
      expect(result[2].label, equals('Net'));
      expect(result[2].value, equals('1,400'));
      expect(result[2].color, equals(repository.primaryPink));
    });

    test('getMacroNutrients should return correct macro nutrients', () async {
      // Act
      final result = await repository.getMacroNutrients();

      // Assert
      expect(result, isA<List<MacroNutrient>>());
      expect(result.length, 3);
      
      // Verify first macro nutrient (Protein)
      expect(result[0].label, equals('Protein'));
      expect(result[0].percentage, equals(25));
      expect(result[0].detail, equals('75g/120g'));
      expect(result[0].color, equals(repository.primaryPink));
      
      // Verify second macro nutrient (Carbs)
      expect(result[1].label, equals('Carbs'));
      expect(result[1].percentage, equals(55));
      expect(result[1].detail, equals('138g/250g'));
      expect(result[1].color, equals(repository.primaryGreen));
      
      // Verify third macro nutrient (Fat)
      expect(result[2].label, equals('Fat'));
      expect(result[2].percentage, equals(20));
      expect(result[2].detail, equals('32g/65g'));
      expect(result[2].color, equals(repository.primaryYellow));
    });

    test('getMicroNutrients should return correct micro nutrients', () async {
      // Act
      final result = await repository.getMicroNutrients();

      // Assert
      expect(result, isA<List<MicroNutrient>>());
      expect(result.length, 4);
      
      // Verify first micro nutrient (Fiber)
      expect(result[0].nutrient, equals('Fiber'));
      expect(result[0].current, equals('12g'));
      expect(result[0].target, equals('25g'));
      expect(result[0].progress, equals(0.48));
      expect(result[0].color, equals(repository.primaryGreen));
      
      // Verify second micro nutrient (Sugar)
      expect(result[1].nutrient, equals('Sugar'));
      expect(result[1].current, equals('18g'));
      expect(result[1].target, equals('30g'));
      expect(result[1].progress, equals(0.6));
      expect(result[1].color, equals(repository.primaryPink));
      
      // Verify third micro nutrient (Sodium)
      expect(result[2].nutrient, equals('Sodium'));
      expect(result[2].current, equals('1200mg'));
      expect(result[2].target, equals('2300mg'));
      expect(result[2].progress, equals(0.52));
      expect(result[2].color, equals(repository.primaryGreen));
      
      // Verify fourth micro nutrient (Iron)
      expect(result[3].nutrient, equals('Iron'));
      expect(result[3].current, equals('12mg'));
      expect(result[3].target, equals('18mg'));
      expect(result[3].progress, equals(0.67));
      expect(result[3].color, equals(repository.primaryPink));
    });

    test('getMeals should return correct meals', () async {
      // Act
      final result = await repository.getMeals();

      // Assert
      expect(result, isA<List<Meal>>());
      expect(result.length, 3);
      
      // Verify first meal (Breakfast)
      expect(result[0].name, equals('Breakfast'));
      expect(result[0].calories, equals(550));
      expect(result[0].totalCalories, equals(2150));
      expect(result[0].time, equals('7:30 AM'));
      expect(result[0].color, equals(repository.primaryPink));
      expect(result[0].percentage, equals(550 / 2150)); // Test computed property
      
      // Verify second meal (Lunch)
      expect(result[1].name, equals('Lunch'));
      expect(result[1].calories, equals(750));
      expect(result[1].totalCalories, equals(2150));
      expect(result[1].time, equals('12:30 PM'));
      expect(result[1].color, equals(repository.primaryGreen));
      expect(result[1].percentage, equals(750 / 2150)); // Test computed property
      
      // Verify third meal (Dinner)
      expect(result[2].name, equals('Dinner'));
      expect(result[2].calories, equals(650));
      expect(result[2].totalCalories, equals(2150));
      expect(result[2].time, equals('7:00 PM'));
      expect(result[2].color, equals(repository.primaryYellow));
      expect(result[2].percentage, equals(650 / 2150)); // Test computed property
    });
  });
}