import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';

void main() {
  group('CaloricRequirementModel', () {
    test('should correctly create an instance via constructor', () {
      final model = CaloricRequirementModel(bmr: 1500.0, tdee: 2000.0);

      expect(model.bmr, 1500.0);
      expect(model.tdee, 2000.0);
    });

    test('toMap should return correct map representation', () {
      final model = CaloricRequirementModel(bmr: 1600.5, tdee: 2200.75);
      final map = model.toMap();

      expect(map, {'bmr': 1600.5, 'tdee': 2200.75});
    });

    test('fromMap should create an instance with correct values', () {
      final map = {'bmr': 1400, 'tdee': 1800};
      final model = CaloricRequirementModel.fromMap(map);

      expect(model.bmr, 1400.0);
      expect(model.tdee, 1800.0);
    });

    test('fromMap should handle num values like int and double correctly', () {
      final map = {'bmr': 1350.75, 'tdee': 1750}; // mix of double and int
      final model = CaloricRequirementModel.fromMap(map);

      expect(model.bmr, 1350.75);
      expect(model.tdee, 1750.0);
    });
  });
}