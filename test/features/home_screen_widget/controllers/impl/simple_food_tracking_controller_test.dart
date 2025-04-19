import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/simple_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_event_type.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import 'dart:async';

// Generate mocks for all dependencies
@GenerateMocks([
  WidgetDataService,
  FoodLogHistoryService,
  CalorieCalculationStrategy,
  NavigatorState,
])
import 'simple_food_tracking_controller_test.mocks.dart';

void main() {
  // Initialize the binding
  TestWidgetsFlutterBinding.ensureInitialized();
  late SimpleFoodTrackingController controller;
  late MockWidgetDataService<SimpleFoodTracking> mockWidgetService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockCalorieCalculationStrategy mockCalorieCalculationStrategy;
  late GlobalKey<NavigatorState> navigatorKey;
  
  const String testUserId = 'test-user-123';
  final testUser = UserModel(
    uid: testUserId,
    displayName: 'Test User',
    email: 'test@example.com',
    photoURL: 'https://example.com/photo.jpg',
    emailVerified: true,
    createdAt: DateTime(2025, 4, 1),
  );

  setUp(() {
    mockWidgetService = MockWidgetDataService<SimpleFoodTracking>();
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockCalorieCalculationStrategy = MockCalorieCalculationStrategy();
    
    navigatorKey = GlobalKey<NavigatorState>();
    
    // We can't easily mock the GlobalKey.currentState property directly
    // Instead, we'll verify the actual navigation methods in our tests
    
    controller = SimpleFoodTrackingController(
      widgetService: mockWidgetService,
      foodLogHistoryService: mockFoodLogHistoryService,
      calorieCalculationStrategy: mockCalorieCalculationStrategy,
    );
    
    // Create a StreamController for widget events
    final streamController = StreamController<FoodWidgetEventType>.broadcast();
    
    // Mock the widgetEvents getter to return the stream
    when(mockWidgetService.widgetEvents).thenAnswer((_) => streamController.stream);
    
    // Add a tearDown to close the stream controller
    addTearDown(() {
      streamController.close();
    });
  });

  group('SimpleFoodTrackingController - initialize', () {
    test('should initialize successfully', () async {
      // Arrange
      when(mockWidgetService.initialize()).thenAnswer((_) async => {});
      when(mockWidgetService.registerWidgetClickCallback()).thenAnswer((_) async => {});
      
      // Act
      await controller.initialize(navigatorKey: navigatorKey);
      
      // Assert
      verify(mockWidgetService.initialize()).called(1);
      verify(mockWidgetService.registerWidgetClickCallback()).called(1);
    });
    
    test('should throw WidgetInitializationException when initialization fails', () async {
      // Arrange
      when(mockWidgetService.initialize()).thenThrow(Exception('Service initialization failed'));
      
      // Act & Assert
      expect(
        () => controller.initialize(navigatorKey: navigatorKey),
        throwsA(isA<WidgetInitializationException>()),
      );
    });
    
    test('should throw WidgetInitializationException when callback registration fails', () async {
      // Arrange
      when(mockWidgetService.initialize()).thenAnswer((_) async => {});
      when(mockWidgetService.registerWidgetClickCallback())
          .thenThrow(Exception('Callback registration failed'));
      
      // Act & Assert
      expect(
        () => controller.initialize(navigatorKey: navigatorKey),
        throwsA(isA<WidgetInitializationException>()),
      );
    });
  });

  group('SimpleFoodTrackingController - updateWidgetData', () {
    test('should update widget data successfully with user and target calories', () async {
      // Arrange
      const targetCalories = 2500;
      const consumedCalories = 1500;
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId))
          .thenAnswer((_) async => consumedCalories);
      
      // Act
      await controller.updateWidgetData(testUser, targetCalories: targetCalories);
      
      // Assert
      verify(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId)).called(1);
      
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as SimpleFoodTracking;
      expect(captured.caloriesNeeded, equals(targetCalories));
      expect(captured.currentCaloriesConsumed, equals(consumedCalories));
      expect(captured.userId, equals(testUserId));
      
      verify(mockWidgetService.updateWidget()).called(1);
    });
    
    test('should update widget data with zero target calories when not provided', () async {
      // Arrange
      const consumedCalories = 1500;
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId))
          .thenAnswer((_) async => consumedCalories);
      
      // Act
      await controller.updateWidgetData(testUser);
      
      // Assert
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as SimpleFoodTracking;
      expect(captured.caloriesNeeded, equals(0));
      expect(captured.currentCaloriesConsumed, equals(consumedCalories));
      expect(captured.userId, equals(testUserId));
    });
    
    test('should call cleanupData when user is null', () async {
      // Arrange
      when(mockWidgetService.updateData(any)).thenAnswer((_) async => {});
      when(mockWidgetService.updateWidget()).thenAnswer((_) async => {});
      
      // Act
      await controller.updateWidgetData(null);
      
      // Assert
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as SimpleFoodTracking;
      expect(captured.caloriesNeeded, equals(0));
      expect(captured.currentCaloriesConsumed, equals(0));
      expect(captured.userId, isNull);
      verify(mockWidgetService.updateWidget()).called(1);
    });
    
    test('should throw WidgetUpdateException when update fails', () async {
      // Arrange
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId))
          .thenThrow(Exception('Failed to calculate calories'));
      
      // Act & Assert
      expect(
        () => controller.updateWidgetData(testUser),
        throwsA(isA<WidgetUpdateException>()),
      );
    });
    
    test('should handle edge case with extremely high calorie values', () async {
      // Arrange
      const targetCalories = 9999999;
      const consumedCalories = 9999999;
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId))
          .thenAnswer((_) async => consumedCalories);
      
      // Act
      await controller.updateWidgetData(testUser, targetCalories: targetCalories);
      
      // Assert
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as SimpleFoodTracking;
      expect(captured.caloriesNeeded, equals(targetCalories));
      expect(captured.currentCaloriesConsumed, equals(consumedCalories));
      expect(captured.userId, equals(testUserId));
    });
  });

  group('SimpleFoodTrackingController - handleWidgetInteraction', () {
    test('should handle clicked event correctly', () async {
      // First initialize to set the navigator key
      await controller.initialize(navigatorKey: navigatorKey);
      
      // Act
      await controller.handleWidgetInteraction(FoodWidgetEventType.clicked);
      
      // Since we can't easily mock GlobalKey.currentState, we just verify no exceptions are thrown
      // In a real integration test, we would verify navigation happens
    });
    
    test('should call refresh callback when refresh event occurs', () async {
      // Arrange
      bool callbackCalled = false;
      FoodWidgetEventType? eventReceived;
      
      controller.setRefreshCallback((event) {
        callbackCalled = true;
        eventReceived = event;
      });
      
      // Act
      await controller.handleWidgetInteraction(FoodWidgetEventType.refresh);
      
      // Assert
      expect(callbackCalled, isTrue);
      expect(eventReceived, equals(FoodWidgetEventType.refresh));
    });
    
    test('should handle quicklog event correctly', () async {
      // First initialize to set the navigator key
      await controller.initialize(navigatorKey: navigatorKey);
      
      // Act
      await controller.handleWidgetInteraction(FoodWidgetEventType.quicklog);
      
      // Since we can't easily mock GlobalKey.currentState, we just verify no exceptions are thrown
      // In a real integration test, we would verify navigation happens
    });
    
    test('should handle gologin event correctly', () async {
      // First initialize to set the navigator key
      await controller.initialize(navigatorKey: navigatorKey);
      
      // Act
      await controller.handleWidgetInteraction(FoodWidgetEventType.gologin);
      
      // Since we can't easily mock GlobalKey.currentState, we just verify no exceptions are thrown
      // In a real integration test, we would verify navigation to the login page
    });
    
    test('should handle other event correctly', () async {
      // Act
      await controller.handleWidgetInteraction(FoodWidgetEventType.other);
      
      // Assert - no exceptions should be thrown
    });
    
    test('should handle navigation failure gracefully', () async {
      // Arrange - create a controller that might encounter navigation failure
      controller = SimpleFoodTrackingController(
        widgetService: mockWidgetService,
        foodLogHistoryService: mockFoodLogHistoryService,
        calorieCalculationStrategy: mockCalorieCalculationStrategy,
      );
      
      // First initialize with a non-null navigator key
      await controller.initialize(navigatorKey: navigatorKey);
      
      // Create a navigatorKey with a null currentState to simulate failure
      final nullNavigatorKey = GlobalKey<NavigatorState>();
      
      // Replace the navigator key with the problematic one
      await controller.initialize(navigatorKey: nullNavigatorKey);
      
      // Act & Assert - even with a null navigator, it shouldn't throw an exception
      // This matches the actual implementation's behavior of safely handling null navigator
      await controller.handleWidgetInteraction(FoodWidgetEventType.clicked);
      
      // If we get here without exception, the test is successful
    });
  });

  group('SimpleFoodTrackingController - registerWidgetClickCallback', () {
    test('should register widget click callback successfully', () async {
      // Arrange
      when(mockWidgetService.registerWidgetClickCallback()).thenAnswer((_) async => {});
      
      // Act
      await controller.registerWidgetClickCallback();
      
      // Assert
      verify(mockWidgetService.registerWidgetClickCallback()).called(1);
    });
    
    test('should throw WidgetCallbackRegistrationException when registration fails', () async {
      // Arrange
      when(mockWidgetService.registerWidgetClickCallback())
          .thenThrow(Exception('Registration failed'));
      
      // Act & Assert
      expect(
        () => controller.registerWidgetClickCallback(),
        throwsA(isA<WidgetCallbackRegistrationException>()),
      );
    });
    
    test('should listen to widget events after registration', () async {
      // Arrange
      when(mockWidgetService.registerWidgetClickCallback()).thenAnswer((_) async => {});
      final streamController = StreamController<FoodWidgetEventType>();
      when(mockWidgetService.widgetEvents).thenAnswer((_) => streamController.stream);
      
      bool callbackCalled = false;
      controller.setRefreshCallback((event) {
        callbackCalled = true;
      });
      
      // Act
      await controller.registerWidgetClickCallback();
      
      // Simulate a widget event
      streamController.add(FoodWidgetEventType.refresh);
      await Future.delayed(Duration.zero); // Allow event to be processed
      
      // Assert
      expect(callbackCalled, isTrue);
      
      // Clean up
      await streamController.close();
    });
  });

  group('SimpleFoodTrackingController - cleanupData', () {
    test('should clean up data successfully', () async {
      // Arrange
      when(mockWidgetService.updateData(any)).thenAnswer((_) async => {});
      when(mockWidgetService.updateWidget()).thenAnswer((_) async => {});
      
      // Act
      await controller.cleanupData();
      
      // Assert
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as SimpleFoodTracking;
      expect(captured.caloriesNeeded, equals(0));
      expect(captured.currentCaloriesConsumed, equals(0));
      expect(captured.userId, isNull);
      
      verify(mockWidgetService.updateWidget()).called(1);
    });
    
    test('should throw WidgetCleanupException when cleanup fails', () async {
      // Arrange
      when(mockWidgetService.updateData(any)).thenThrow(Exception('Update failed'));
      
      // Act & Assert
      expect(
        () => controller.cleanupData(),
        throwsA(isA<WidgetCleanupException>()),
      );
    });
  });

  group('SimpleFoodTrackingController - setRefreshCallback', () {
    test('should set refresh callback correctly', () async {
      // Arrange
      bool callbackCalled = false;
      final callback = (_) { callbackCalled = true; };
      
      // Act
      controller.setRefreshCallback(callback);
      
      // Trigger the callback via handleWidgetInteraction
      await controller.handleWidgetInteraction(FoodWidgetEventType.refresh);
      
      // Assert
      expect(callbackCalled, isTrue);
    });
    
    test('should handle null callback gracefully', () async {
      // Arrange - controller starts with null callback
      
      // Act
      // Set a no-op callback
      controller.setRefreshCallback((_) {});
      
      // Assert - can invoke refresh without error
      await controller.handleWidgetInteraction(FoodWidgetEventType.refresh);
      // No assertion needed - test passes if no exception is thrown
    });
  });

  group('Integration tests', () {
    test('initialization and updating should work together', () async {
      // Arrange
      when(mockWidgetService.initialize()).thenAnswer((_) async => {});
      when(mockWidgetService.registerWidgetClickCallback()).thenAnswer((_) async => {});
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any))
          .thenAnswer((_) async => 1500);
      
      // Act - initialize and then update
      await controller.initialize(navigatorKey: navigatorKey);
      await controller.updateWidgetData(testUser, targetCalories: 2000);
      
      // Assert
      verify(mockWidgetService.initialize()).called(1);
      verify(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any)).called(1);
      
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as SimpleFoodTracking;
      expect(captured.caloriesNeeded, equals(2000));
      expect(captured.currentCaloriesConsumed, equals(1500));
    });
    
    test('should handle a complete widget lifecycle', () async {
      // Arrange
      when(mockWidgetService.initialize()).thenAnswer((_) async => {});
      when(mockWidgetService.registerWidgetClickCallback()).thenAnswer((_) async => {});
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any))
          .thenAnswer((_) async => 1500);
      
      // Act - Initialize, update, handle interaction, and cleanup
      await controller.initialize(navigatorKey: navigatorKey);
      await controller.updateWidgetData(testUser, targetCalories: 2000);
      await controller.handleWidgetInteraction(FoodWidgetEventType.clicked);
      await controller.cleanupData();
      
      // Assert
      verify(mockWidgetService.initialize()).called(1);
      verify(mockWidgetService.updateWidget()).called(2); // Once for update, once for cleanup
    });
  });
}
