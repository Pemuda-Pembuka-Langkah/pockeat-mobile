// Dart imports:
import 'dart:core';

// Project imports:
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';

/// Model untuk pesan notifikasi hewan peliharaan yang sedih
class PetSadnessMessage {
  final String title;
  final String body;
  final String? imageAsset;

  const PetSadnessMessage({
    required this.title,
    required this.body,
    this.imageAsset,
  });
}

/// Factory class untuk membuat pesan pet sadness berdasarkan durasi inaktivitas
class PetSadnessMessageFactory {
  /// Membuat pesan yang sesuai dengan durasi inaktivitas
  static PetSadnessMessage createMessage(Duration inactivityDuration) {
    // Level 1: Slightly sad (24-48 hours)
    if (inactivityDuration >= NotificationConstants.slightlySadThreshold &&
        inactivityDuration < NotificationConstants.verySadThreshold) {
      return const PetSadnessMessage(
        title: 'Your Panda Misses You 😢',
        body:
            'Your panda misses you! It has been more than 24 hours since your last visit. Open the app and maintain your streak!',
        imageAsset: 'panda_slightly_sad',
      );
    }
    // Level 2: Very sad (48-72 hours)
    else if (inactivityDuration >= NotificationConstants.verySadThreshold &&
        inactivityDuration < NotificationConstants.extremelySadThreshold) {
      return const PetSadnessMessage(
        title: 'Your Panda Is Very Sad 😭',
        body:
            'Your panda is very sad! It has been more than 2 days since your last visit. Come back and maintain your eating habits!',
        imageAsset: 'panda_very_sad',
      );
    }
    // Level 3: Extremely sad (72+ hours)
    else {
      return const PetSadnessMessage(
        title: 'URGENT: Your Panda Is Crying 💔',
        body:
            'Your panda has been crying for more than 3 days! They miss you terribly. Open the app and check your progress!',
        imageAsset: 'panda_extremely_sad',
      );
    }
  }
}
