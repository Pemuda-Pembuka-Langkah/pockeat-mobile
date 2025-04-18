import 'dart:async';

import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/permission_helper.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/widget_background_service_helper.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/detailed_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/food_tracking_client_controller_impl.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/simple_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_event_type.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';

// Mock classes for dependencies
@GenerateMocks([
  LoginService,
  CaloricRequirementService,
  HealthMetricsRepository,
  HealthMetricsCheckService,
  SimpleFoodTrackingController,
  DetailedFoodTrackingController,
  CalorieCalculationStrategy,
  NavigatorState,
  PermissionHelperInterface,
  WidgetBackgroundServiceHelperInterface,
])
import 'food_tracking_client_controller_test.mocks.dart';

// We'll use the MockWidgetBackgroundServiceHelperInterface instead

void main() {
  // Initialize the binding
  TestWidgetsFlutterBinding.ensureInitialized();

  late FoodTrackingClientControllerImpl controller;
  late MockLoginService mockLoginService;
  late MockCaloricRequirementService mockCaloricRequirementService;
  late MockHealthMetricsRepository mockHealthMetricsRepository;
  late MockHealthMetricsCheckService mockHealthMetricsCheckService;
  late MockSimpleFoodTrackingController mockSimpleController;
  late MockDetailedFoodTrackingController mockDetailedController;
  late MockCalorieCalculationStrategy mockCalorieCalculationStrategy;
  late MockPermissionHelperInterface mockPermissionHelper;
  late MockWidgetBackgroundServiceHelperInterface mockBackgroundServiceHelper;
  late GlobalKey<NavigatorState> navigatorKey;

  // Test user ID
  final String testUserId = 'test-user-123';
  final testUser = UserModel(
    uid: testUserId,
    displayName: 'Test User',
    email: 'test@example.com',
    photoURL: 'https://example.com/photo.jpg',
    emailVerified: true,
    createdAt: DateTime(2025, 4, 1),
  );

  // We'll use the mockPermissionHelper instead of trying to mock the Permission class

  setUp(() {
    mockLoginService = MockLoginService();
    mockCaloricRequirementService = MockCaloricRequirementService();
    mockHealthMetricsRepository = MockHealthMetricsRepository();
    mockHealthMetricsCheckService = MockHealthMetricsCheckService();
    mockSimpleController = MockSimpleFoodTrackingController();
    mockDetailedController = MockDetailedFoodTrackingController();
    mockCalorieCalculationStrategy = MockCalorieCalculationStrategy();
    mockPermissionHelper = MockPermissionHelperInterface();
    mockBackgroundServiceHelper = MockWidgetBackgroundServiceHelperInterface();
    navigatorKey = GlobalKey<NavigatorState>();

    controller = FoodTrackingClientControllerImpl(
      loginService: mockLoginService,
      caloricRequirementService: mockCaloricRequirementService,
      healthMetricsRepository: mockHealthMetricsRepository,
      healthMetricsCheckService: mockHealthMetricsCheckService,
      simpleController: mockSimpleController,
      detailedController: mockDetailedController,
      calorieCalculationStrategy: mockCalorieCalculationStrategy,
      permissionHelper: mockPermissionHelper,
      backgroundServiceHelper: mockBackgroundServiceHelper,
    );

    // Setup default mock behaviors
    when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);
    when(mockSimpleController.initialize(
            navigatorKey: anyNamed('navigatorKey')))
        .thenAnswer((_) async {});
    when(mockDetailedController.initialize(
            navigatorKey: anyNamed('navigatorKey')))
        .thenAnswer((_) async {});
    when(mockSimpleController.registerWidgetClickCallback())
        .thenAnswer((_) async {});
    when(mockDetailedController.registerWidgetClickCallback())
        .thenAnswer((_) async {});
    when(mockSimpleController.setRefreshCallback(any)).thenReturn(null);
    when(mockDetailedController.setRefreshCallback(any)).thenReturn(null);

    // Setup permission helper mocks
    when(mockPermissionHelper.requestNotificationPermission())
        .thenAnswer((_) async => PermissionStatus.granted);
    when(mockPermissionHelper.requestBatteryOptimizationExemption())
        .thenAnswer((_) async => PermissionStatus.granted);
    when(mockPermissionHelper.isBatteryOptimizationExemptionGranted())
        .thenAnswer((_) async => true);

    // Setup background service helper mocks
    when(mockBackgroundServiceHelper.initialize())
        .thenAnswer((_) async => null);
    when(mockBackgroundServiceHelper.registerPeriodicTask())
        .thenAnswer((_) async => null);
    when(mockBackgroundServiceHelper.registerMidnightTask())
        .thenAnswer((_) async => null);
    when(mockBackgroundServiceHelper.cancelAllTasks())
        .thenAnswer((_) async => null);
  });

  group('FoodTrackingClientController - initialize', () {
    test('should initialize successfully', () async {
      // Act
      await controller.initialize(navigatorKey);

      // Assert
      verify(mockSimpleController.initialize(navigatorKey: navigatorKey))
          .called(1);
      verify(mockDetailedController.initialize(navigatorKey: navigatorKey))
          .called(1);
      verify(mockSimpleController.registerWidgetClickCallback()).called(1);
      verify(mockDetailedController.registerWidgetClickCallback()).called(1);
      verify(mockLoginService.getCurrentUser()).called(1);
    });

    test('should update widgets if user already logged in', () async {
      // Arrange
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, any))
          .thenAnswer((_) async => 2500);
      when(mockSimpleController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async {});
      when(mockDetailedController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async {});

      // Act
      await controller.initialize(navigatorKey);

      // Assert
      verify(mockLoginService.getCurrentUser()).called(1);
      verify(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, testUserId))
          .called(1);
      verify(mockSimpleController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(1);
      verify(mockDetailedController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(1);
    });

    test(
        'should throw WidgetInitializationException if simple controller initialization fails',
        () async {
      // Arrange
      when(mockSimpleController.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenThrow(Exception('Failed to initialize'));

      // Act & Assert
      expect(
        () => controller.initialize(navigatorKey),
        throwsA(isA<WidgetInitializationException>()),
      );
    });

    test(
        'should throw WidgetInitializationException if detailed controller initialization fails',
        () async {
      // Arrange
      when(mockDetailedController.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenThrow(Exception('Failed to initialize'));

      // Act & Assert
      expect(
        () => controller.initialize(navigatorKey),
        throwsA(isA<WidgetInitializationException>()),
      );
    });

    test(
        'should throw WidgetInitializationException if callback registration fails',
        () async {
      // Arrange
      when(mockSimpleController.registerWidgetClickCallback())
          .thenThrow(Exception('Failed to register callback'));

      // Act & Assert
      expect(
        () => controller.initialize(navigatorKey),
        throwsA(isA<WidgetInitializationException>()),
      );
    });
  });

  group('FoodTrackingClientController - processUserStatusChange', () {
    test(
        'should update widgets with correct target calories for logged in user',
        () async {
      // Arrange
      when(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, any))
          .thenAnswer((_) async => 2500);
      when(mockSimpleController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async {});
      when(mockDetailedController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async {});

      // Act
      await controller.processUserStatusChange(testUser);

      // Assert
      verify(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, testUserId))
          .called(1);
      verify(mockSimpleController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(1);
      verify(mockDetailedController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(1);
    });

    test('should update widgets with null user when logged out', () async {
      // Arrange
      when(mockSimpleController.updateWidgetData(null))
          .thenAnswer((_) async => null);
      when(mockDetailedController.updateWidgetData(null))
          .thenAnswer((_) async => null);
      when(mockSimpleController.cleanupData()).thenAnswer((_) async => null);
      when(mockDetailedController.cleanupData()).thenAnswer((_) async => null);

      // Act
      await controller.processUserStatusChange(null);

      // Assert
      verifyNever(mockCalorieCalculationStrategy.calculateTargetCalories(
          any, any, any));
      verify(mockSimpleController.cleanupData())
          .called(1); // Controller cleans up data for null user
      verify(mockDetailedController.cleanupData())
          .called(1); // Controller cleans up data for null user
    });

    test(
        'should throw WidgetUpdateException if calculating target calories fails',
        () async {
      // Arrange
      when(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, any))
          .thenThrow(Exception('Failed to calculate target calories'));

      // Act & Assert
      expect(
        () => controller.processUserStatusChange(testUser),
        throwsA(isA<WidgetUpdateException>()),
      );
    });

    test('should throw WidgetUpdateException if updating widgets fails',
        () async {
      // Arrange
      when(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, any))
          .thenAnswer((_) async => 2500);
      when(mockSimpleController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenThrow(Exception('Failed to update widget'));

      // Act & Assert
      expect(
        () => controller.processUserStatusChange(testUser),
        throwsA(isA<WidgetUpdateException>()),
      );
    });
  });

  group('FoodTrackingClientController - processPeriodicUpdate', () {
    test('should call processUserStatusChange with current user', () async {
      // Arrange - setup a current user by initializing with one
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, any))
          .thenAnswer((_) async => 2500);
      when(mockSimpleController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async {});
      when(mockDetailedController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async {});

      // First initialize to set the currentUser
      await controller.initialize(navigatorKey);

      // Reset invocation counters after initialization
      clearInteractions(mockCalorieCalculationStrategy);
      clearInteractions(mockSimpleController);
      clearInteractions(mockDetailedController);

      // Act
      await controller.processPeriodicUpdate();

      // Assert
      verify(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, testUserId))
          .called(1);
      verify(mockSimpleController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(1);
      verify(mockDetailedController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(1);
    });

    test('should do nothing if no current user', () async {
      // Act
      await controller.processPeriodicUpdate();

      // Assert
      verifyNever(mockCalorieCalculationStrategy.calculateTargetCalories(
          any, any, any));
      verifyNever(mockSimpleController.updateWidgetData(any));
      verifyNever(mockDetailedController.updateWidgetData(any));
    });

    test('should throw WidgetUpdateException if periodic update fails',
        () async {
      // For this test, let's create a fresh instance of the controller with all mocks properly set up
      // Create a new instance to avoid any issues with previous test state
      final testController = FoodTrackingClientControllerImpl(
        loginService: mockLoginService,
        caloricRequirementService: mockCaloricRequirementService,
        healthMetricsRepository: mockHealthMetricsRepository,
        healthMetricsCheckService: mockHealthMetricsCheckService,
        simpleController: mockSimpleController,
        detailedController: mockDetailedController,
        calorieCalculationStrategy: mockCalorieCalculationStrategy,
        permissionHelper: mockPermissionHelper,
        backgroundServiceHelper: mockBackgroundServiceHelper,
      );
      
      // Set up all mocks needed for successful initialization
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockSimpleController.initialize(navigatorKey: anyNamed('navigatorKey'))).thenAnswer((_) async => null);
      when(mockDetailedController.initialize(navigatorKey: anyNamed('navigatorKey'))).thenAnswer((_) async => null);
      when(mockSimpleController.registerWidgetClickCallback()).thenAnswer((_) async => null);
      when(mockDetailedController.registerWidgetClickCallback()).thenAnswer((_) async => null);
      when(mockSimpleController.setRefreshCallback(any)).thenReturn(null);
      when(mockDetailedController.setRefreshCallback(any)).thenReturn(null);
      when(mockPermissionHelper.requestNotificationPermission()).thenAnswer((_) async => PermissionStatus.granted);
      when(mockPermissionHelper.isBatteryOptimizationExemptionGranted()).thenAnswer((_) async => true);
      when(mockBackgroundServiceHelper.initialize()).thenAnswer((_) async => null);
      when(mockBackgroundServiceHelper.registerPeriodicTask()).thenAnswer((_) async => null);
      when(mockBackgroundServiceHelper.registerMidnightTask()).thenAnswer((_) async => null);
      
      // Mock for the initial update during initialization
      when(mockCalorieCalculationStrategy.calculateTargetCalories(any, any, any))
          .thenAnswer((_) async => 2500);
      when(mockSimpleController.updateWidgetData(any, targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async => null);
      when(mockDetailedController.updateWidgetData(any, targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async => null);

      // Initialize the controller with our test navigator key
      await testController.initialize(navigatorKey);
      
      // Now, make the calculation strategy throw for the periodic update
      clearInteractions(mockCalorieCalculationStrategy);
      when(mockCalorieCalculationStrategy.calculateTargetCalories(any, any, any))
          .thenThrow(Exception('Failed to calculate target calories'));

      // Act & Assert - now that the controller has a currentUser set, this should trigger the exception
      expect(
        () => testController.processPeriodicUpdate(),
        throwsA(isA<WidgetUpdateException>()),
      );
    });
  });

  group('FoodTrackingClientController - cleanup', () {
    test('should clean up data successfully', () async {
      // Arrange
      when(mockSimpleController.cleanupData()).thenAnswer((_) async {});
      when(mockDetailedController.cleanupData()).thenAnswer((_) async {});

      // Act
      await controller.cleanup();

      // Assert
      verify(mockSimpleController.cleanupData()).called(1);
      verify(mockDetailedController.cleanupData()).called(1);
    });

    test('should throw WidgetCleanupException if cleanup fails', () async {
      // Arrange
      when(mockSimpleController.cleanupData())
          .thenThrow(Exception('Failed to clean up data'));

      // Act & Assert
      expect(
        () => controller.cleanup(),
        throwsA(isA<WidgetCleanupException>()),
      );
    });
  });

  group('FoodTrackingClientController - stopPeriodicUpdates', () {
    test('should stop periodic updates successfully', () async {
      // Act
      await controller.stopPeriodicUpdates();

      // Note: difficult to verify Timer cancellation directly, so we'll just
      // make sure it doesn't throw any exceptions
    });
  });

  group('FoodTrackingClientController - edge cases', () {
    test('should handle rapid sequential initialization', () async {
      // Arrange - simulate a situation where initialize is called twice rapidly
      when(mockSimpleController.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async =>
              await Future.delayed(const Duration(milliseconds: 50)));
      when(mockDetailedController.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async =>
              await Future.delayed(const Duration(milliseconds: 50)));

      // Act - call initialize twice in quick succession
      final future1 = controller.initialize(navigatorKey);
      final future2 = controller.initialize(navigatorKey);

      // Wait for both to complete
      await Future.wait([future1, future2]);

      // Assert - should have called initialize on each controller twice
      verify(mockSimpleController.initialize(navigatorKey: navigatorKey))
          .called(2);
      verify(mockDetailedController.initialize(navigatorKey: navigatorKey))
          .called(2);
    });

    test('should handle multiple user status changes in quick succession',
        () async {
      // Arrange
      when(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, any))
          .thenAnswer((_) async => 2500);
      when(mockSimpleController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async =>
              await Future.delayed(const Duration(milliseconds: 50)));
      when(mockDetailedController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async =>
              await Future.delayed(const Duration(milliseconds: 50)));

      // Create a slightly different test user
      final testUser2 = UserModel(
        uid: 'test-user-456',
        displayName: 'Test User 2',
        email: 'test2@example.com',
        photoURL: 'https://example.com/photo2.jpg',
        emailVerified: true,
        createdAt: DateTime(2025, 4, 1),
      );

      // Act - call processUserStatusChange twice in quick succession with different users
      final future1 = controller.processUserStatusChange(testUser);
      final future2 = controller.processUserStatusChange(testUser2);

      // Wait for both to complete
      await Future.wait([future1, future2]);

      // Assert - should have called updateWidgetData with both users
      verify(mockSimpleController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(1);
      verify(mockSimpleController.updateWidgetData(testUser2,
              targetCalories: 2500))
          .called(1);
      verify(mockDetailedController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(1);
      verify(mockDetailedController.updateWidgetData(testUser2,
              targetCalories: 2500))
          .called(1);
    });

    test('should handle edge case with null dependencies', () async {
      // This is to verify that our implementation robustly handles any potential null errors

      // Arrange - create a controller with null dependencies (but use mocks for required ones)
      controller = FoodTrackingClientControllerImpl(
        loginService: mockLoginService,
        caloricRequirementService: mockCaloricRequirementService,
        healthMetricsRepository: mockHealthMetricsRepository,
        healthMetricsCheckService: mockHealthMetricsCheckService,
        simpleController: mockSimpleController,
        detailedController: mockDetailedController,
        calorieCalculationStrategy: null, // Explicitly test with null
        permissionHelper: mockPermissionHelper,
        backgroundServiceHelper: mockBackgroundServiceHelper,
      );

      // Act - should use DefaultCalorieCalculationStrategy if null
      await controller.initialize(navigatorKey);

      // Assert - should complete without exceptions
      verify(mockSimpleController.initialize(navigatorKey: navigatorKey))
          .called(1);
    });
  });

  group('Integration tests', () {
    test('should handle full lifecycle correctly', () async {
      // Arrange
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);
      when(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, any))
          .thenAnswer((_) async => 2500);
      when(mockSimpleController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async => null);
      when(mockDetailedController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async => null);
      when(mockSimpleController.cleanupData()).thenAnswer((_) async => null);
      when(mockDetailedController.cleanupData()).thenAnswer((_) async => null);
      when(mockSimpleController.updateWidgetData(null))
          .thenAnswer((_) async => null);
      when(mockDetailedController.updateWidgetData(null))
          .thenAnswer((_) async => null);

      // Act - execute a typical lifecycle sequence
      await controller.initialize(navigatorKey);

      // Reset invocation counters after initialization
      clearInteractions(mockSimpleController);
      clearInteractions(mockDetailedController);
      clearInteractions(mockCalorieCalculationStrategy);

      // Continue with lifecycle
      await controller.processUserStatusChange(testUser); // User logs in
      await controller.processPeriodicUpdate(); // Widget updates periodically
      await controller.processUserStatusChange(
          null); // User logs out - this will call cleanupData()
      // Since processUserStatusChange(null) already calls cleanupData, we should see 2 calls total
      await controller.cleanup(); // App closes - another call to cleanupData
      await controller.stopPeriodicUpdates(); // Background tasks stop

      // Assert - we don't verify initialization again since we cleared those interactions
      verify(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, testUserId))
          .called(2); // Once for login, once for update
      verify(mockSimpleController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(2); // Once for login, once for update
      verify(mockDetailedController.updateWidgetData(testUser,
              targetCalories: 2500))
          .called(2); // Once for login, once for update
      verify(mockSimpleController.cleanupData())
          .called(2); // Once for logout, once for cleanup
      verify(mockDetailedController.cleanupData())
          .called(2); // Once for logout, once for cleanup
      verify(mockBackgroundServiceHelper.cancelAllTasks()).called(1);
    });

    test('should handle refresh callbacks correctly', () async {
      // Arrange
      Function(FoodWidgetEventType)? simpleCallback;
      Function(FoodWidgetEventType)? detailedCallback;

      // Capture the callbacks
      when(mockSimpleController.setRefreshCallback(any))
          .thenAnswer((invocation) {
        simpleCallback =
            invocation.positionalArguments[0] as Function(FoodWidgetEventType);
        return null; // Return value for the mock
      });

      when(mockDetailedController.setRefreshCallback(any))
          .thenAnswer((invocation) {
        detailedCallback =
            invocation.positionalArguments[0] as Function(FoodWidgetEventType);
        return null; // Return value for the mock
      });

      when(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, any))
          .thenAnswer((_) async => 2500);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockSimpleController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async => null);
      when(mockDetailedController.updateWidgetData(any,
              targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async => null);

      // Act - initialize to setup callbacks
      await controller.initialize(navigatorKey);

      // Reset mock interactions after initialization
      clearInteractions(mockCalorieCalculationStrategy);
      clearInteractions(mockSimpleController);
      clearInteractions(mockDetailedController);

      // Trigger callbacks
      simpleCallback?.call(FoodWidgetEventType.refresh);

      // Use a small delay to allow the async callback chain to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      verify(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, testUserId))
          .called(1);

      // Reset again and try the detailed callback
      clearInteractions(mockCalorieCalculationStrategy);
      detailedCallback?.call(FoodWidgetEventType.refresh);

      // Use a small delay to allow the async callback chain to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert for detailed callback
      verify(mockCalorieCalculationStrategy.calculateTargetCalories(
              any, any, testUserId))
          .called(1);
    });
  });
}

// We no longer need the MockPermission class since we're using PermissionHelperInterface
