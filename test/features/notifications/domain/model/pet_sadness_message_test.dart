// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/model/pet_sadness_message.dart';

void main() {
  group('PetSadnessMessage', () {
    test('should create PetSadnessMessage with required parameters', () {
      // Arrange & Act
      const message = PetSadnessMessage(
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      expect(message.title, 'Test Title');
      expect(message.body, 'Test Body');
      expect(message.imageAsset, null);
    });

    test('should create PetSadnessMessage with optional imageAsset parameter', () {
      // Arrange & Act
      const message = PetSadnessMessage(
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

  group('PetSadnessMessageFactory', () {
    test('should return slightly sad message when inactivity is between 24-48 hours', () {
      // Arrange
      final slightlySadDuration = NotificationConstants.slightlySadThreshold;
      final almostVerySadDuration = NotificationConstants.verySadThreshold - const Duration(minutes: 1);
      
      // Act
      final exactThresholdMessage = PetSadnessMessageFactory.createMessage(slightlySadDuration);
      final almostNextLevelMessage = PetSadnessMessageFactory.createMessage(almostVerySadDuration);

      // Assert
      expect(exactThresholdMessage.title, 'Your Panda Misses You 😢');
      expect(exactThresholdMessage.body, 'Your panda misses you! It has been more than 24 hours since your last visit. Open the app and maintain your streak!');
      expect(exactThresholdMessage.imageAsset, 'panda_slightly_sad');
      
      expect(almostNextLevelMessage.title, 'Your Panda Misses You 😢');
      expect(almostNextLevelMessage.body, 'Your panda misses you! It has been more than 24 hours since your last visit. Open the app and maintain your streak!');
      expect(almostNextLevelMessage.imageAsset, 'panda_slightly_sad');
    });

    test('should return very sad message when inactivity is between 48-72 hours', () {
      // Arrange
      final verySadDuration = NotificationConstants.verySadThreshold;
      final almostExtremelySadDuration = NotificationConstants.extremelySadThreshold - const Duration(minutes: 1);
      
      // Act
      final exactThresholdMessage = PetSadnessMessageFactory.createMessage(verySadDuration);
      final almostNextLevelMessage = PetSadnessMessageFactory.createMessage(almostExtremelySadDuration);

      // Assert
      expect(exactThresholdMessage.title, 'Your Panda Is Very Sad 😭');
      expect(exactThresholdMessage.body, 'Your panda is very sad! It has been more than 2 days since your last visit. Come back and maintain your eating habits!');
      expect(exactThresholdMessage.imageAsset, 'panda_very_sad');
      
      expect(almostNextLevelMessage.title, 'Your Panda Is Very Sad 😭');
      expect(almostNextLevelMessage.body, 'Your panda is very sad! It has been more than 2 days since your last visit. Come back and maintain your eating habits!');
      expect(almostNextLevelMessage.imageAsset, 'panda_very_sad');
    });

    test('should return extremely sad message when inactivity is 72+ hours', () {
      // Arrange
      final exactThresholdDuration = NotificationConstants.extremelySadThreshold;
      final wayPastThresholdDuration = NotificationConstants.extremelySadThreshold + const Duration(hours: 24);
      
      // Act
      final exactThresholdMessage = PetSadnessMessageFactory.createMessage(exactThresholdDuration);
      final wayPastThresholdMessage = PetSadnessMessageFactory.createMessage(wayPastThresholdDuration);

      // Assert
      expect(exactThresholdMessage.title, 'URGENT: Your Panda Is Crying 💔');
      expect(exactThresholdMessage.body, 'Your panda has been crying for more than 3 days! They miss you terribly. Open the app and check your progress!');
      expect(exactThresholdMessage.imageAsset, 'panda_extremely_sad');
      
      expect(wayPastThresholdMessage.title, 'URGENT: Your Panda Is Crying 💔');
      expect(wayPastThresholdMessage.body, 'Your panda has been crying for more than 3 days! They miss you terribly. Open the app and check your progress!');
      expect(wayPastThresholdMessage.imageAsset, 'panda_extremely_sad');
    });

    test('should return extremely sad message for very long inactivity periods', () {
      // Arrange
      final veryLongInactivity = const Duration(days: 10);
      
      // Act
      final message = PetSadnessMessageFactory.createMessage(veryLongInactivity);

      // Assert
      expect(message.title, 'URGENT: Your Panda Is Crying 💔');
      expect(message.body, 'Your panda has been crying for more than 3 days! They miss you terribly. Open the app and check your progress!');
      expect(message.imageAsset, 'panda_extremely_sad');
    });

    test('should handle edge cases properly', () {
      // Arrange - Duration less than the slightly sad threshold
      final belowThreshold = NotificationConstants.slightlySadThreshold - const Duration(minutes: 1);
      
      // Act
      final belowThresholdMessage = PetSadnessMessageFactory.createMessage(belowThreshold);
      
      // Assert - Should default to extremely sad since there's no specific handling for below threshold
      expect(belowThresholdMessage.title, 'URGENT: Your Panda Is Crying 💔');
      expect(belowThresholdMessage.body, 'Your panda has been crying for more than 3 days! They miss you terribly. Open the app and check your progress!');
      expect(belowThresholdMessage.imageAsset, 'panda_extremely_sad');
    });
  });
}
