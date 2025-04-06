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
      userId: 'test-user-id',
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
      expect(find.text('Chest'), findsAtLeastNWidgets(1)); // May appear multiple times in redesign
      
      // Assert - Check for date and time elements - more flexible test
      final date = weightLiftingExercise.timestamp;
      // Just check for day, month, and year separately as they might appear in different formats
      expect(find.textContaining('${date.year}'), findsAtLeastNWidgets(1));
      expect(find.textContaining('${date.day}'), findsAtLeastNWidgets(1));
      
      // Assert - Check info cards - more flexible test
      expect(find.text('Sets'), findsAtLeastNWidgets(1));
      expect(find.text('2'), findsAtLeastNWidgets(1)); // At least one '2' for total sets
      expect(find.text('Reps'), findsAtLeastNWidgets(1));
      
      // Assert - Set titles should be displayed
      expect(find.text('Set 1'), findsOneWidget);
      expect(find.text('Set 2'), findsOneWidget);
      
      // Assert - Weight values should be displayed in some form
      expect(find.textContaining('60'), findsAtLeastNWidgets(1)); 
      expect(find.textContaining('65'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle exercise with no sets', (WidgetTester tester) async {
      // Arrange - Create exercise with empty sets list
      final emptySetExercise = WeightLifting(
        id: 'weight-empty',
        name: 'Empty Sets Exercise',
        bodyPart: 'Test',
        metValue: 5.0,
        userId: 'test-user-id',
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
      expect(find.text('Test'), findsAtLeastNWidgets(1)); // May appear multiple times in redesign
      
      // Assert - Empty sets should be handled gracefully
      expect(find.text('No sets recorded for this exercise'), findsOneWidget);
    });
  });
}
