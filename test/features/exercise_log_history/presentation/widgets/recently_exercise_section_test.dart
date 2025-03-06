import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/domain/repositories/exercise_log_history_repository.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_history_card.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/recently_exercise_section.dart';

// Generate mock class
@GenerateMocks([ExerciseLogHistoryRepository])
import 'recently_exercise_section_test.mocks.dart';

void main() {
  late MockExerciseLogHistoryRepository mockRepository;
  
  setUp(() {
    mockRepository = MockExerciseLogHistoryRepository();
  });

  group('RecentlyExerciseSection Widget Tests', () {
    final mockExercises = [
      ExerciseLogHistoryItem(
        id: 'test-id-1',
        activityType: ExerciseLogHistoryItem.TYPE_SMART_EXERCISE,
        title: 'HIIT Workout',
        subtitle: '25 min • 320 cal',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        caloriesBurned: 320,
      ),
      ExerciseLogHistoryItem(
        id: 'test-id-2',
        activityType: ExerciseLogHistoryItem.TYPE_CARDIO,
        title: 'Evening Run',
        subtitle: '5.2 km • 350 cal',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        caloriesBurned: 350,
      ),
    ];

    testWidgets('displays title correctly', (WidgetTester tester) async {
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => mockExercises);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              repository: mockRepository,
            ),
          ),
        ),
      );
      
      await tester.pump(Duration.zero);
      
      expect(find.text('Recent Exercises'), findsOneWidget);
    });

    testWidgets('displays exercise cards', (WidgetTester tester) async {
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => mockExercises);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              repository: mockRepository,
            ),
          ),
        ),
      );
      
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
      
      expect(find.byType(ExerciseHistoryCard), findsNWidgets(2));
    });

    testWidgets('shows empty state when no exercises', (WidgetTester tester) async {
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => []);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              repository: mockRepository,
            ),
          ),
        ),
      );
      
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
      
      expect(find.text('No exercise history yet'), findsOneWidget);
    });

    testWidgets('shows error state when repository throws error', (WidgetTester tester) async {
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => throw Exception('Test error'));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              repository: mockRepository,
            ),
          ),
        ),
      );
      
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
      
      expect(find.textContaining('Error loading exercises'), findsOneWidget);
    });

    testWidgets('has Show All button', (WidgetTester tester) async {
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => mockExercises);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              repository: mockRepository,
            ),
          ),
        ),
      );
      
      await tester.pump(Duration.zero);
      
      expect(find.text('Show All'), findsOneWidget);
    });
  });
}
