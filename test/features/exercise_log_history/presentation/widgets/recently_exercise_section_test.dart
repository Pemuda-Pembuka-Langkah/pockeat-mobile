import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_history_card.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/recently_exercise_section.dart';

import 'recently_exercise_section_test.mocks.dart';

// Create a mock Navigator observer to verify navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

@GenerateMocks([ExerciseLogHistoryService])
void main() {
  late MockExerciseLogHistoryService mockRepository;
  late List<ExerciseLogHistoryItem> mockExercises;
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockRepository = MockExerciseLogHistoryService();
    mockObserver = MockNavigatorObserver();

    mockExercises = [
      ExerciseLogHistoryItem(
        id: 'test-id-1',
        activityType: ExerciseLogHistoryItem.typeSmartExercise,
        title: 'Morning Run',
        subtitle: '30 minutes • 5 km',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        caloriesBurned: 350,
      ),
      ExerciseLogHistoryItem(
        id: 'test-id-2',
        activityType: ExerciseLogHistoryItem.typeWeightlifting,
        title: 'Strength Training',
        subtitle: '8 exercises',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        caloriesBurned: 280,
      ),
    ];
  });

  group('RecentlyExerciseSection Widget Tests', () {
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

      await tester.pumpAndSettle();

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

      await tester.pumpAndSettle();

      expect(find.byType(ExerciseHistoryCard), findsNWidgets(2));
      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Strength Training'), findsOneWidget);
    });

    testWidgets('displays empty state when no exercises',
        (WidgetTester tester) async {
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

      await tester.pumpAndSettle();

      expect(find.text('No exercise history yet'), findsOneWidget);
    });

    testWidgets('displays error state when repository throws',
        (WidgetTester tester) async {
      // Create a specific test exception
      final testException = Exception('Test error');
      
      // Setup the mock to throw an exception - using a straightforward approach
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 10));
            throw testException;
          });

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              repository: mockRepository,
            ),
          ),
        ),
      );

      // Wait for all pending timers and animation frames to complete
      await tester.pump(); // Initial loading state
      await tester.pump(const Duration(milliseconds: 20)); // Wait for Future to complete with error

      // Verify the error message is displayed
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

      await tester.pumpAndSettle();

      expect(find.text('Show All'), findsOneWidget);
    });

    // Test navigation indirectly by using a test-specific Navigator
    testWidgets('navigates when Show All is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => mockExercises);

      bool navigated = false;

      // Build our app with a custom navigator
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    RecentlyExerciseSection(
                      repository: mockRepository,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // This will be true if navigation was attempted
                        navigated = Navigator.of(context).canPop();
                      },
                      child: Text('Check Navigation'),
                    ),
                  ],
                );
              },
            ),
          ),
          onGenerateRoute: (settings) {
            // Mark that navigation happened
            navigated = true;
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Navigation occurred')),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Act - tap the show all button
      await tester.tap(find.text('Show All'));
      await tester.pumpAndSettle();

      // Assert - verify that navigation happened
      expect(navigated, isTrue);
    });

    testWidgets('navigates when exercise card is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => mockExercises);

      bool navigated = false;

      // Build our app with a custom navigator
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              repository: mockRepository,
            ),
          ),
          onGenerateRoute: (settings) {
            // Mark that navigation happened
            navigated = true;
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Navigation occurred')),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Act - tap the first exercise card
      await tester.tap(find.byType(ExerciseHistoryCard).first);
      await tester.pumpAndSettle();

      // Assert - verify that navigation happened
      expect(navigated, isTrue);
    });

    testWidgets('reloads exercises when repository changes',
        (WidgetTester tester) async {
      // Arrange - First repository
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => mockExercises);

      final testKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              key: testKey,
              repository: mockRepository,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Create a new mock repository
      final newMockRepository = MockExerciseLogHistoryService();
      final newMockExercises = [
        ExerciseLogHistoryItem(
          id: 'new-test-id',
          activityType: ExerciseLogHistoryItem.typeCardio,
          title: 'New Exercise',
          subtitle: 'New subtitle',
          timestamp: DateTime.now(),
          caloriesBurned: 200,
        ),
      ];

      when(newMockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => newMockExercises);

      // Act - Rebuild with new repository
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              key: testKey,
              repository: newMockRepository,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      verify(newMockRepository.getAllExerciseLogs(limit: 5)).called(1);
      expect(find.text('New Exercise'), findsOneWidget);
    });

    testWidgets('reloads exercises when limit changes',
        (WidgetTester tester) async {
      // Arrange - First limit
      when(mockRepository.getAllExerciseLogs(limit: 5))
          .thenAnswer((_) async => mockExercises);

      final testKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              key: testKey,
              repository: mockRepository,
              limit: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Setup for new limit
      when(mockRepository.getAllExerciseLogs(limit: 3))
          .thenAnswer((_) async => mockExercises.take(1).toList());

      // Act - Rebuild with new limit
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentlyExerciseSection(
              key: testKey,
              repository: mockRepository,
              limit: 3,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      verify(mockRepository.getAllExerciseLogs(limit: 3)).called(1);
      // Only one exercise card should be visible now
      expect(find.byType(ExerciseHistoryCard), findsOneWidget);
    });
  });
}
