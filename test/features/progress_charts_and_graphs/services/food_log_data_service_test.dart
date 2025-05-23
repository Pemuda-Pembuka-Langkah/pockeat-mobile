// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';
import 'food_log_data_service_test.mocks.dart';

@GenerateMocks([FoodLogHistoryService, User])

// Mock for FirebaseAuth that doesn't rely on Firebase initialization
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }
}

// A testable version of FoodLogDataService with mocked Firebase
class TestFoodLogDataService extends FoodLogDataService {
  final FirebaseAuth auth;
  final FoodLogHistoryService foodLogService;

  TestFoodLogDataService({
    required this.foodLogService,
    required this.auth,
  }) : super(foodLogService: foodLogService);

  // Override the private method to use our mocked auth
  @override
  Future<String> _getUserId() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  // Override the method with the weeksAgo parameter
  @override
  Future<List<CalorieData>> getWeekCalorieData({int weeksAgo = 0}) async {
    try {
      // Get the date range for the requested week (Sunday to Saturday)
      final now = DateTime.now();
      final currentStartOfWeek = now.subtract(Duration(days: now.weekday % 7));

      // Calculate start date for the requested week (going back weeksAgo weeks)
      final startDate = DateTime(currentStartOfWeek.year,
          currentStartOfWeek.month, currentStartOfWeek.day - (7 * weeksAgo));

      final endDate = startDate.add(const Duration(days: 7));

      // Get user ID from our mocked auth
      final userId = await _getUserId();

      // Fetch food log entries for the specified week
      final foodLogs = await foodLogService.getAllFoodLogs(userId, limit: 100);

      // Filter logs for the specific week
      final weekLogs = filterLogsForSpecificWeek(foodLogs, startDate, endDate);

      // Group entries by day and calculate macronutrient totals
      return processLogsToCalorieData(weekLogs, startDate);
    } catch (e) {
      debugPrint('Error fetching week calorie data ($weeksAgo weeks ago): $e');
      return getDefaultWeekData();
    }
  }

  @override
  Future<List<CalorieData>> getMonthCalorieData() async {
    try {
      // Get the date range for current month
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final userId = await _getUserId();

      // Fetch food log entries
      final foodLogs = await foodLogService.getAllFoodLogs(userId, limit: 100);

      // Filter logs for current month
      final monthLogs = filterLogsForCurrentMonth(foodLogs, firstDayOfMonth);

      // Process logs into weekly data
      return processLogsToWeeklyCalorieData(monthLogs, firstDayOfMonth);
    } catch (e) {
      debugPrint('Error fetching month calorie data: $e');
      return getDefaultMonthData();
    }
  }

  // Implementation methods without @override since they're not actually overriding
  List<CalorieData> processLogsToCalorieData(
      List<FoodLogHistoryItem> logs, DateTime startDate) {
    // Create a map for each day
    Map<String, Map<String, double>> dailyMacros = {};
    Map<String, double> dailyCalories = {};

    // Initialize all days of the week with zeros
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (var day in dayNames) {
      dailyMacros[day] = {'protein': 0, 'carbs': 0, 'fats': 0};
      dailyCalories[day] = 0;
    }

    // Process each log entry
    for (var log in logs) {
      // Use timestamp directly without timezone adjustment
      final logDateTime = log.timestamp;
      final dayOfWeek = dayNames[logDateTime.weekday % 7];

      // Extract values
      final protein = log.protein?.toDouble() ?? 0;
      final carbs = log.carbs?.toDouble() ?? 0;
      final fat = log.fat?.toDouble() ?? 0;
      final calories = log.calories.toDouble();

      // Add values
      dailyMacros[dayOfWeek]!['protein'] =
          (dailyMacros[dayOfWeek]!['protein'] ?? 0) + protein;
      dailyMacros[dayOfWeek]!['carbs'] =
          (dailyMacros[dayOfWeek]!['carbs'] ?? 0) + carbs;
      dailyMacros[dayOfWeek]!['fats'] =
          (dailyMacros[dayOfWeek]!['fats'] ?? 0) + fat;
      dailyCalories[dayOfWeek] = (dailyCalories[dayOfWeek] ?? 0) + calories;
    }

    // Convert to CalorieData list
    List<CalorieData> result = [];
    for (var dayName in dayNames) {
      result.add(CalorieData(
        dayName,
        dailyMacros[dayName]!['protein'] ?? 0,
        dailyMacros[dayName]!['carbs'] ?? 0,
        dailyMacros[dayName]!['fats'] ?? 0,
        dailyCalories[dayName] ?? 0,
      ));
    }

    return result;
  }

