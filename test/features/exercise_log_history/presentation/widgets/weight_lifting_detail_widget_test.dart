import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/weight_lifting_detail_widget.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

void main() {
  group('WeightLiftingDetailWidget', () {
    // Sample weight lifting data for testing
    final weightLiftingSet1 = WeightLiftingSet(
      weight: 60.0,
      reps: 12,
      duration: 45.0,
    );
    
    final weightLiftingSet2 = WeightLiftingSet(
      weight: 65.0,
      reps: 10,
      duration: 40.0,
    );
    
    final weightLiftingExercise = WeightLifting(
      id: 'weight-1',
      name: 'Bench Press',
      bodyPart: 'Chest',
      metValue: 6.0,
      timestamp: DateTime(2025, 3, 5, 15, 30), // 3:30 PM
      sets: [weightLiftingSet1, weightLiftingSet2],
    );

    testWidgets('should display weight lifting exercise details correctly', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: WeightLiftingDetailWidget(
            weightLifting: weightLiftingExercise,
          ),
        ),
      ));

      // Assert - Basic exercise info should be displayed
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Body Part: Chest'), findsOneWidget);
      
      // Assert - Check formatted info rows
      expect(find.text('MET Value'), findsOneWidget);
      expect(find.text('6.0'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('5/3/2025'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('15:30'), findsOneWidget);
      expect(find.text('Number of Sets'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      
      // Assert - Set titles should be displayed
      expect(find.text('Sets'), findsOneWidget);
      expect(find.text('Set 1'), findsOneWidget);
      expect(find.text('Set 2'), findsOneWidget);
      
      // Assert - Set details should be displayed
      expect(find.text('Weight (kg)'), findsNWidgets(2));
      expect(find.text('60.0'), findsOneWidget);
      expect(find.text('65.0'), findsOneWidget);
      expect(find.text('Repetitions'), findsNWidgets(2));
      expect(find.text('12'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Duration (sec)'), findsNWidgets(2));
      expect(find.text('45.0'), findsOneWidget);
      expect(find.text('40.0'), findsOneWidget);
    });

    testWidgets('should handle exercise with no sets', (WidgetTester tester) async {
      // Arrange - Create exercise with empty sets list
      final emptySetExercise = WeightLifting(
        id: 'weight-empty',
        name: 'Empty Sets Exercise',
        bodyPart: 'Test',
        metValue: 5.0,
        timestamp: DateTime(2025, 3, 6),
        sets: [],
      );
      
      // Act - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: WeightLiftingDetailWidget(
            weightLifting: emptySetExercise,
          ),
        ),
      ));

      // Assert - Basic info should still be displayed
      expect(find.text('Empty Sets Exercise'), findsOneWidget);
      expect(find.text('Body Part: Test'), findsOneWidget);
      expect(find.text('Number of Sets'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      
      // Assert - Sets heading should still be displayed, but no set cards
      expect(find.text('Sets'), findsOneWidget);
      expect(find.text('Set 1'), findsNothing);
    });
  });
}
