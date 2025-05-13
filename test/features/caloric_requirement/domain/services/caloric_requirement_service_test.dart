// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_calculator.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/macronutrient_requirement_calculator.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

void main() {
  group('CaloricRequirementCalculator', () {
    test('calculates BMR for male correctly', () {
      final bmr = CaloricRequirementCalculator.calculateBMR(
        weight: 70,
        height: 175,
        age: 25,
        gender: 'male',
      );
      final expectedBMR = 10 * 70 + 6.25 * 175 - 5 * 25 + 5;
      expect(bmr, closeTo(expectedBMR, 0.01));
    });

    test('calculates BMR for female correctly', () {
      final bmr = CaloricRequirementCalculator.calculateBMR(
        weight: 60,
        height: 160,
        age: 30,
        gender: 'female',
      );
      final expectedBMR = 10 * 60 + 6.25 * 160 - 5 * 30 - 161;
      expect(bmr, closeTo(expectedBMR, 0.01));
    });

    test('returns correct activity multiplier for all levels', () {
      final levels = {
        'sedentary': 1.2,
        'light': 1.375,
        'moderate': 1.55,
        'active': 1.725,
        'very active': 1.9,
        'extra active': 2.0,
        'unknown': 1.2, // fallback default
      };

      levels.forEach((level, expectedMultiplier) {
        final result = CaloricRequirementCalculator.activityMultiplier(level);
        expect(result, expectedMultiplier);
      });
    });

    test('calculates TDEE correctly', () {
      final bmr = 1500.0;
      final tdee = CaloricRequirementCalculator.calculateTDEE(bmr, 'moderate');
      final expectedTDEE = 1500.0 * 1.55;
      expect(tdee, closeTo(expectedTDEE, 0.01));
    });
  });

  group('CaloricRequirementService', () {
    test('analyze() returns model with correct BMR, TDEE, and macronutrients', () {
      final model = HealthMetricsModel(
        userId: 'user123',
        height: 170,
        weight: 65,
        age: 24,
        gender: 'male',
        activityLevel: 'active',
        fitnessGoal: 'Maintain',
        bmi: 22.5,
        bmiCategory: 'Normal',
        desiredWeight: 60,
      );

      final service = CaloricRequirementService();
      final result = service.analyze(
        userId: model.userId,
        model: model,
      );

      // Expected calculations
      final expectedBMR = CaloricRequirementCalculator.calculateBMR(
        weight: model.weight,
        height: model.height,
        age: model.age,
        gender: model.gender,
      );

      final expectedTDEE = CaloricRequirementCalculator.calculateTDEE(
        expectedBMR,
        model.activityLevel,
      );

      final expectedMacros = MacronutrientCalculator.calculateGramsFromTDEE(expectedTDEE);

      expect(result.userId, model.userId);
      expect(result.bmr, closeTo(expectedBMR, 0.01));
      expect(result.tdee, closeTo(expectedTDEE, 0.01));
      expect(result.proteinGrams, closeTo(expectedMacros['proteinGrams']!, 0.01));
      expect(result.carbsGrams, closeTo(expectedMacros['carbsGrams']!, 0.01));
      expect(result.fatGrams, closeTo(expectedMacros['fatGrams']!, 0.01));
      expect(result.timestamp, isA<DateTime>());
    });
  });
}
