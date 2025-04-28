// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/model/streak_message.dart';

void main() {
  group('StreakMessage', () {
    group('RegularStreakMessage', () {
      test('should have correct properties for streak < 7', () {
        final message = RegularStreakMessage(3);
        
        expect(message.streak, equals(3));
        expect(message.title, equals('3 Day Streak! 👏'));
        expect(message.body, equals('Keep up the good habit today!'));
      });
      
      test('should handle streak of 0', () {
        final message = RegularStreakMessage(0);
        
        expect(message.streak, equals(0));
        expect(message.title, equals('0 Day Streak! 👏'));
        expect(message.body, equals('Keep up the good habit today!'));
      });
      
      test('should handle boundary value of 6', () {
        final message = RegularStreakMessage(6);
        
        expect(message.streak, equals(6));
        expect(message.title, equals('6 Day Streak! 👏'));
      });
      
      test('should reflect the correct streak in the title', () {
        final message1 = RegularStreakMessage(1);
        final message5 = RegularStreakMessage(5);
        
        expect(message1.title, equals('1 Day Streak! 👏'));
        expect(message5.title, equals('5 Day Streak! 👏'));
      });
    });
    
    group('WeeklyStreakMessage', () {
      test('should have correct properties for streak >= 7 and < 30', () {
        final message = WeeklyStreakMessage(14);
        
        expect(message.streak, equals(14));
        expect(message.title, equals('7+ Day Streak! 🔥'));
        expect(message.body, contains('14 day streak'));
      });
      
      test('should handle boundary value of 7', () {
        final message = WeeklyStreakMessage(7);
        
        expect(message.streak, equals(7));
        expect(message.title, equals('7+ Day Streak! 🔥'));
        expect(message.body, contains('7 day streak'));
      });
      
      test('should handle boundary value of 29', () {
        final message = WeeklyStreakMessage(29);
        
        expect(message.streak, equals(29));
        expect(message.title, equals('7+ Day Streak! 🔥'));
        expect(message.body, contains('29 day streak'));
      });
      
      test('should reflect the correct streak in the body', () {
        final message7 = WeeklyStreakMessage(7);
        final message21 = WeeklyStreakMessage(21);
        
        expect(message7.body, contains('7 day streak'));
        expect(message21.body, contains('21 day streak'));
      });
    });
    
    group('MonthlyStreakMessage', () {
      test('should have correct properties for streak >= 30 and < 100', () {
        final message = MonthlyStreakMessage(45);
        
        expect(message.streak, equals(45));
        expect(message.title, equals('30+ Day Streak! 🌟'));
        expect(message.body, contains('45 days'));
      });
      
      test('should handle boundary value of 30', () {
        final message = MonthlyStreakMessage(30);
        
        expect(message.streak, equals(30));
        expect(message.title, equals('30+ Day Streak! 🌟'));
        expect(message.body, contains('30 days'));
      });
      
      test('should handle boundary value of 99', () {
        final message = MonthlyStreakMessage(99);
        
        expect(message.streak, equals(99));
        expect(message.title, equals('30+ Day Streak! 🌟'));
        expect(message.body, contains('99 days'));
      });
      
      test('should reflect the correct streak in the body', () {
        final message30 = MonthlyStreakMessage(30);
        final message75 = MonthlyStreakMessage(75);
        
        expect(message30.body, contains('30 days'));
        expect(message75.body, contains('75 days'));
      });
    });
    
    group('CenturyStreakMessage', () {
      test('should have correct properties for streak >= 100', () {
        final message = CenturyStreakMessage(120);
        
        expect(message.streak, equals(120));
        expect(message.title, equals('WOW! 100+ Day Streak! 🏆'));
        expect(message.body, contains('120 consecutive days'));
      });
      
      test('should handle boundary value of 100', () {
        final message = CenturyStreakMessage(100);
        
        expect(message.streak, equals(100));
        expect(message.title, equals('WOW! 100+ Day Streak! 🏆'));
        expect(message.body, contains('100 consecutive days'));
      });
      
      test('should handle very large streak values', () {
        final message = CenturyStreakMessage(1000);
        
        expect(message.streak, equals(1000));
        expect(message.title, equals('WOW! 100+ Day Streak! 🏆'));
        expect(message.body, contains('1000 consecutive days'));
      });
      
      test('should reflect the correct streak in the body', () {
        final message100 = CenturyStreakMessage(100);
        final message365 = CenturyStreakMessage(365);
        
        expect(message100.body, contains('100 consecutive days'));
        expect(message365.body, contains('365 consecutive days'));
      });
    });
    
    group('StreakMessageFactory', () {
      test('should create RegularStreakMessage for streak < 7', () {
        final message0 = StreakMessageFactory.createMessage(0);
        final message1 = StreakMessageFactory.createMessage(1);
        final message6 = StreakMessageFactory.createMessage(6);
        
        expect(message0, isA<RegularStreakMessage>());
        expect(message1, isA<RegularStreakMessage>());
        expect(message6, isA<RegularStreakMessage>());
        
        expect(message0.streak, equals(0));
        expect(message1.streak, equals(1));
        expect(message6.streak, equals(6));
      });
      
      test('should create WeeklyStreakMessage for streak >= 7 and < 30', () {
        final message7 = StreakMessageFactory.createMessage(7);
        final message15 = StreakMessageFactory.createMessage(15);
        final message29 = StreakMessageFactory.createMessage(29);
        
        expect(message7, isA<WeeklyStreakMessage>());
        expect(message15, isA<WeeklyStreakMessage>());
        expect(message29, isA<WeeklyStreakMessage>());
        
        expect(message7.streak, equals(7));
        expect(message15.streak, equals(15));
        expect(message29.streak, equals(29));
      });
      
      test('should create MonthlyStreakMessage for streak >= 30 and < 100', () {
        final message30 = StreakMessageFactory.createMessage(30);
        final message50 = StreakMessageFactory.createMessage(50);
        final message99 = StreakMessageFactory.createMessage(99);
        
        expect(message30, isA<MonthlyStreakMessage>());
        expect(message50, isA<MonthlyStreakMessage>());
        expect(message99, isA<MonthlyStreakMessage>());
        
        expect(message30.streak, equals(30));
        expect(message50.streak, equals(50));
        expect(message99.streak, equals(99));
      });
      
      test('should create CenturyStreakMessage for streak >= 100', () {
        final message100 = StreakMessageFactory.createMessage(100);
        final message200 = StreakMessageFactory.createMessage(200);
        final message365 = StreakMessageFactory.createMessage(365);
        
        expect(message100, isA<CenturyStreakMessage>());
        expect(message200, isA<CenturyStreakMessage>());
        expect(message365, isA<CenturyStreakMessage>());
        
        expect(message100.streak, equals(100));
        expect(message200.streak, equals(200));
        expect(message365.streak, equals(365));
      });
      
      test('should throw ArgumentError when streak is negative', () {
        expect(() => StreakMessageFactory.createMessage(-1), throwsArgumentError);
      });
      
      test('error message should be in English', () {
        try {
          StreakMessageFactory.createMessage(-5);
        } catch (e) {
          expect(e.toString(), contains('Streak must not be negative'));
        }
      });

      test('returns correct message type for streak count of 0', () {
        expect(StreakMessageFactory.createMessage(0), isA<RegularStreakMessage>());
      });
      
      test('should create message with correct properties at boundary values', () {
        // Test exact boundary values
        final message6 = StreakMessageFactory.createMessage(6);
        final message7 = StreakMessageFactory.createMessage(7);
        final message29 = StreakMessageFactory.createMessage(29);
        final message30 = StreakMessageFactory.createMessage(30);
        final message99 = StreakMessageFactory.createMessage(99);
        final message100 = StreakMessageFactory.createMessage(100);
        
        // Verify correct message types at boundaries
        expect(message6, isA<RegularStreakMessage>());
        expect(message7, isA<WeeklyStreakMessage>());
        expect(message29, isA<WeeklyStreakMessage>());
        expect(message30, isA<MonthlyStreakMessage>());
        expect(message99, isA<MonthlyStreakMessage>());
        expect(message100, isA<CenturyStreakMessage>());
        
        // Verify properties from parent classes are correctly set
        expect(message6.streak, equals(6));
        expect(message7.streak, equals(7));
        expect(message30.streak, equals(30));
        expect(message100.streak, equals(100));
      });
      
      test('should handle edge case of MAX_INT', () {
        // Test with maximum integer value
        final int veryLargeStreak = 2147483647; // MAX_INT
        final message = StreakMessageFactory.createMessage(veryLargeStreak);
        
        expect(message, isA<CenturyStreakMessage>());
        expect(message.streak, equals(veryLargeStreak));
        expect(message.body, contains(veryLargeStreak.toString()));
      });
    });
    
    group('Object behavior', () {
      test('different instances with same streak value should have same properties', () {
        final message1 = RegularStreakMessage(5);
        final message2 = RegularStreakMessage(5);
        
        expect(message1.title, equals(message2.title));
        expect(message1.body, equals(message2.body));
        expect(message1.streak, equals(message2.streak));
      });
      
      test('streak value should be immutable after creation', () {
        final message = RegularStreakMessage(3);
        expect(message.streak, equals(3));
        
        // Verify that streak cannot be modified (compile-time check for this test)
        // message._streak = 5; // This should not compile
        
        // Create a new instance to change streak
        final newMessage = RegularStreakMessage(5);
        expect(newMessage.streak, equals(5));
      });
    });

    group('StreakMessage integration', () {
      test('should have consistent streak values across factory and concrete implementations', () {
        for (int streak in [0, 3, 7, 15, 30, 60, 100, 365]) {
          final message = StreakMessageFactory.createMessage(streak);
          expect(message.streak, equals(streak));
        }
      });
      
      test('should respect polymorphism principles', () {
        final List<StreakMessage> messages = [
          StreakMessageFactory.createMessage(3),
          StreakMessageFactory.createMessage(10),
          StreakMessageFactory.createMessage(45),
          StreakMessageFactory.createMessage(120),
        ];
        
        // All should have non-empty properties regardless of concrete type
        for (final message in messages) {
          expect(message.title, isNotEmpty);
          expect(message.body, isNotEmpty);
          expect(message.streak, isNonNegative);
        }
      });
      
      test('content verification - messages should contain appropriate emoji', () {
        final regularMessage = StreakMessageFactory.createMessage(3);
        final weeklyMessage = StreakMessageFactory.createMessage(14);
        final monthlyMessage = StreakMessageFactory.createMessage(45);
        final centuryMessage = StreakMessageFactory.createMessage(120);
        
        expect(regularMessage.title, contains('👏'));
        expect(weeklyMessage.title, contains('🔥'));
        expect(monthlyMessage.title, contains('🌟'));
        expect(centuryMessage.title, contains('🏆'));
      });
      
      test('content verification - messages should reflect appropriate milestones', () {
        final regularMessage = StreakMessageFactory.createMessage(3);
        final weeklyMessage = StreakMessageFactory.createMessage(14);
        final monthlyMessage = StreakMessageFactory.createMessage(45);
        final centuryMessage = StreakMessageFactory.createMessage(120);
        
        expect(regularMessage.title, startsWith('3 Day'));
        expect(weeklyMessage.title, startsWith('7+ Day'));
        expect(monthlyMessage.title, startsWith('30+ Day'));
        expect(centuryMessage.title, contains('100+ Day'));
      });
    });
  });
}
