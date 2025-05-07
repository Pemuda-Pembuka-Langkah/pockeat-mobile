// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/pet_companion/domain/model/pet_information.dart';

void main() {
  group('PetInformation', () {
    test('should create a valid model from constructor', () {
      // Arrange & Act
      final model = PetInformation(
        heart: 5,
        mood: 'Happy',
        isCalorieOverTarget: false,
      );

      // Assert
      expect(model.name, 'Panda');
      expect(model.heart, 5);
      expect(model.mood, 'Happy');
      expect(model.isCalorieOverTarget, false);
    });

    test('should create a model with different values', () {
      // Arrange & Act
      final model = PetInformation(
        heart: 2,
        mood: 'Sad',
        isCalorieOverTarget: true,
      );

      // Assert
      expect(model.name, 'Panda'); // name is fixed
      expect(model.heart, 2);
      expect(model.mood, 'Sad');
      expect(model.isCalorieOverTarget, true);
    });

    test('should have fixed name as Panda', () {
      // Arrange & Act
      final model1 = PetInformation(
        heart: 3,
        mood: 'Neutral',
        isCalorieOverTarget: false,
      );
      
      final model2 = PetInformation(
        heart: 4,
        mood: 'Excited',
        isCalorieOverTarget: true,
      );

      // Assert
      expect(model1.name, 'Panda');
      expect(model2.name, 'Panda');
      expect(model1.name, equals(model2.name));
    });
  });
} 