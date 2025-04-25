// Project imports:
import '../models/caloric_requirement_model.dart';

abstract class CaloricRequirementRepository {
  Future<void> saveCaloricRequirement({
    required String userId,
    required CaloricRequirementModel result,
  });

  Future<CaloricRequirementModel?> getCaloricRequirement(String userId);
}
