// lib/features/health_metrics/caloric_requirement/domain/services/caloric_requirement_service.dart

import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_calculator.dart';

class CaloricRequirementService {
  CaloricRequirementModel analyze(HealthMetricsModel model) {
    final bmr = CaloricRequirementCalculator.calculateBMR(
      weight: model.weight,
      height: model.height,
      age: model.age,
      gender: model.gender,
    );

    final tdee = CaloricRequirementCalculator.calculateTDEE(
      bmr,
      model.activityLevel,
    );

    return CaloricRequirementModel(bmr: bmr, tdee: tdee);
  }
}