// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/homepage/presentation/widgets/calories_today_widget.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

// Mock classes
class MockCalorieStatsService extends Mock implements CalorieStatsService {}

class MockUserPreferencesService extends Mock
    implements UserPreferencesService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late GetIt getIt;
  late MockCalorieStatsService mockCalorieStatsService;
  late MockUserPreferencesService mockUserPreferencesService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    // Initialize GetIt
    getIt = GetIt.instance;

    // Create mock services
    mockCalorieStatsService = MockCalorieStatsService();
    mockUserPreferencesService = MockUserPreferencesService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Configure mocks
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user');

    // Register mocks with GetIt
    if (getIt.isRegistered<CalorieStatsService>()) {
      getIt.unregister<CalorieStatsService>();
    }
    if (getIt.isRegistered<UserPreferencesService>()) {
      getIt.unregister<UserPreferencesService>();
    }
    if (getIt.isRegistered<FirebaseAuth>()) {
      getIt.unregister<FirebaseAuth>();
    }

    getIt.registerSingleton<CalorieStatsService>(mockCalorieStatsService);
    getIt.registerSingleton<UserPreferencesService>(mockUserPreferencesService);
    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
  });

  tearDown(() {
    // Clean up GetIt
    getIt.reset();
  });

  group('CaloriesTodayWidget', () {
    testWidgets('should display loading indicator while data is loading',
        (WidgetTester tester) async {
      // Arrange
      final dailyStats = DailyCalorieStats(
        userId: 'test-user',
        date: DateTime.now(),
        caloriesBurned: 300,
        caloriesConsumed: 1200,
      );

      // Setup mock responses with Future.delayed to simulate loading
      when(() => mockCalorieStatsService.calculateStatsForDate(any(), any()))
          .thenAnswer((_) =>
              Future.delayed(const Duration(seconds: 1), () => dailyStats));

      when(() =>
              mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer(
              (_) => Future.delayed(const Duration(seconds: 1), () => false));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaloriesTodayWidget(targetCalories: 2000),
          ),
        ),
      );

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'should display remaining calories without compensation when feature is disabled',
        (WidgetTester tester) async {
      // Arrange
      final dailyStats = DailyCalorieStats(
        userId: 'test-user',
        date: DateTime.now(),
        caloriesBurned: 300,
        caloriesConsumed: 1200,
      );

      // Setup mock responses
      when(() => mockCalorieStatsService.calculateStatsForDate(any(), any()))
          .thenAnswer((_) => Future.value(dailyStats));

      when(() =>
              mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) => Future.value(false));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaloriesTodayWidget(targetCalories: 2000),
          ),
        ),
      );

      // Wait for futures to complete
      await tester.pumpAndSettle();

      // Assert
      // Target (2000) - consumed (1200) = 800 remaining calories
      expect(find.text('800'), findsOneWidget);
      // Should NOT display the calories burned badge
      expect(find.text('+300'), findsNothing);
    });

    testWidgets(
        'should display remaining calories with compensation when feature is enabled',
        (WidgetTester tester) async {
      // Arrange
      final dailyStats = DailyCalorieStats(
        userId: 'test-user',
        date: DateTime.now(),
        caloriesBurned: 300,
        caloriesConsumed: 1200,
      );

      // Setup mock responses
      when(() => mockCalorieStatsService.calculateStatsForDate(any(), any()))
          .thenAnswer((_) => Future.value(dailyStats));

      when(() =>
              mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) => Future.value(true));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaloriesTodayWidget(targetCalories: 2000),
          ),
        ),
      );

      // Wait for futures to complete
      await tester.pumpAndSettle();

      // Assert
      // Target (2000) + burned (300) - consumed (1200) = 1100 remaining calories
      expect(find.text('1100'), findsOneWidget);
      // Should display the calories burned badge
      expect(find.text('+300'), findsOneWidget);
    });

    testWidgets(
        'should display correct completion percentage without compensation',
        (WidgetTester tester) async {
      // Arrange
      final dailyStats = DailyCalorieStats(
        userId: 'test-user',
        date: DateTime.now(),
        caloriesBurned: 300,
        caloriesConsumed: 1000,
      );

      // Setup mock responses
      when(() => mockCalorieStatsService.calculateStatsForDate(any(), any()))
          .thenAnswer((_) => Future.value(dailyStats));

      when(() =>
              mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) => Future.value(false));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaloriesTodayWidget(targetCalories: 2000),
          ),
        ),
      );

      // Wait for futures to complete
      await tester.pumpAndSettle();

      // Assert
      // Consumed (1000) / Target (2000) = 50%
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets(
        'should display correct completion percentage with compensation',
        (WidgetTester tester) async {
      // Arrange
      final dailyStats = DailyCalorieStats(
        userId: 'test-user',
        date: DateTime.now(),
        caloriesBurned: 1000,
        caloriesConsumed: 1000,
      );

      // Setup mock responses
      when(() => mockCalorieStatsService.calculateStatsForDate(any(), any()))
          .thenAnswer((_) => Future.value(dailyStats));

      when(() =>
              mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) => Future.value(true));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaloriesTodayWidget(targetCalories: 2000),
          ),
        ),
      );

      // Wait for futures to complete
      await tester.pumpAndSettle();

      // Assert
      // Consumed (1000) / (Target (2000) + Burned (1000)) = 33%
      expect(find.text('33%'), findsOneWidget);
    });
  });
}
