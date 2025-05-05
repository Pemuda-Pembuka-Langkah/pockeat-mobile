// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/detailed_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/nutrient_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';
import 'detailed_food_tracking_controller_test.mocks.dart';

// Generate mocks for all dependencies
@GenerateMocks([
  WidgetDataService,
  FoodLogHistoryService,
  CalorieStatsService,
  NutrientCalculationStrategy,
])

void main() {
  // Initialize the binding
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late DetailedFoodTrackingController controller;
  late MockWidgetDataService<DetailedFoodTracking> mockWidgetService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockCalorieStatsService mockCalorieStatsService;
  late MockNutrientCalculationStrategy mockNutrientCalculationStrategy;
  
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
    mockCalorieStatsService = MockCalorieStatsService();
    mockNutrientCalculationStrategy = MockNutrientCalculationStrategy();
    
    controller = DetailedFoodTrackingController(
      widgetService: mockWidgetService,
      foodLogHistoryService: mockFoodLogHistoryService,
      calorieStatsService: mockCalorieStatsService,
      nutrientCalculationStrategy: mockNutrientCalculationStrategy,
    );
  });

  group('DetailedFoodTrackingController - constructor', () {
    test('should initialize with default nutrient strategy when none is provided', () {
      // Arrange & Act - buat controller tanpa nutrient strategy
      final controllerWithDefault = DetailedFoodTrackingController(
        widgetService: mockWidgetService,
        foodLogHistoryService: mockFoodLogHistoryService,
        calorieStatsService: mockCalorieStatsService,
        // tidak memberikan nutrientCalculationStrategy secara eksplisit
      );
      
      // Assert - tidak dapat langsung mengakses private field, tapi kita bisa
      // memverifikasi bahwa controller dibuat dengan sukses
      expect(controllerWithDefault, isA<DetailedFoodTrackingController>());
    });
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
      const protein = 45;
      const carbs = 100;
      const fat = 25;
      
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
      
      // Setup CalorieStatsService untuk memberikan stats harian
      final dailyStats = DailyCalorieStats(
        caloriesConsumed: consumedCalories,
        caloriesBurned: 500,
        userId: testUserId,
        date: startOfDay,
      );
      
      when(mockCalorieStatsService.getStatsByDate(testUserId, startOfDay))
          .thenAnswer((_) async => dailyStats);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, startOfDay))
          .thenAnswer((_) async => logs);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'protein'))
          .thenReturn(protein.toDouble());
      
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'carbs'))
          .thenReturn(carbs.toDouble());
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'fat'))
          .thenReturn(fat.toDouble());
      
      // Act
      await controller.updateWidgetData(testUser, targetCalories: targetCalories);
      
      // Assert
      verify(mockCalorieStatsService.getStatsByDate(testUserId, startOfDay)).called(1);
        
      verify(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, any)).called(1);
      
      final captured = verify(mockWidgetService.updateData(captureAny)).captured.first as DetailedFoodTracking;
      expect(captured.caloriesNeeded, equals(targetCalories));
      expect(captured.currentCaloriesConsumed, equals(consumedCalories));
      expect(captured.userId, equals(testUserId));
    });
    
    test('should update widget data with zero target calories when not provided', () async {
      // Arrange
      const consumedCalories = 1500;
      const protein = 45;
      const carbs = 100;
      const fat = 25;
      
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Breakfast',
          subtitle: '350 calories',
          timestamp: today,
          calories: 350,
          protein: 15.0,
          carbs: 40,
          fat: 10,
        ),
      ];
      
      // Setup CalorieStatsService untuk memberikan stats harian
      final dailyStats = DailyCalorieStats(
        caloriesConsumed: consumedCalories,
        caloriesBurned: 500,
        userId: testUserId,
        date: startOfDay,
      );
      
      when(mockCalorieStatsService.getStatsByDate(testUserId, startOfDay))
          .thenAnswer((_) async => dailyStats);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(testUserId, startOfDay))
          .thenAnswer((_) async => logs);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'protein'))
          .thenReturn(protein.toDouble());
      
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'carbs'))
          .thenReturn(carbs.toDouble());
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(logs, 'fat'))
          .thenReturn(fat.toDouble());
      
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
      when(mockCalorieStatsService.getStatsByDate(testUserId, any))
          .thenThrow(Exception('Failed to get calories stats'));
      
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
    test('should handle a complete widget lifecycle', () async {
      // Arrange
      const targetCalories = 2000;
      const consumedCalories = 1500;
      
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      // Setup CalorieStatsService untuk memberikan stats harian
      final dailyStats = DailyCalorieStats(
        caloriesConsumed: consumedCalories,
        caloriesBurned: 500,
        userId: testUserId,
        date: startOfDay,
      );
      
      when(mockCalorieStatsService.getStatsByDate(any, any))
          .thenAnswer((_) async => dailyStats);
      
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(any, 'protein'))
          .thenReturn(30);
      
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(any, 'carbs'))
          .thenReturn(100);
          
      when(mockNutrientCalculationStrategy.calculateNutrientFromLogs(any, 'fat'))
          .thenReturn(25);
      
      when(mockFoodLogHistoryService.getFoodLogsByDate(any, any))
          .thenAnswer((_) async => []);
      
      // Act - Initialize, update, and cleanup
      await controller.initialize();
      await controller.updateWidgetData(testUser, targetCalories: targetCalories);
      await controller.cleanupData();
      
      // Assert
      verify(mockWidgetService.initialize()).called(1);
      verify(mockCalorieStatsService.getStatsByDate(any, any)).called(1);
      verify(mockFoodLogHistoryService.getFoodLogsByDate(any, any)).called(1);
    });
  });
}
