// Dart imports:
import 'dart:core';

/// Model for pet status messages
class PetStatusMessage {
  final String title;
  final String body;
  final String imageAsset;

  const PetStatusMessage({
    required this.title,
    required this.body,
    required this.imageAsset,
  });
}

/// Factory class to create pet status messages based on mood, heart level, and calories
class PetStatusMessageFactory {
  /// Creates appropriate messages based on pet status
  /// 
  /// [mood] - Pet mood ('happy' or 'sad')
  /// [heartLevel] - Pet heart level (0-4)
  /// [currentCalories] - Current calories consumed
  /// [requiredCalories] - Daily calorie target
  static PetStatusMessage createMessage({
    required String mood,
    required int heartLevel,
    required int currentCalories,
    required int requiredCalories,
  }) {
    final bool isHappy = mood == 'happy';
    final String imageAsset = isHappy ? 'pet_happy' : 'pet_sad';
    final int caloriesRemaining = requiredCalories - currentCalories;
    final double caloriesPercentage = currentCalories / requiredCalories * 100;
    
    // Format percentage with 1 decimal place
    final String formattedPercentage = caloriesPercentage.toStringAsFixed(1);

    // Messages based on mood and heart level combination
    if (isHappy) {
      if (heartLevel >= 4) {
        return PetStatusMessage(
          title: 'Panda is Very Happy! 🐼💖',
          body: 'You\'ve been eating well! Already reached $formattedPercentage% of your calorie target. Only $caloriesRemaining calories left to reach your goal!',
          imageAsset: imageAsset,
        );
      } else if (heartLevel == 3) {
        return PetStatusMessage(
          title: 'Panda is Happy! 🐼😊',
          body: 'You\'ve logged your food today. Already reached $formattedPercentage% of your calorie target. Still need $caloriesRemaining more calories to reach your goal!',
          imageAsset: imageAsset,
        );
      } else if (heartLevel == 2) {
        return PetStatusMessage(
          title: 'Panda is Quite Happy 🐼',
          body: 'You\'ve started logging your food. Only reached $formattedPercentage% of your calorie target. Still need $caloriesRemaining more calories!',
          imageAsset: imageAsset,
        );
      } else {
        return PetStatusMessage(
          title: 'Panda Needs More Food 🐼',
          body: 'You\'ve logged some food, but only $formattedPercentage% of your target. Still need $caloriesRemaining more calories!',
          imageAsset: imageAsset,
        );
      }
    } else {
      // Sad mood messages
      if (heartLevel >= 2) {
        return PetStatusMessage(
          title: 'Panda is a Bit Sad 😕',
          body: 'You haven\'t logged any food today, but you still have $currentCalories calories out of your $requiredCalories target. Let\'s log your meals!',
          imageAsset: imageAsset,
        );
      } else if (heartLevel == 1) {
        return PetStatusMessage(
          title: 'Panda is Sad 😢',
          body: 'You haven\'t logged any food today and only have $currentCalories calories out of your $requiredCalories target. Let\'s start logging your meals!',
          imageAsset: imageAsset,
        );
      } else {
        return PetStatusMessage(
          title: 'Panda is Very Sad 😭',
          body: 'Panda is hungry! You haven\'t logged any food today and have no calorie intake yet. Your daily calorie target: $requiredCalories. Let\'s eat!',
          imageAsset: imageAsset,
        );
      }
    }
  }
}
