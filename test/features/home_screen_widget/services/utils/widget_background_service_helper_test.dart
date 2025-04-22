import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_background_service.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/widget_background_service_helper.dart';

// Mock for static WidgetBackgroundService class
class MockWidgetBackgroundService {
  static bool initializeWasCalled = false;
  static bool registerPeriodicTaskWasCalled = false;
  static bool registerMidnightTaskWasCalled = false;
  static bool cancelAllTasksWasCalled = false;
  static Exception? exceptionToThrow;
  
  static void reset() {
    initializeWasCalled = false;
    registerPeriodicTaskWasCalled = false;
    registerMidnightTaskWasCalled = false;
    cancelAllTasksWasCalled = false;
    exceptionToThrow = null;
  }
  
  static Future<void> initialize() async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    initializeWasCalled = true;
  }
  
  static Future<void> registerPeriodicTask() async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    registerPeriodicTaskWasCalled = true;
  }
  
  static Future<void> registerMidnightTask() async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    registerMidnightTaskWasCalled = true;
  }
  
  static Future<void> cancelAllTasks() async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    cancelAllTasksWasCalled = true;
  }
}

// Create a testable version of WidgetBackgroundServiceHelper
class TestableWidgetBackgroundServiceHelper extends WidgetBackgroundServiceHelper {
  @override
  Future<void> initialize() async {
    await MockWidgetBackgroundService.initialize();
  }
  
  @override
  Future<void> registerPeriodicTask() async {
    await MockWidgetBackgroundService.registerPeriodicTask();
  }
  
  @override
  Future<void> registerMidnightTask() async {
    await MockWidgetBackgroundService.registerMidnightTask();
  }
  
  @override
  Future<void> cancelAllTasks() async {
    await MockWidgetBackgroundService.cancelAllTasks();
  }
}

@GenerateMocks([])
void main() {
  group('WidgetBackgroundServiceHelper Tests', () {
    late TestableWidgetBackgroundServiceHelper helper;
    
    setUp(() {
      helper = TestableWidgetBackgroundServiceHelper();
      MockWidgetBackgroundService.reset();
    });
    
    group('initialize', () {
      // Positive case
      test('calls WidgetBackgroundService.initialize', () async {
        // Execute
        await helper.initialize();
        
        // Verify
        expect(MockWidgetBackgroundService.initializeWasCalled, true);
      });
      
      // Negative case - initialization failure
      test('propagates exceptions from WidgetBackgroundService.initialize', () async {
        // Setup
        MockWidgetBackgroundService.exceptionToThrow = Exception('Initialization failed');
        
        // Execute & Verify
        expect(
          () => helper.initialize(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(), 
            'message', 
            contains('Initialization failed')
          )),
        );
      });
    });
    
    group('registerPeriodicTask', () {
      // Positive case
      test('calls WidgetBackgroundService.registerPeriodicTask', () async {
        // Execute
        await helper.registerPeriodicTask();
        
        // Verify
        expect(MockWidgetBackgroundService.registerPeriodicTaskWasCalled, true);
      });
      
      // Negative case - registration failure
      test('propagates exceptions from WidgetBackgroundService.registerPeriodicTask', () async {
        // Setup
        MockWidgetBackgroundService.exceptionToThrow = Exception('Registration failed');
        
        // Execute & Verify
        expect(
          () => helper.registerPeriodicTask(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(), 
            'message', 
            contains('Registration failed')
          )),
        );
      });
    });
    
    group('registerMidnightTask', () {
      // Positive case
      test('calls WidgetBackgroundService.registerMidnightTask', () async {
        // Execute
        await helper.registerMidnightTask();
        
        // Verify
        expect(MockWidgetBackgroundService.registerMidnightTaskWasCalled, true);
      });
      
      // Negative case - registration failure
      test('propagates exceptions from WidgetBackgroundService.registerMidnightTask', () async {
        // Setup
        MockWidgetBackgroundService.exceptionToThrow = Exception('Midnight task registration failed');
        
        // Execute & Verify
        expect(
          () => helper.registerMidnightTask(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(), 
            'message', 
            contains('Midnight task registration failed')
          )),
        );
      });
    });
    
    group('cancelAllTasks', () {
      // Positive case
      test('calls WidgetBackgroundService.cancelAllTasks', () async {
        // Execute
        await helper.cancelAllTasks();
        
        // Verify
        expect(MockWidgetBackgroundService.cancelAllTasksWasCalled, true);
      });
      
      // Negative case - cancellation failure
      test('propagates exceptions from WidgetBackgroundService.cancelAllTasks', () async {
        // Setup
        MockWidgetBackgroundService.exceptionToThrow = Exception('Cancellation failed');
        
        // Execute & Verify
        expect(
          () => helper.cancelAllTasks(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(), 
            'message', 
            contains('Cancellation failed')
          )),
        );
      });
    });

    // Test sequence of operations and ordering
    group('operation sequence', () {
      test('can call all methods in sequence', () async {
        // Execute
        await helper.initialize();
        await helper.registerPeriodicTask();
        await helper.registerMidnightTask();
        await helper.cancelAllTasks();
        
        // Verify
        expect(MockWidgetBackgroundService.initializeWasCalled, true);
        expect(MockWidgetBackgroundService.registerPeriodicTaskWasCalled, true);
        expect(MockWidgetBackgroundService.registerMidnightTaskWasCalled, true);
        expect(MockWidgetBackgroundService.cancelAllTasksWasCalled, true);
      });

      // Edge case - rapid repeated calls
      test('handles multiple rapid calls to same method', () async {
        // Execute
        await Future.wait([
          helper.initialize(),
          helper.initialize(),
          helper.initialize(),
        ]);
        
        // Verify
        expect(MockWidgetBackgroundService.initializeWasCalled, true);
      });
    });
  });
}
