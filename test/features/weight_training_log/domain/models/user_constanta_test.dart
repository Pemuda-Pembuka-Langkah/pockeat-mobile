// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/weight_training_log/domain/models/user_constanta.dart';

void main() {
  group('UserConstanta', () {
    test('should have correct default values', () {
      // Test user profile constants
      expect(UserConstanta.gender, 'Male');
      expect(UserConstanta.weight, 70.0);
      expect(UserConstanta.height, 175.0);
      expect(UserConstanta.age, 30);
      
      // Test exercise preferences
      expect(UserConstanta.defaultReps, 10);
      expect(UserConstanta.defaultWeight, 20.0);
      expect(UserConstanta.defaultDuration, 45.0);
    });

    test('should have all bodyParts defined', () {
      expect(UserConstanta.bodyParts, isA<List<String>>());
      expect(UserConstanta.bodyParts.length, 8);
      
      // Check specific body parts
      expect(UserConstanta.bodyParts, contains('Chest'));
      expect(UserConstanta.bodyParts, contains('Back'));
      expect(UserConstanta.bodyParts, contains('Shoulders'));
      expect(UserConstanta.bodyParts, contains('Biceps'));
      expect(UserConstanta.bodyParts, contains('Triceps'));
      expect(UserConstanta.bodyParts, contains('Legs'));
      expect(UserConstanta.bodyParts, contains('Core'));
      expect(UserConstanta.bodyParts, contains('Full Body'));
    });

    test('should be able to modify static fields', () {
      // Save original values
      final originalGender = UserConstanta.gender;
      final originalWeight = UserConstanta.weight;
      
      // Modify values
      UserConstanta.gender = 'Female';
      UserConstanta.weight = 65.0;
      
      // Check modified values
      expect(UserConstanta.gender, 'Female');
      expect(UserConstanta.weight, 65.0);
      
      // Restore original values for other tests
      UserConstanta.gender = originalGender;
      UserConstanta.weight = originalWeight;
    });
  });
}
