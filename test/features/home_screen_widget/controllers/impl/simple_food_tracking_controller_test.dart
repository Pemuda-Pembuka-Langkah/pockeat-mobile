import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/simple_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';

// Generate mocks for all dependencies
@GenerateMocks([
  WidgetDataService,
  FoodLogHistoryService,
  CalorieCalculationStrategy
])
import 'simple_food_tracking_controller_test.mocks.dart';

void main() {
  // Initialize the binding
  TestWidgetsFlutterBinding.ensureInitialized();
  late SimpleFoodTrackingController controller;
  late MockWidgetDataService<SimpleFoodTracking> mockWidgetService;
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
    mockWidgetService = MockWidgetDataService<SimpleFoodTracking>();
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockCalorieCalculationStrategy = MockCalorieCalculationStrategy();

    controller = SimpleFoodTrackingController(
      widgetService: mockWidgetService,
      foodLogHistoryService: mockFoodLogHistoryService,
      calorieCalculationStrategy: mockCalorieCalculationStrategy,
    );
  });

  group('SimpleFoodTrackingController - initialize', () {
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
      when(mockWidgetService.initialize()).thenThrow(Exception('Service initialization failed'));

      // Act & Assert
      expect(
        () => controller.initialize(),
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
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any))
          .thenAnswer((_) async => 1500);

      // Act - initialize and then update
      await controller.initialize();
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
      when(mockCalorieCalculationStrategy.calculateTodayTotalCalories(any, any))
          .thenAnswer((_) async => 1500);

      // Act - Initialize, update and cleanup
      await controller.initialize();
      await controller.updateWidgetData(testUser, targetCalories: 2000);
      await controller.cleanupData();

      // Assert
      verify(mockWidgetService.initialize()).called(1);
    });
  });
}
