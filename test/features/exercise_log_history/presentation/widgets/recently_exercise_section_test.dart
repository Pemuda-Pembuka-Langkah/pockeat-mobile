import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/recently_exercise_section.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'recently_exercise_section_test.mocks.dart';

@GenerateMocks([
  ExerciseLogHistoryService,
  FirebaseAuth,
  User,
  NavigatorObserver,
])
void main() {
  late MockExerciseLogHistoryService mockRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  const String testUserId = 'test-user-123';

  setUp(() {
    mockRepository = MockExerciseLogHistoryService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Setup Firebase Auth mock
    when(mockUser.uid).thenReturn(testUserId);
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
  });

  group('RecentlyExerciseSection Widget Tests', () {
    final mockExercises = [
      ExerciseLogHistoryItem(
        id: '1',
        activityType: ExerciseLogHistoryItem.typeCardio,
        title: 'Morning Run',
        subtitle: '30 min • 300 kcal',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        caloriesBurned: 300,
        sourceId: 'cardio-1',
      ),
      ExerciseLogHistoryItem(
        id: '2',
        activityType: ExerciseLogHistoryItem.typeWeightlifting,
        title: 'Gym Workout',
        subtitle: '45 min • 400 kcal',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        caloriesBurned: 400,
        sourceId: 'weight-1',
      ),
    ];

    Widget buildTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: RecentlyExerciseSection(
            repository: mockRepository,
            auth: mockFirebaseAuth,
          ),
        ),
      );
    }

    testWidgets('displays title correctly', (WidgetTester tester) async {
      final completer = Completer<List<ExerciseLogHistoryItem>>();
      when(mockRepository.getAllExerciseLogs(testUserId, limit: 5))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Recent Exercises'), findsOneWidget);
    });

    testWidgets('displays loading state', (WidgetTester tester) async {
      final completer = Completer<List<ExerciseLogHistoryItem>>();
      when(mockRepository.getAllExerciseLogs(testUserId, limit: 5))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays exercises', (WidgetTester tester) async {
      when(mockRepository.getAllExerciseLogs(testUserId, limit: 5))
          .thenAnswer((_) async => mockExercises);

      await tester.pumpWidget(buildTestWidget());

      // Initial pump to start building
      await tester.pump();

      // Allow the future to complete
      await tester.pump(const Duration(milliseconds: 50));

      // Check that the exercise titles are displayed in the widget tree
      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Gym Workout'), findsOneWidget);
    });

    testWidgets('displays empty state when no exercises',
        (WidgetTester tester) async {
      when(mockRepository.getAllExerciseLogs(testUserId, limit: 5))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('No exercise history yet'), findsOneWidget);
    });

    testWidgets('displays error state when fetch fails',
        (WidgetTester tester) async {
      // Arrange
      final completer = Completer<List<ExerciseLogHistoryItem>>();
      
      when(mockRepository.getAllExerciseLogs(testUserId, limit: 5))
          .thenAnswer((_) => completer.future);

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(); // Render frame pertama

      // Complete dengan error
      completer.completeError('Network error');
      
      // Tunggu frame setelah error
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error loading exercises: Network error'), findsOneWidget);
    });
  });
}
