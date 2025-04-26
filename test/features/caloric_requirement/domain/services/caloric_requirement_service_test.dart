// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_calculator.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
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
      expect(bmr, closeTo(10 * 70 + 6.25 * 175 - 5 * 25 + 5, 0.01));
    });

    test('calculates BMR for female correctly', () {
      final bmr = CaloricRequirementCalculator.calculateBMR(
        weight: 60,
        height: 160,
        age: 30,
        gender: 'female',
      );
      expect(bmr, closeTo(10 * 60 + 6.25 * 160 - 5 * 30 - 161, 0.01));
    });

    test('returns correct activity multiplier for all levels', () {
      final levels = {
        'sedentary': 1.2,
        'light': 1.375,
        'moderate': 1.55,
        'active': 1.725,
        'very active': 1.9,
        'extra active': 2.0,
        'unknown': 1.2, // fallback
      };

      levels.forEach((level, expected) {
        final result = CaloricRequirementCalculator.activityMultiplier(level);
        expect(result, expected);
      });
    });

    test('calculates TDEE correctly', () {
      final bmr = 1500.0;
      final tdee = CaloricRequirementCalculator.calculateTDEE(bmr, 'moderate');
      expect(tdee, closeTo(1500.0 * 1.55, 0.01));
    });
  });

  group('CaloricRequirementService', () {
    test('analyze returns correct model based on HealthMetricsModel', () {
      final model = HealthMetricsModel(
        userId: 'abc',
        height: 170,
        weight: 65,
        age: 24,
        gender: 'male',
        activityLevel: 'active',
        fitnessGoal: 'Maintain',
      );

      final service = CaloricRequirementService();
      final result = service.analyze(
        userId: model.userId,
        model: model,
        );

      final expectedBMR = CaloricRequirementCalculator.calculateBMR(
        weight: 65,
        height: 170,
        age: 24,
        gender: 'male',
      );

      final expectedTDEE = CaloricRequirementCalculator.calculateTDEE(
        expectedBMR,
        'active',
      );

      expect(result.userId, model.userId);
      expect(result.bmr, closeTo(expectedBMR, 0.01));
      expect(result.tdee, closeTo(expectedTDEE, 0.01));
      expect(result.timestamp, isA<DateTime>());
    });
  });
}
