import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';

void main() {
  group('HomeScreenWidgetException Tests', () {
    test('toString returns formatted message', () {
      // Arrange
      const message = 'Test exception message';
      final exception = HomeScreenWidgetException(message);
      
      // Assert
      expect(exception.toString(), 'HomeScreenWidgetException: $message');
    });
  });

  group('WidgetCallbackRegistrationException Tests', () {
    test('inherits from HomeScreenWidgetException', () {
      // Arrange
      const message = 'Failed to register callback';
      final exception = WidgetCallbackRegistrationException(message);
      
      // Assert
      expect(exception, isA<HomeScreenWidgetException>());
      expect(exception.message, message);
      expect(exception.toString(), 'HomeScreenWidgetException: $message');
    });
  });

  group('WidgetTimerSetupException Tests', () {
    test('inherits from HomeScreenWidgetException', () {
      // Arrange
      const message = 'Failed to setup timer';
      final exception = WidgetTimerSetupException(message);
      
      // Assert
      expect(exception, isA<HomeScreenWidgetException>());
      expect(exception.message, message);
      expect(exception.toString(), 'HomeScreenWidgetException: $message');
    });
  });

  group('WidgetUpdateException Tests', () {
    test('inherits from HomeScreenWidgetException', () {
      // Arrange
      const message = 'Failed to update widget';
      final exception = WidgetUpdateException(message);
      
      // Assert
      expect(exception, isA<HomeScreenWidgetException>());
      expect(exception.message, message);
      expect(exception.toString(), 'HomeScreenWidgetException: $message');
    });
  });

  group('HealthMetricsNotFoundException Tests', () {
    test('constructs message with user ID', () {
      // Arrange
      const userId = 'user123';
      final exception = HealthMetricsNotFoundException(userId);
      
      // Assert
      expect(exception, isA<HomeScreenWidgetException>());
      expect(exception.userId, userId);
      expect(exception.message, 'Health metrics not found for user: $userId');
      expect(exception.toString(), 'HomeScreenWidgetException: Health metrics not found for user: $userId');
    });
    
    // Edge case - empty user ID
    test('handles empty user ID', () {
      // Arrange
      const userId = '';
      final exception = HealthMetricsNotFoundException(userId);
      
      // Assert
      expect(exception.userId, userId);
      expect(exception.message, 'Health metrics not found for user: ');
    });
  });

  group('CaloricRequirementCalculationException Tests', () {
    test('inherits from HomeScreenWidgetException', () {
      // Arrange
      const message = 'Failed to calculate caloric requirement';
      final exception = CaloricRequirementCalculationException(message);
      
      // Assert
      expect(exception, isA<HomeScreenWidgetException>());
      expect(exception.message, message);
      expect(exception.toString(), 'HomeScreenWidgetException: $message');
    });
  });

  group('WidgetCleanupException Tests', () {
    test('inherits from HomeScreenWidgetException', () {
      // Arrange
      const message = 'Failed to cleanup widget';
      final exception = WidgetCleanupException(message);
      
      // Assert
      expect(exception, isA<HomeScreenWidgetException>());
      expect(exception.message, message);
      expect(exception.toString(), 'HomeScreenWidgetException: $message');
    });
  });

  group('WidgetInitializationException Tests', () {
    test('inherits from HomeScreenWidgetException', () {
      // Arrange
      const message = 'Failed to initialize widget';
      final exception = WidgetInitializationException(message);
      
      // Assert
      expect(exception, isA<HomeScreenWidgetException>());
      expect(exception.message, message);
      expect(exception.toString(), 'HomeScreenWidgetException: $message');
    });
  });
  
  // Edge cases for all exceptions
  group('Exception Edge Cases', () {
    test('handles very long message', () {
      final veryLongMessage = 'A' * 1000; // 1000 character message
      final exception = HomeScreenWidgetException(veryLongMessage);
      
      expect(exception.message.length, 1000);
      expect(exception.toString().length, 1000 + 'HomeScreenWidgetException: '.length);
    });
    
    test('handles special characters in message', () {
      const specialMessage = 'Message with !@#\$%^&*()_+{}:"<>?';
      final exception = HomeScreenWidgetException(specialMessage);
      
      expect(exception.message, specialMessage);
    });
    
    test('handles multi-line message', () {
      const multiLineMessage = 'Line 1\nLine 2\nLine 3';
      final exception = HomeScreenWidgetException(multiLineMessage);
      
      expect(exception.message, multiLineMessage);
    });
    
    test('handles empty message', () {
      const emptyMessage = '';
      final exception = HomeScreenWidgetException(emptyMessage);
      
      expect(exception.message, emptyMessage);
      expect(exception.toString(), 'HomeScreenWidgetException: ');
    });
    
    test('handles null-like strings in message', () {
      const nullString = 'null';
      final exception = HomeScreenWidgetException(nullString);
      
      expect(exception.message, nullString);
      expect(exception.toString(), 'HomeScreenWidgetException: null');
    });
  });
  
  group('Exception Equality Tests', () {
    test('two exceptions with same message are not equal', () {
      // Arrange
      const message = 'Same error message';
      final exception1 = HomeScreenWidgetException(message);
      final exception2 = HomeScreenWidgetException(message);
      
      // Assert - in Dart, two instances are different objects even with same properties
      expect(identical(exception1, exception2), isFalse);
      expect(exception1.message, exception2.message);
    });
    
    test('exception can be used as a rethrown exception', () {
      // Arrange
      const originalMessage = 'Original error';
      final originalException = HomeScreenWidgetException(originalMessage);
      late HomeScreenWidgetException caughtException;
      
      // Act - simulate catching and rethrowing
      try {
        throw originalException;
      } catch (e) {
        caughtException = e as HomeScreenWidgetException;
      }
      
      // Assert
      expect(identical(originalException, caughtException), isTrue);
      expect(caughtException.message, originalMessage);
    });
  });
  
  // Tambahan test case untuk exception chaining
  group('Exception Chaining Tests', () {
    test('can create exception with nested exception info', () {
      // Arrange
      final innerException = Exception('Inner error');
      final outerMessage = 'Outer error: ${innerException.toString()}';
      final exception = HomeScreenWidgetException(outerMessage);
      
      // Assert
      expect(exception.message, contains('Inner error'));
      expect(exception.toString(), contains('Inner error'));
    });
  });
}
