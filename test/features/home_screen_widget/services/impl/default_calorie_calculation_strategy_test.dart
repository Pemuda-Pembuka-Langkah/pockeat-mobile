import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_calorie_calculation_strategy.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';

// Generate mocks for all dependencies
@GenerateMocks(
    [FoodLogHistoryService, HealthMetricsRepository, CaloricRequirementService])
import 'default_calorie_calculation_strategy_test.mocks.dart';

void main() {
  late DefaultCalorieCalculationStrategy strategy;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockHealthMetricsRepository mockHealthMetricsRepository;
  late MockCaloricRequirementService mockCaloricRequirementService;

  const String testUserId = 'test-user-123';

  setUp(() {
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockHealthMetricsRepository = MockHealthMetricsRepository();
    mockCaloricRequirementService = MockCaloricRequirementService();
    strategy = DefaultCalorieCalculationStrategy();
  });

  group('DefaultCalorieCalculationStrategy - calculateTodayTotalCalories', () {
    test('should calculate total calories from today\'s food logs correctly',
        () async {
      // Arrange
      final DateTime today = DateTime.now();

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
        FoodLogHistoryItem(
          id: '3',
          title: 'Dinner',
          subtitle: '650 calories',
          timestamp: today,
          calories: 650,
          protein: 35,
          carbs: 70,
          fat: 20,
        ),
      ];

      when(mockFoodLogHistoryService.getFoodLogsByDate(any, any))
          .thenAnswer((_) async => logs);

      // Act
      final result = await strategy.calculateTodayTotalCalories(
          mockFoodLogHistoryService, testUserId);

      // Assert
      expect(result, 1550); // 350 + 550 + 650 = 1550
      verify(mockFoodLogHistoryService.getFoodLogsByDate(any, any)).called(1);
    });

    test('should return 0 when no food logs are found for today', () async {
      // Arrange
      // We'll just mock the service to return empty logs
      when(mockFoodLogHistoryService.getFoodLogsByDate(any, any))
          .thenAnswer((_) async => []);

      // Act
      final result = await strategy.calculateTodayTotalCalories(
          mockFoodLogHistoryService, testUserId);

      // Assert
      expect(result, 0);
      verify(mockFoodLogHistoryService.getFoodLogsByDate(any, any)).called(1);
    });

    test('should handle fractional calorie values correctly', () async {
      // Arrange
      final DateTime today = DateTime.now();
      
      final logs = [
        FoodLogHistoryItem(
          id: '1',
          title: 'Snack 1',
          subtitle: '150.5 calories',
          timestamp: today,
          calories: 150.5,
          protein: 5,
          carbs: 20,
          fat: 5,
        ),
        FoodLogHistoryItem(
          id: '2',
          title: 'Snack 2',
          subtitle: '200.7 calories',
          timestamp: today,
          calories: 200.7,
          protein: 8,
          carbs: 25,
          fat: 8,
        ),
      ];

      when(mockFoodLogHistoryService.getFoodLogsByDate(any, any))
          .thenAnswer((_) async => logs);

      // Act
      final result = await strategy.calculateTodayTotalCalories(
          mockFoodLogHistoryService, testUserId);

      // Assert
      expect(result, 350); // Note: The calculation rounds down to int
      verify(mockFoodLogHistoryService.getFoodLogsByDate(any, any)).called(1);
    });
  });

  group('DefaultCalorieCalculationStrategy - calculateTargetCalories', () {
    test('should calculate target calories from health metrics correctly',
        () async {
      // Arrange
      final mockHealthMetrics = HealthMetricsModel(
        userId: testUserId,
        height: 175.0,
        weight: 70.0,
        age: 30,
        gender: 'male',
        activityLevel: 'moderate',
        fitnessGoal: 'maintain',
      );

      final mockRequirementResult = CaloricRequirementModel(
        userId: testUserId,
        bmr: 1700.0,
        tdee: 2500.0,
        timestamp: DateTime.now(),
      );

      when(mockHealthMetricsRepository.getHealthMetrics(any))
          .thenAnswer((_) async => mockHealthMetrics);

      when(mockCaloricRequirementService.analyze(
  userId: anyNamed('userId'),
  model: anyNamed('model'),
)).thenReturn(mockRequirementResult);

      // Act
      final result = await strategy.calculateTargetCalories(
          mockHealthMetricsRepository,
          mockCaloricRequirementService,
          testUserId);

      // Assert
      expect(result, 2500);
      verify(mockHealthMetricsRepository.getHealthMetrics(any)).called(1);
      verify(mockCaloricRequirementService.analyze(
        userId: anyNamed('userId'),
        model: anyNamed('model'),
      )).called(1);
    });

    test('should return 0 when health metrics are null', () async {
      // Arrange
      when(mockHealthMetricsRepository.getHealthMetrics(testUserId))
          .thenAnswer((_) async => null);

      // Act
      final result = await strategy.calculateTargetCalories(
          mockHealthMetricsRepository,
          mockCaloricRequirementService,
          testUserId);

      // Assert
      expect(result, 0);
      verify(mockHealthMetricsRepository.getHealthMetrics(any)).called(1);
      verifyNever(mockCaloricRequirementService.analyze(
        userId: anyNamed('userId'),
        model: anyNamed('model'),
      ));
    });

    test('should handle fractional tdee values correctly', () async {
      // Arrange
      final mockHealthMetrics = HealthMetricsModel(
        userId: testUserId,
        height: 175.0,
        weight: 70.0,
        age: 30,
        gender: 'male',
        activityLevel: 'moderate',
        fitnessGoal: 'maintain',
      );

      final mockRequirementResult = CaloricRequirementModel(
        userId: testUserId,
        bmr: 1700.5,
        tdee: 2550.7, // Fractional value
        timestamp: DateTime.now(),
      );

      when(mockHealthMetricsRepository.getHealthMetrics(any))
          .thenAnswer((_) async => mockHealthMetrics);

      when(mockCaloricRequirementService.analyze(
      userId: anyNamed('userId'),
      model: anyNamed('model'),
    )).thenReturn(mockRequirementResult);

      // Act
      final result = await strategy.calculateTargetCalories(
          mockHealthMetricsRepository,
          mockCaloricRequirementService,
          testUserId);

      // Assert
      expect(result, 2550); // 2550.7 truncated to int
      verify(mockHealthMetricsRepository.getHealthMetrics(any)).called(1);
      verify(mockCaloricRequirementService.analyze(
        userId: anyNamed('userId'),
        model: anyNamed('model'),
      )).called(1);
    });
  });
}
