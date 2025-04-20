import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/detailed_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';

// Generate mocks for all dependencies
@GenerateMocks([
  WidgetDataService,
  FoodLogHistoryService,
  CalorieCalculationStrategy,
])
import 'detailed_food_tracking_controller_test.mocks.dart';

void main() {
  // Initialize the binding
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late DetailedFoodTrackingController controller;
  late MockWidgetDataService<DetailedFoodTracking> mockWidgetService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockCalorieCalculationStrategy mockCalorieCalculationStrategy;
  
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
    
    controller = DetailedFoodTrackingController(
      widgetService: mockWidgetService,
      foodLogHistoryService: mockFoodLogHistoryService,
      calorieCalculationStrategy: mockCalorieCalculationStrategy,
    );
  });

  group('DetailedFoodTrackingController - initialize', () {
    test('should initialize successfully', () async {
      // Arrange
      when(mockWidgetService.initialize()).thenAnswer((_) async => {});
      
      // Act
      await controller.initialize();
      
      // Assert
      verify(mockWidgetService.initialize()).called(1);
    });
    
    test('should throw WidgetInitializationException when initialization fails', () async {
      // Arrange
      when(mockWidgetService.initialize())
          .thenThrow(Exception('Service initialization failed'));
      
      // Act & Assert
      expect(
        () => controller.initialize(),
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
          
      // Act
      await controller.updateWidgetData(testUser, targetCalories: targetCalories);
      
      // Assert
      verify(mockCalorieCalculationStrategy.calculateTodayTotalCalories(
        mockFoodLogHistoryService, testUserId)).called(1);
        
      verify(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, any)).called(1);
      
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
      expect(captured.caloriesNeeded, equals(targetCalories));
      expect(captured.currentCaloriesConsumed, equals(consumedCalories));
      expect(captured.userId, equals(testUserId));
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
      
      // Create empty logs list for the test
      final logs = <FoodLogHistoryItem>[];
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any))
          .thenAnswer((_) async => 1500);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(any, any))
          .thenAnswer((_) async => logs);
          
      // Act - Initialize and then update
      await controller.initialize();
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
      
      // Create empty logs list for the test
      final logs = <FoodLogHistoryItem>[];
      
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any))
          .thenAnswer((_) async => 1500);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(any, any))
          .thenAnswer((_) async => logs);
          
      // Act - Initialize, update and cleanup
      await controller.initialize();
      await controller.updateWidgetData(testUser, targetCalories: 2500);
      await controller.cleanupData();
      
      // Assert
      verify(mockWidgetService.initialize()).called(1);
      verify(mockWidgetService.updateWidget()).called(2); // Once for update, once for cleanup
    });
  });
}
