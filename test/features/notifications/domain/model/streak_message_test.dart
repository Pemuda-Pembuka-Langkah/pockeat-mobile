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
        expect(message.title, equals('Streak 3 Hari! 👏'));
        expect(message.body, equals('Teruskan kebiasaan baikmu hari ini!'));
      });
      
      test('should reflect the correct streak in the title', () {
        final message1 = RegularStreakMessage(1);
        final message5 = RegularStreakMessage(5);
        
        expect(message1.title, equals('Streak 1 Hari! 👏'));
        expect(message5.title, equals('Streak 5 Hari! 👏'));
      });
    });
    
    group('WeeklyStreakMessage', () {
      test('should have correct properties for streak >= 7 and < 30', () {
        final message = WeeklyStreakMessage(14);
        
        expect(message.streak, equals(14));
        expect(message.title, equals('Streak 7+ Hari! 🔥'));
        expect(message.body, contains('14 hari'));
      });
      
      test('should reflect the correct streak in the body', () {
        final message7 = WeeklyStreakMessage(7);
        final message21 = WeeklyStreakMessage(21);
        
        expect(message7.body, contains('7 hari'));
        expect(message21.body, contains('21 hari'));
      });
    });
    
    group('MonthlyStreakMessage', () {
      test('should have correct properties for streak >= 30 and < 100', () {
        final message = MonthlyStreakMessage(45);
        
        expect(message.streak, equals(45));
        expect(message.title, equals('Streak 30+ Hari! 🌟'));
        expect(message.body, contains('45 hari'));
      });
      
      test('should reflect the correct streak in the body', () {
        final message30 = MonthlyStreakMessage(30);
        final message75 = MonthlyStreakMessage(75);
        
        expect(message30.body, contains('30 hari'));
        expect(message75.body, contains('75 hari'));
      });
    });
    
    group('CenturyStreakMessage', () {
      test('should have correct properties for streak >= 100', () {
        final message = CenturyStreakMessage(120);
        
        expect(message.streak, equals(120));
        expect(message.title, equals('WOW! 100+ Hari Streak! 🏆'));
        expect(message.body, contains('120 hari'));
      });
      
      test('should reflect the correct streak in the body', () {
        final message100 = CenturyStreakMessage(100);
        final message365 = CenturyStreakMessage(365);
        
        expect(message100.body, contains('100 hari'));
        expect(message365.body, contains('365 hari'));
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
      
      test('should throw ArgumentError for negative streak', () {
        expect(() => StreakMessageFactory.createMessage(-1), throwsArgumentError);
        expect(() => StreakMessageFactory.createMessage(-100), throwsArgumentError);
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
    });
  });
}