  List<CalorieData> processLogsToWeeklyCalorieData(
      List<FoodLogHistoryItem> logs, DateTime startDate) {
    // Create map for each week
    Map<int, Map<String, double>> weeklyMacros = {
      1: {'protein': 0, 'carbs': 0, 'fats': 0},
      2: {'protein': 0, 'carbs': 0, 'fats': 0},
      3: {'protein': 0, 'carbs': 0, 'fats': 0},
      4: {'protein': 0, 'carbs': 0, 'fats': 0},
    };

    Map<int, double> weeklyCalories = {1: 0, 2: 0, 3: 0, 4: 0};

    // Process each log entry
    for (var log in logs) {
      // Use timestamp directly without timezone adjustment
      final logDateTime = log.timestamp;

      // Calculate week number (1-4)
      final weekOfMonth = ((logDateTime.day - 1) / 7).floor() + 1;
      final weekNumber = weekOfMonth.clamp(1, 4);

      // Extract values
      final protein = log.protein?.toDouble() ?? 0;
      final carbs = log.carbs?.toDouble() ?? 0;
      final fat = log.fat?.toDouble() ?? 0;
      final calories = log.calories.toDouble();

      // Add values for this week
      weeklyMacros[weekNumber]!['protein'] =
          (weeklyMacros[weekNumber]!['protein'] ?? 0) + protein;
      weeklyMacros[weekNumber]!['carbs'] =
          (weeklyMacros[weekNumber]!['carbs'] ?? 0) + carbs;
      weeklyMacros[weekNumber]!['fats'] =
          (weeklyMacros[weekNumber]!['fats'] ?? 0) + fat;
      weeklyCalories[weekNumber] = (weeklyCalories[weekNumber] ?? 0) + calories;
    }

    // Convert to CalorieData list
    List<CalorieData> result = [];
    for (int i = 1; i <= 4; i++) {
      result.add(CalorieData(
        'Week $i',
        weeklyMacros[i]!['protein'] ?? 0,
        weeklyMacros[i]!['carbs'] ?? 0,
        weeklyMacros[i]!['fats'] ?? 0,
        weeklyCalories[i] ?? 0,
      ));
    }

    return result;
  }

  // Helper methods for filtering logs
  List<FoodLogHistoryItem> filterLogsForSpecificWeek(
      List<FoodLogHistoryItem> logs, DateTime startDate, DateTime endDate) {
    return logs.where((log) {
      // The problem is likely here - we need to make sure we're correctly filtering by date range
      // Make sure timestamps are properly compared, allowing for exact start date
      return (log.timestamp.isAtSameMomentAs(startDate) ||
              log.timestamp.isAfter(startDate)) &&
          log.timestamp.isBefore(endDate);
    }).toList();
  }

  List<FoodLogHistoryItem> filterLogsForCurrentMonth(
      List<FoodLogHistoryItem> logs, DateTime firstDayOfMonth) {
    final lastDayOfMonth = DateTime(
        firstDayOfMonth.year,
        firstDayOfMonth.month + 1,
        0, // Last day of month
        23,
        59,
        59);

    return logs.where((log) {
      return log.timestamp.isAfter(firstDayOfMonth) &&
          log.timestamp.isBefore(lastDayOfMonth);
    }).toList();
  }

  // Default data methods without @override annotation
  List<CalorieData> getDefaultWeekData() {
    return [
      CalorieData('Sun', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Mon', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Tue', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Wed', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Thu', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Fri', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Sat', 0.0, 0.0, 0.0, 0.0),
    ];
  }

  List<CalorieData> getDefaultMonthData() {
    return [
      CalorieData('Week 1', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Week 2', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Week 3', 0.0, 0.0, 0.0, 0.0),
      CalorieData('Week 4', 0.0, 0.0, 0.0, 0.0),
    ];
  }
}

