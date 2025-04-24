// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_history_card.dart';

void main() {
  late ExerciseLogHistoryItem smartExerciseItem;
  late ExerciseLogHistoryItem cardioItem;
  late ExerciseLogHistoryItem weightliftingItem;

  setUp(() {
    // Create test data
    final now = DateTime.now();

    smartExerciseItem = ExerciseLogHistoryItem(
      id: 'test-id-1',
      activityType: ExerciseLogHistoryItem.typeSmartExercise,
      title: 'HIIT Workout',
      subtitle: '25 min • 320 cal',
      timestamp: now.subtract(const Duration(hours: 2)),
      caloriesBurned: 320,
    );

    cardioItem = ExerciseLogHistoryItem(
      id: 'test-id-2',
      activityType: ExerciseLogHistoryItem.typeCardio,
      title: 'Evening Run',
      subtitle: '5.2 km • 350 cal',
      timestamp: now.subtract(const Duration(days: 1)),
      caloriesBurned: 350,
    );

    weightliftingItem = ExerciseLogHistoryItem(
      id: 'test-id-3',
      activityType: ExerciseLogHistoryItem.typeWeightlifting,
      title: 'Upper Body',
      subtitle: '6 exercises • 280 cal',
      timestamp: now.subtract(const Duration(days: 2)),
      caloriesBurned: 280,
    );
  });

  testWidgets('ExerciseHistoryCard displays title correctly',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseHistoryCard(
            exercise: smartExerciseItem,
          ),
        ),
      ),
    );

    // Verify that the title is displayed correctly
    expect(find.text('HIIT Workout'), findsOneWidget);
  });
  
  testWidgets('ExerciseHistoryCard has RichText for subtitle', 
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseHistoryCard(
            exercise: smartExerciseItem,
          ),
        ),
      ),
    );
    
    // Verify that the RichText widget exists
    expect(find.byType(RichText), findsAtLeastNWidgets(1));
  });

  testWidgets('ExerciseHistoryCard displays correct timeAgo',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseHistoryCard(
            exercise: smartExerciseItem,
          ),
        ),
      ),
    );

    // Verify that the timeAgo is displayed
    expect(find.text('2h ago'), findsOneWidget);
  });

  testWidgets('ExerciseHistoryCard shows correct icon for smart exercise',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseHistoryCard(
            exercise: smartExerciseItem,
          ),
        ),
      ),
    );

    // Verify that the correct icon is displayed
    expect(find.byIcon(CupertinoIcons.text_badge_checkmark), findsOneWidget);
  });

  testWidgets('ExerciseHistoryCard shows correct icon for cardio',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseHistoryCard(
            exercise: cardioItem,
          ),
        ),
      ),
    );

    // Verify that the correct icon is displayed
    expect(find.byIcon(Icons.directions_run), findsOneWidget);
  });

  testWidgets('ExerciseHistoryCard shows correct icon for weightlifting',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseHistoryCard(
            exercise: weightliftingItem,
          ),
        ),
      ),
    );

    // Verify that the correct icon is displayed
    expect(find.byIcon(CupertinoIcons.arrow_up_circle_fill), findsOneWidget);
  });

  testWidgets('ExerciseHistoryCard calls onTap callback when tapped',
      (WidgetTester tester) async {
    bool wasTapped = false;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseHistoryCard(
            exercise: smartExerciseItem,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    // Tap the card
    await tester.tap(find.byType(InkWell));

    // Verify that the callback was called
    expect(wasTapped, true);
  });
}
