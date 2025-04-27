// lib/features/health_metrics/caloric_requirement/domain/services/caloric_requirement_service.dart

// Project imports:
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_calculator.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

class CaloricRequirementService {
  CaloricRequirementModel analyze({
    required String userId,
    required HealthMetricsModel model,
  }) {
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

    return CaloricRequirementModel(
      userId: userId,
      bmr: bmr,
      tdee: tdee,
      timestamp: DateTime.now(),
    );
  }
}