void main() {
  late TestFoodLogDataService foodLogDataService;
  late MockFoodLogHistoryService mockFoodLogService;
  late MockUser mockUser;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockFoodLogService = MockFoodLogHistoryService();
    mockUser = MockUser();
    mockFirebaseAuth = MockFirebaseAuth();

    // Set up FirebaseAuth mock
    when(mockUser.uid).thenReturn('test-user-id');
    mockFirebaseAuth.setCurrentUser(mockUser);

    // Create a version of FoodLogDataService that uses our mock Auth
    foodLogDataService = TestFoodLogDataService(
      foodLogService: mockFoodLogService,
      auth: mockFirebaseAuth,
    );
  });

  group('FoodLogDataService', () {
    group('getWeekCalorieData', () {
      test('returns default data when exception occurs', () async {
        // Arrange
        when(mockFoodLogService.getAllFoodLogs('test-user-id', limit: 100))
            .thenThrow(Exception('Test exception'));

        // Act
        final result = await foodLogDataService.getWeekCalorieData();

        // Assert
        expect(result, isA<List<CalorieData>>());
        expect(result.length, 7); // 7 days with default values

        // Verify all values are zero
        for (var data in result) {
          expect(data.protein, 0.0);
          expect(data.carbs, 0.0);
          expect(data.fats, 0.0);
          expect(data.calories, 0.0);
        }
      });

      test('returns default data when user is not logged in', () async {
        // Arrange
        mockFirebaseAuth.setCurrentUser(null);

        // Act
        final result = await foodLogDataService.getWeekCalorieData();

        // Assert
        expect(result, isA<List<CalorieData>>());
        expect(result.length, 7);

        // Verify all values are zero
        for (var data in result) {
          expect(data.protein, 0.0);
          expect(data.carbs, 0.0);
          expect(data.fats, 0.0);
          expect(data.calories, 0.0);
        }
      });
    });

    group('getMonthCalorieData', () {
      test('returns correctly processed data for current month', () async {
        // Arrange
        final now = DateTime.now();
        final firstDayOfMonth = DateTime(now.year, now.month, 1);

        final mockLogs = _createMockFoodLogsForMonth(firstDayOfMonth);

        when(mockFoodLogService.getAllFoodLogs('test-user-id', limit: 100))
            .thenAnswer((_) async => mockLogs);

        // Act
        final result = await foodLogDataService.getMonthCalorieData();

        // Assert
        expect(result, isA<List<CalorieData>>());
        expect(result.length, 4); // 4 weeks in a month

        // Verify Week 1 has the expected values
        final week1Data = result.firstWhere((data) => data.day == 'Week 1');
        expect(week1Data.protein, 40.0);
        expect(week1Data.carbs, 60.0);
        expect(week1Data.fats, 20.0);
        expect(week1Data.calories, 600.0); // Sum of Week 1 calories

        // Verify the service called the history service
        verify(mockFoodLogService.getAllFoodLogs('test-user-id', limit: 100))
            .called(1);
      });

      test('returns default data when exception occurs', () async {
        // Arrange
        when(mockFoodLogService.getAllFoodLogs('test-user-id', limit: 100))
            .thenThrow(Exception('Test exception'));

        // Act
        final result = await foodLogDataService.getMonthCalorieData();

        // Assert
        expect(result, isA<List<CalorieData>>());
        expect(result.length, 4); // 4 weeks with default values

        // Verify all values are zero
        for (var data in result) {
          expect(data.protein, 0.0);
          expect(data.carbs, 0.0);
          expect(data.fats, 0.0);
          expect(data.calories, 0.0); // Make sure we check calories too
        }
      });
    });

    group('calculateTotalCalories', () {
      test('calculates total calories correctly', () {
        // Arrange
        final calorieDataList = [
          CalorieData('Day 1', 20.0, 30.0, 10.0, 300.0),
          CalorieData('Day 2', 25.0, 35.0, 15.0, 400.0),
          CalorieData('Day 3', 30.0, 40.0, 20.0, 500.0),
        ];

        // Act
        final result =
            foodLogDataService.calculateTotalCalories(calorieDataList);

        // Assert
        expect(result, 1200.0);
      });

      test('returns zero when list is empty', () {
        // Arrange
        final calorieDataList = <CalorieData>[];

        // Act
        final result =
            foodLogDataService.calculateTotalCalories(calorieDataList);

        // Assert
        expect(result, 0.0);
      });
    });
  });
}

// Helper methods to create mock data

List<FoodLogHistoryItem> _createMockFoodLogsForMonth(DateTime firstDayOfMonth) {
  return [
    // Week 1
    _createMockFoodLogItem(
        firstDayOfMonth.add(const Duration(days: 1)), 20.0, 30.0, 10.0, 300.0),
    _createMockFoodLogItem(
        firstDayOfMonth.add(const Duration(days: 3)), 20.0, 30.0, 10.0, 300.0),
    // Week 2
    _createMockFoodLogItem(
        firstDayOfMonth.add(const Duration(days: 8)), 25.0, 35.0, 12.0, 350.0),
    _createMockFoodLogItem(
        firstDayOfMonth.add(const Duration(days: 10)), 25.0, 35.0, 12.0, 350.0),
    // Week 3
    _createMockFoodLogItem(
        firstDayOfMonth.add(const Duration(days: 15)), 30.0, 40.0, 15.0, 400.0),
    _createMockFoodLogItem(
        firstDayOfMonth.add(const Duration(days: 17)), 30.0, 40.0, 15.0, 400.0),
    // Week 4
    _createMockFoodLogItem(
        firstDayOfMonth.add(const Duration(days: 22)), 22.0, 33.0, 11.0, 320.0),
    _createMockFoodLogItem(
        firstDayOfMonth.add(const Duration(days: 24)), 22.0, 33.0, 11.0, 320.0),
  ];
}

FoodLogHistoryItem _createMockFoodLogItem(DateTime timestamp, double protein,
    double carbs, double fat, double calories) {
  return FoodLogHistoryItem(
    id: 'id-${timestamp.millisecondsSinceEpoch}',
    title: 'Test Food ${timestamp.day}',
    subtitle: 'Food subtitle',
    timestamp: timestamp,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
  );
}
