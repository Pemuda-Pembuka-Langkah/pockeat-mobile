// Flutter imports:
import 'dart:async';

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

      // Setup mock responses with Completer to avoid pending timers
      final completer = Completer<DailyCalorieStats>();

      // Use immediate responses instead of delayed futures to avoid pending timers
      when(() => mockCalorieStatsService.calculateStatsForDate(any(), any()))
          .thenAnswer((_) => completer.future);

      when(() =>
              mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) => Future.value(false));

      when(() => mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) => Future.value(false));

      when(() => mockUserPreferencesService.getRolloverCalories())
          .thenAnswer((_) => Future.value(0));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaloriesTodayWidget(targetCalories: 2000),
          ),
        ),
      );

      // Assert - should show loading indicator since data is not yet available
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid pending timers
      completer.complete(dailyStats);

      // Pump a small amount to process futures but don't wait for animations
      await tester.pump(const Duration(milliseconds: 50));
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

      when(() => mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) => Future.value(false));

      when(() => mockUserPreferencesService.getRolloverCalories())
          .thenAnswer((_) => Future.value(0));

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
      // Should NOT display the rollover calories badge
      expect(find.byIcon(Icons.update), findsNothing);
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

      when(() => mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) => Future.value(false));

      when(() => mockUserPreferencesService.getRolloverCalories())
          .thenAnswer((_) => Future.value(0));

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
      // Should show fire icon for exercise compensation
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets(
        'should display remaining calories with rollover when rollover feature is enabled',
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

      when(() => mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) => Future.value(true));

      when(() => mockUserPreferencesService.getRolloverCalories())
          .thenAnswer((_) => Future.value(500));

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
      // Target (2000) + rollover (500) - consumed (1200) = 1300 remaining calories
      expect(find.text('1300'), findsOneWidget);
      // Should display the rollover calories badge with update icon
      expect(find.text('+500'), findsOneWidget);
      expect(find.byIcon(Icons.update), findsOneWidget);
    });

    testWidgets(
        'should display both rollover and exercise calories when both features are enabled',
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

      when(() => mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) => Future.value(true));

      when(() => mockUserPreferencesService.getRolloverCalories())
          .thenAnswer((_) => Future.value(500));

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
      // Target (2000) + burned (300) + rollover (500) - consumed (1200) = 1600 remaining calories
      expect(find.text('1600'), findsOneWidget);
      // Should display both badges
      expect(find.text('+300'), findsOneWidget);
      expect(find.text('+500'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.update), findsOneWidget);
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

      when(() => mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) => Future.value(false));

      when(() => mockUserPreferencesService.getRolloverCalories())
          .thenAnswer((_) => Future.value(0));

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

      when(() => mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) => Future.value(false));

      when(() => mockUserPreferencesService.getRolloverCalories())
          .thenAnswer((_) => Future.value(0));

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

    testWidgets(
        'should display correct completion percentage with rollover calories',
        (WidgetTester tester) async {
      // Arrange
      final dailyStats = DailyCalorieStats(
        userId: 'test-user',
        date: DateTime.now(),
        caloriesBurned: 0,
        caloriesConsumed: 1000,
      );

      // Setup mock responses
      when(() => mockCalorieStatsService.calculateStatsForDate(any(), any()))
          .thenAnswer((_) => Future.value(dailyStats));

      when(() =>
              mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) => Future.value(false));

      when(() => mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) => Future.value(true));

      when(() => mockUserPreferencesService.getRolloverCalories())
          .thenAnswer((_) => Future.value(1000));

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
      // Consumed (1000) / (Target (2000) + Rollover (1000)) = 33%
      expect(find.text('33%'), findsOneWidget);
    });
  });
}
