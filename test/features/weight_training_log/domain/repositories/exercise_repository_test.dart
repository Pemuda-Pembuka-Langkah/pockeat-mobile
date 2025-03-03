import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/exercise_repository.dart';

void main() {
  group('Exercise Repository', () {
    test('should have correct pre-defined exercises for Upper Body', () {
      expect(exercisesByCategory.containsKey('Upper Body'), isTrue);
      expect(exercisesByCategory['Upper Body']!['Bench Press'], 5.0);
      expect(exercisesByCategory['Upper Body']!['Bicep Curls'], 3.5);
    });

    test('should return null for non-existing body part', () {
      expect(exercisesByCategory['Non Existent'], isNull);
    });

    test('should return null for non-existing exercise in valid category', () {
      expect(exercisesByCategory['Upper Body']?['NonExistentExercise'], isNull);
    });
  });
}