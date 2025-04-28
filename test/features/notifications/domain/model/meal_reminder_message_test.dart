// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/model/meal_reminder_message.dart';
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';

// Project imports:




void main() {
  group('MealReminderMessage Implementations', () {
    test('BreakfastReminderMessage properties have correct values', () {
      final message = BreakfastReminderMessage();
      
      expect(message.title, 'Time for Breakfast! 🍳');
      expect(message.body, "Start your day with energy! Don't forget to have a healthy breakfast.");
      expect(message.mealType, NotificationConstants.breakfast);
    });
    
    test('LunchReminderMessage properties have correct values', () {
      final message = LunchReminderMessage();
      
      expect(message.title, 'Time for Lunch! 🍱');
      expect(message.body, 'Take a break and recharge with a nutritious lunch.');
      expect(message.mealType, NotificationConstants.lunch);
    });
    
    test('DinnerReminderMessage properties have correct values', () {
      final message = DinnerReminderMessage();
      
      expect(message.title, 'Time for Dinner! 🍽️');
      expect(message.body, 'Complete your daily nutrition with a balanced dinner.');
      expect(message.mealType, NotificationConstants.dinner);
    });
  });
  
  group('MealReminderMessageFactory', () {
    test('createMessage returns correct instance for breakfast', () {
      final message = MealReminderMessageFactory.createMessage(NotificationConstants.breakfast);
      
      expect(message, isA<BreakfastReminderMessage>());
      expect(message.mealType, NotificationConstants.breakfast);
    });
    
    test('createMessage returns correct instance for lunch', () {
      final message = MealReminderMessageFactory.createMessage(NotificationConstants.lunch);
      
      expect(message, isA<LunchReminderMessage>());
      expect(message.mealType, NotificationConstants.lunch);
    });
    
    test('createMessage returns correct instance for dinner', () {
      final message = MealReminderMessageFactory.createMessage(NotificationConstants.dinner);
      
      expect(message, isA<DinnerReminderMessage>());
      expect(message.mealType, NotificationConstants.dinner);
    });
    
    test('createMessage throws ArgumentError for invalid meal type', () {
      expect(
        () => MealReminderMessageFactory.createMessage('invalid_meal_type'),
        throwsArgumentError,
      );
    });
    
    test('createMessage is case-insensitive', () {
      expect(
        MealReminderMessageFactory.createMessage('BREAKFAST'),
        isA<BreakfastReminderMessage>(),
      );
      
      expect(
        MealReminderMessageFactory.createMessage('Lunch'),
        isA<LunchReminderMessage>(),
      );
      
      expect(
        MealReminderMessageFactory.createMessage('dInNeR'),
        isA<DinnerReminderMessage>(),
      );
    });
  });
  
  group('MealReminderMessageFactory.createCurrentMealMessage', () {
    test('returns appropriate message based on time of day', () {
      // Test breakfast time (8:00 AM)
      final breakfastTime = DateTime(2025, 4, 26, 8, 0);
      final breakfastMessage = MealReminderMessageFactory.createCurrentMealMessage(breakfastTime);
      expect(breakfastMessage, isA<BreakfastReminderMessage>());
      expect(breakfastMessage.mealType, NotificationConstants.breakfast);
      
      // Test lunch time (1:00 PM)
      final lunchTime = DateTime(2025, 4, 26, 13, 0);
      final lunchMessage = MealReminderMessageFactory.createCurrentMealMessage(lunchTime);
      expect(lunchMessage, isA<LunchReminderMessage>());
      expect(lunchMessage.mealType, NotificationConstants.lunch);
      
      // Test dinner time (7:00 PM)
      final dinnerTime = DateTime(2025, 4, 26, 19, 0);
      final dinnerMessage = MealReminderMessageFactory.createCurrentMealMessage(dinnerTime);
      expect(dinnerMessage, isA<DinnerReminderMessage>());
      expect(dinnerMessage.mealType, NotificationConstants.dinner);
      
      // Test late night (2:00 AM) - should default to dinner
      final lateNightTime = DateTime(2025, 4, 26, 2, 0);
      final lateNightMessage = MealReminderMessageFactory.createCurrentMealMessage(lateNightTime);
      expect(lateNightMessage, isA<DinnerReminderMessage>());
      expect(lateNightMessage.mealType, NotificationConstants.dinner);
    });
    
    test('edge cases for time ranges', () {
      // Edge of breakfast range (5:00 AM)
      final earlyBreakfastTime = DateTime(2025, 4, 26, 5, 0);
      expect(MealReminderMessageFactory.createCurrentMealMessage(earlyBreakfastTime), 
             isA<BreakfastReminderMessage>());
      
      // Edge of breakfast/lunch transition (10:59 AM)
      final lateBreakfastTime = DateTime(2025, 4, 26, 10, 59);
      expect(MealReminderMessageFactory.createCurrentMealMessage(lateBreakfastTime), 
             isA<BreakfastReminderMessage>());
      
      // Edge of lunch range (11:00 AM)
      final earlyLunchTime = DateTime(2025, 4, 26, 11, 0);
      expect(MealReminderMessageFactory.createCurrentMealMessage(earlyLunchTime), 
             isA<LunchReminderMessage>());
      
      // Edge of lunch/dinner transition (3:59 PM)
      final lateLunchTime = DateTime(2025, 4, 26, 15, 59);
      expect(MealReminderMessageFactory.createCurrentMealMessage(lateLunchTime), 
             isA<LunchReminderMessage>());
      
      // Edge of dinner range (4:00 PM)
      final earlyDinnerTime = DateTime(2025, 4, 26, 16, 0);
      expect(MealReminderMessageFactory.createCurrentMealMessage(earlyDinnerTime), 
             isA<DinnerReminderMessage>());
    });
  });
  
  group('Integration with NotificationModel', () {
    test('MealReminderMessage can be used with NotificationModel', () {
      final message = MealReminderMessageFactory.createMessage(NotificationConstants.breakfast);
      final scheduledTime = DateTime(2025, 4, 26, 8, 0);
      
      // Create a notification model with the meal reminder message
      final notificationModel = NotificationModel(
        title: message.title,
        body: message.body,
        payload: NotificationConstants.mealReminderPayload,
        scheduledTime: scheduledTime,
      );
      
      // Verify the created model has the expected properties
      expect(notificationModel.title, equals(message.title));
      expect(notificationModel.body, equals(message.body));
      expect(notificationModel.payload, equals(NotificationConstants.mealReminderPayload));
      expect(notificationModel.scheduledTime, equals(scheduledTime));
    });
  });
}
