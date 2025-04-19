import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/detailed_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_event_type.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import 'dart:async';

// Generate mocks for all dependencies
@GenerateMocks([
  WidgetDataService,
  FoodLogHistoryService,
  CalorieCalculationStrategy,
  NutrientCalculationStrategy,
  NavigatorState,
])
import 'detailed_food_tracking_controller_test.mocks.dart';

void main() {
  // Initialize the binding
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late DetailedFoodTrackingController controller;
  late MockWidgetDataService<DetailedFoodTracking> mockWidgetService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockCalorieCalculationStrategy mockCalorieCalculationStrategy;
  late MockNutrientCalculationStrategy mockNutrientCalculationStrategy;
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
    mockWidgetService = MockWidgetDataService<DetailedFoodTracking>();
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockCalorieCalculationStrategy = MockCalorieCalculationStrategy();
    mockNutrientCalculationStrategy = MockNutrientCalculationStrategy();
    
    navigatorKey = GlobalKey<NavigatorState>();
    
    // We can't easily mock the GlobalKey.currentState property directly
    // Instead, we'll verify the actual navigation methods in our tests
    
    controller = DetailedFoodTrackingController(
      widgetService: mockWidgetService,
      foodLogHistoryService: mockFoodLogHistoryService,
      calorieCalculationStrategy: mockCalorieCalculationStrategy,
      nutrientCalculationStrategy: mockNutrientCalculationStrategy,
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

  group('DetailedFoodTrackingController - initialize', () {
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
      when(mockWidgetService.initialize())
          .thenThrow(Exception('Service initialization failed'));
      
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

  group('DetailedFoodTrackingController - updateWidgetData', () {
    test('should update widget data successfully with user and target calories', () async {
      // Arrange
      const targetCalories = 2500;
      const consumedCalories = 1500;
      
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Breakfast',
          subtitle: '350 calories',
          timestamp: today,
          calories: 350,
          protein: 15,
          carbs: 40,
          fat: 10,
        ),
        FoodLogHistoryItem(
          id: '2',
          title: 'Lunch',
          subtitle: '550 calories',
          timestamp: today,
          calories: 550,
          protein: 30,
          carbs: 60,
          fat: 15,
        ),
      ];
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId))
          .thenAnswer((_) async => consumedCalories);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, startOfDay))
          .thenAnswer((_) async => logs);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'protein'))
          .thenReturn(45.0); // 15 + 30
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'carbs'))
          .thenReturn(100.0); // 40 + 60
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'fat'))
          .thenReturn(25.0); // 10 + 15
      
      // Act
      await controller.updateWidgetData(testUser, targetCalories: targetCalories);
      
      // Assert
      verify(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId)).called(1);
        
      verify(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, any)).called(1);
      
      verify(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'protein')).called(1);
      verify(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'carbs')).called(1);
      verify(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'fat')).called(1);
      
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
      expect(captured.caloriesNeeded, equals(targetCalories));
      expect(captured.currentCaloriesConsumed, equals(consumedCalories));
      expect(captured.currentProtein, equals(45.0));
      expect(captured.currentCarb, equals(100.0));
      expect(captured.currentFat, equals(25.0));
      expect(captured.userId, equals(testUserId));
      
      verify(mockWidgetService.updateWidget()).called(1);
    });
    
    test('should update widget data with zero target calories when not provided', () async {
      // Arrange
      const consumedCalories = 1500;
      
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Breakfast',
          subtitle: '350 calories',
          timestamp: today,
          calories: 350,
          protein: 15,
          carbs: 40,
          fat: 10,
        ),
      ];
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId))
          .thenAnswer((_) async => consumedCalories);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, startOfDay))
          .thenAnswer((_) async => logs);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'protein'))
          .thenReturn(15.0);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'carbs'))
          .thenReturn(40.0);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'fat'))
          .thenReturn(10.0);
      
      // Act
      await controller.updateWidgetData(testUser);
      
      // Assert
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
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
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
      expect(captured.caloriesNeeded, equals(0));
      expect(captured.currentCaloriesConsumed, equals(0));
      expect(captured.currentProtein, equals(0));
      expect(captured.currentCarb, equals(0));
      expect(captured.currentFat, equals(0));
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
    
    test('should handle edge case with empty food logs', () async {
      // Arrange
      const targetCalories = 2000;
      const consumedCalories = 0;
      
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      final logs = <FoodLogHistoryItem>[];
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId))
          .thenAnswer((_) async => consumedCalories);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, startOfDay))
          .thenAnswer((_) async => logs);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'protein'))
          .thenReturn(0);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'carbs'))
          .thenReturn(0);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'fat'))
          .thenReturn(0);
      
      // Act
      await controller.updateWidgetData(testUser, targetCalories: targetCalories);
      
      // Assert
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
      expect(captured.caloriesNeeded, equals(targetCalories));
      expect(captured.currentCaloriesConsumed, equals(0));
      expect(captured.currentProtein, equals(0));
      expect(captured.currentCarb, equals(0));
      expect(captured.currentFat, equals(0));
    });
    
    test('should handle edge case with extremely high nutrition values', () async {
      // Arrange
      const targetCalories = 9999999;
      const consumedCalories = 9999999;
      
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Extreme Meal',
          subtitle: 'Very high calories',
          timestamp: today,
          calories: 9999999,
          protein: 999999,
          carbs: 999999,
          fat: 999999,
        ),
      ];
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId))
          .thenAnswer((_) async => consumedCalories);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, startOfDay))
          .thenAnswer((_) async => logs);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'protein'))
          .thenReturn(999999.0);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'carbs'))
          .thenReturn(999999.0);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'fat'))
          .thenReturn(999999.0);
      
      // Act
      await controller.updateWidgetData(testUser, targetCalories: targetCalories);
      
      // Assert
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
      expect(captured.caloriesNeeded, equals(targetCalories));
      expect(captured.currentCaloriesConsumed, equals(consumedCalories));
      expect(captured.currentProtein, equals(999999.0));
      expect(captured.currentCarb, equals(999999.0));
      expect(captured.currentFat, equals(999999.0));
    });
  });

  group('DetailedFoodTrackingController - handleWidgetInteraction', () {
    test('should handle clicked event correctly', () async {
      // First initialize to set the navigator key
      await controller.initialize(navigatorKey: navigatorKey);
      
      // Act
      await controller.handleWidgetInteraction(FoodWidgetEventType.clicked);
      
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
    
    test('should handle other event correctly', () async {
      // Act
      await controller.handleWidgetInteraction(FoodWidgetEventType.other);
      
      // Assert - no exceptions should be thrown
    });
    
    test('should handle navigation failure gracefully', () async {
      // Arrange - create a controller that might encounter navigation failure
      controller = DetailedFoodTrackingController(
        widgetService: mockWidgetService,
        foodLogHistoryService: mockFoodLogHistoryService,
        calorieCalculationStrategy: mockCalorieCalculationStrategy,
        nutrientCalculationStrategy: mockNutrientCalculationStrategy,
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

  group('DetailedFoodTrackingController - setRefreshCallback', () {
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
      // Act
      // Set a no-op callback
      controller.setRefreshCallback((_) {});
      
      // Assert - can invoke refresh without error
      await controller.handleWidgetInteraction(FoodWidgetEventType.refresh);
      // No assertion needed - test passes if no exception is thrown
    });
  });

  group('DetailedFoodTrackingController - registerWidgetClickCallback', () {
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

  group('DetailedFoodTrackingController - cleanupData', () {
    test('should clean up data successfully', () async {
      // Arrange
      when(mockWidgetService.updateData(any)).thenAnswer((_) async => {});
      when(mockWidgetService.updateWidget()).thenAnswer((_) async => {});
      
      // Act
      await controller.cleanupData();
      
      // Assert
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
      expect(captured.caloriesNeeded, equals(0));
      expect(captured.currentCaloriesConsumed, equals(0));
      expect(captured.currentProtein, equals(0));
      expect(captured.currentCarb, equals(0));
      expect(captured.currentFat, equals(0));
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

  group('Integration tests', () {
    test('initialization and updating should work together', () async {
      // Arrange
      when(mockWidgetService.initialize()).thenAnswer((_) async => {});
      when(mockWidgetService.registerWidgetClickCallback()).thenAnswer((_) async => {});
      
      // Create empty logs list for the test
      final logs = <FoodLogHistoryItem>[];
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any))
          .thenAnswer((_) async => 1500);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(any, any))
          .thenAnswer((_) async => logs);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(any, any))
          .thenReturn(0);
      
      // Act - Initialize and then update
      await controller.initialize(navigatorKey: navigatorKey);
      await controller.updateWidgetData(testUser, targetCalories: 2000);
      
      // Assert
      verify(mockWidgetService.initialize()).called(1);
      verify(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any)).called(1);
      
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
      expect(captured.caloriesNeeded, equals(2000));
      expect(captured.currentCaloriesConsumed, equals(1500));
    });
    
    test('should handle a complete widget lifecycle', () async {
      // Arrange
      when(mockWidgetService.initialize()).thenAnswer((_) async => {});
      when(mockWidgetService.registerWidgetClickCallback()).thenAnswer((_) async => {});
      
      // Create empty logs list for the test
      final logs = <FoodLogHistoryItem>[];
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any))
          .thenAnswer((_) async => 1500);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(any, any))
          .thenAnswer((_) async => logs);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(any, any))
          .thenReturn(0);
      
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
