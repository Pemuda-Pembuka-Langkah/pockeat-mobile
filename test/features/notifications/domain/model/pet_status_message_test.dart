// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/model/pet_status_message.dart';

void main() {
  group('PetStatusMessage', () {
    test('should create a PetStatusMessage with all required properties', () {
      // Arrange & Act
      final message = PetStatusMessage(
        title: 'Test Title',
        body: 'Test Body',
        imageAsset: 'test_image',
      );

      // Assert
      expect(message.title, 'Test Title');
      expect(message.body, 'Test Body');
      expect(message.imageAsset, 'test_image');
    });
  });

  group('PetStatusMessageFactory - Happy Mood', () {
    test('should create very happy message when mood is happy and heart level is 4', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 4,
        currentCalories: 1500,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.title, 'Panda is Very Happy! 🐼💖');
      expect(message.body, contains('You\'ve been eating well!'));
      expect(message.body, contains('75.0%'));
      expect(message.body, contains('500 calories'));
      expect(message.imageAsset, 'pet_happy');
    });

    test('should create happy message when mood is happy and heart level is 3', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 3,
        currentCalories: 1000,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.title, 'Panda is Happy! 🐼😊');
      expect(message.body, contains('You\'ve logged your food today'));
      expect(message.body, contains('50.0%'));
      expect(message.body, contains('1000 more calories'));
      expect(message.imageAsset, 'pet_happy');
    });

    test('should create quite happy message when mood is happy and heart level is 2', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 2,
        currentCalories: 500,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.title, 'Panda is Quite Happy 🐼');
      expect(message.body, contains('You\'ve started logging your food'));
      expect(message.body, contains('25.0%'));
      expect(message.body, contains('1500 more calories'));
      expect(message.imageAsset, 'pet_happy');
    });

    test('should create needs more food message when mood is happy and heart level is below 2', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 1,
        currentCalories: 200,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.title, 'Panda Needs More Food 🐼');
      expect(message.body, contains('You\'ve logged some food'));
      expect(message.body, contains('10.0%'));
      expect(message.body, contains('1800 more calories'));
      expect(message.imageAsset, 'pet_happy');
    });
  });

  group('PetStatusMessageFactory - Sad Mood', () {
    test('should create a bit sad message when mood is sad and heart level is 2 or more', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'sad',
        heartLevel: 2,
        currentCalories: 500,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.title, 'Panda is a Bit Sad 😕');
      expect(message.body, contains('You haven\'t logged any food today'));
      expect(message.body, contains('500 calories out of your 2000 target'));
      expect(message.imageAsset, 'pet_sad');
    });

    test('should create sad message when mood is sad and heart level is 1', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'sad',
        heartLevel: 1,
        currentCalories: 200,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.title, 'Panda is Sad 😢');
      expect(message.body, contains('You haven\'t logged any food today and only have'));
      expect(message.body, contains('200 calories out of your 2000 target'));
      expect(message.imageAsset, 'pet_sad');
    });

    test('should create very sad message when mood is sad and heart level is 0', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'sad',
        heartLevel: 0,
        currentCalories: 0,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.title, 'Panda is Very Sad 😭');
      expect(message.body, contains('Panda is hungry!'));
      expect(message.body, contains('no calorie intake yet'));
      expect(message.body, contains('daily calorie target: 2000'));
      expect(message.imageAsset, 'pet_sad');
    });
  });

  group('PetStatusMessageFactory - Edge Cases', () {
    test('should handle zero calories correctly', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 1,
        currentCalories: 0,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.body, contains('0.0%'));
      expect(message.body, contains('2000 more calories'));
    });

    test('should handle 100% of calories correctly', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 4,
        currentCalories: 2000,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.body, contains('100.0%'));
      expect(message.body, contains('0 calories left'));
    });

    test('should handle calories over 100% correctly', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 4,
        currentCalories: 2500,
        requiredCalories: 2000,
      );

      // Assert
      expect(message.body, contains('125.0%'));
      // Negative calories should be shown as negative
      expect(message.body, contains('-500 calories'));
    });

    test('should handle uppercase mood value correctly', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'HAPPY',
        heartLevel: 4,
        currentCalories: 1500,
        requiredCalories: 2000,
      );

      // Assert
      // It should not recognize 'HAPPY' as 'happy' and default to sad mood
      expect(message.imageAsset, 'pet_sad');
    });
  });

  group('PetStatusMessageFactory - Percentage Formatting', () {
    test('should format percentage with one decimal place', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 4,
        currentCalories: 1234,
        requiredCalories: 2000,
      );

      // Assert
      // 1234/2000 * 100 = 61.7%
      expect(message.body, contains('61.7%'));
    });

    test('should handle recurring decimal places correctly', () {
      // Arrange & Act
      final message = PetStatusMessageFactory.createMessage(
        mood: 'happy',
        heartLevel: 4,
        currentCalories: 2000,
        requiredCalories: 3000,
      );

      // Assert
      // 2000/3000 * 100 = 66.666...%
      expect(message.body, contains('66.7%'));
    });
  });
}
