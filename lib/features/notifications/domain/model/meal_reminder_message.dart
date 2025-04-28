// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';

/// Abstract Product - Interface for all meal reminder messages
@immutable
abstract class MealReminderMessage {
  /// Get notification title
  String get title;

  /// Get notification body
  String get body;

  /// Get meal type (breakfast, lunch, dinner)
  String get mealType;
}

/// Concrete Product - Message for breakfast reminder
class BreakfastReminderMessage implements MealReminderMessage {
  @override
  String get title => 'Time for Breakfast! 🍳';

  @override
  String get body =>
      'Start your day with energy! Don\'t forget to have a healthy breakfast.';

  @override
  String get mealType => NotificationConstants.breakfast;
}

/// Concrete Product - Message for lunch reminder
class LunchReminderMessage implements MealReminderMessage {
  @override
  String get title => 'Time for Lunch! 🍱';

  @override
  String get body => 'Take a break and recharge with a nutritious lunch.';

  @override
  String get mealType => NotificationConstants.lunch;
}

/// Concrete Product - Message for dinner reminder
class DinnerReminderMessage implements MealReminderMessage {
  @override
  String get title => 'Time for Dinner! 🍽️';

  @override
  String get body => 'Complete your daily nutrition with a balanced dinner.';

  @override
  String get mealType => NotificationConstants.dinner;
}

/// Factory - Class to create appropriate MealReminderMessage instance
class MealReminderMessageFactory {
  /// Create MealReminderMessage based on meal type
  ///
  /// [mealType] is the type of meal (breakfast, lunch, dinner)
  /// Returns MealReminderMessage appropriate for the meal type
  static MealReminderMessage createMessage(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return BreakfastReminderMessage();
      case 'lunch':
        return LunchReminderMessage();
      case 'dinner':
        return DinnerReminderMessage();
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }
  }

  /// Helper method to create a notification message based on time of day
  ///
  /// This is useful when wanting to show a notification immediately
  /// [dateTime] Optional parameter to specify a time (for testing), defaults to current time
  static MealReminderMessage createCurrentMealMessage([DateTime? dateTime]) {
    // Determine the meal type based on time of day
    final time = dateTime ?? DateTime.now();
    final hour = time.hour;

    // 5-10 AM: Breakfast, 11 AM-3 PM: Lunch, 4-9 PM: Dinner
    if (hour >= 5 && hour < 11) {
      return BreakfastReminderMessage();
    } else if (hour >= 11 && hour < 16) {
      return LunchReminderMessage();
    } else {
      return DinnerReminderMessage();
    }
  }
}
