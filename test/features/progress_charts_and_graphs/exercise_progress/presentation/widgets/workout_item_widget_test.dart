import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_item.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_item_widget.dart';

void main() {
  group('WorkoutItemWidget', () {
    final mockWorkout = WorkoutItem(
      title: 'Morning Run',
      type: 'Cardio',
      stats: '5.2 km • 320 cal',
      time: '2h ago',
      colorValue: 0xFFFF6B6B, // Pink color
    );

    testWidgets('renders all workout information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutItemWidget(workout: mockWorkout),
          ),
        ),
      );

      // Verify the workout title is displayed
      expect(find.text('Morning Run'), findsOneWidget);
      
      // Verify the workout type is displayed
      expect(find.text('Cardio'), findsOneWidget);
      
      // Verify the stats are displayed
      expect(find.text('5.2 km • 320 cal'), findsOneWidget);
      
      // Verify the time is displayed
      expect(find.text('2h ago'), findsOneWidget);
      
      // Verify the bullet point separator is displayed
      expect(find.text(' • '), findsOneWidget);
      
      // Verify the fitness icon is displayed
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('applies correct styling to container and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutItemWidget(workout: mockWorkout),
          ),
        ),
      );

      // Find the container
      final containerFinder = find.ancestor(
        of: find.byIcon(Icons.fitness_center),
        matching: find.byType(Container),
      );
      
      final container = tester.widget<Container>(containerFinder);
      
      // Verify container decoration
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Color(0xFFFF6B6B).withOpacity(0.1)));
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
      
      // Verify icon color
      final icon = tester.widget<Icon>(find.byIcon(Icons.fitness_center));
      expect(icon.color, equals(const Color(0xFFFF6B6B)));
      
      // Verify container constraints indirectly by checking the render object
      final RenderBox box = tester.renderObject(containerFinder);
      expect(box.size.width, equals(40));
      expect(box.size.height, equals(40));
    });

    testWidgets('applies correct text styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutItemWidget(workout: mockWorkout),
          ),
        ),
      );

      // Verify title text style
      final titleText = tester.widget<Text>(find.text('Morning Run'));
      expect(titleText.style?.fontSize, equals(14));
      expect(titleText.style?.fontWeight, equals(FontWeight.w500));
      expect(titleText.style?.color, equals(Colors.black87));
      
      // Verify type text style
      final typeText = tester.widget<Text>(find.text('Cardio'));
      expect(typeText.style?.fontSize, equals(12));
      expect(typeText.style?.fontWeight, equals(FontWeight.w500));
      expect(typeText.style?.color, equals(const Color(0xFFFF6B6B)));
      
      // Verify stats text style
      final statsText = tester.widget<Text>(find.text('5.2 km • 320 cal'));
      expect(statsText.style?.fontSize, equals(12));
      expect(statsText.style?.color, equals(Colors.black54));
      
      // Verify time text style
      final timeText = tester.widget<Text>(find.text('2h ago'));
      expect(timeText.style?.fontSize, equals(12));
      expect(timeText.style?.color, equals(Colors.black54));
    });

    testWidgets('has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutItemWidget(workout: mockWorkout),
          ),
        ),
      );

      // Verify main Row exists
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      
      // Verify Expanded widget wraps the Column
      expect(find.byType(Expanded), findsOneWidget);
      
      // Instead of looking for specific widgets with measurements,
      // verify the overall structure is correct
      final workoutItemFinder = find.byType(WorkoutItemWidget);
      expect(workoutItemFinder, findsOneWidget);
      
      // Verify that a Container, SizedBox, Expanded, and Text widgets exist in that order
      final rowFinder = find.descendant(
        of: workoutItemFinder,
        matching: find.byType(Row).first,
      );
      
      final row = tester.widget<Row>(rowFinder);
      expect(row.children.length, equals(4)); // Container, SizedBox, Expanded, Text
      expect(row.children[0], isA<Container>());
      expect(row.children[1], isA<SizedBox>());
      expect(row.children[2], isA<Expanded>());
      expect(row.children[3], isA<Text>());
      
      // Verify Column for text content exists and has correct crossAxisAlignment
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(Expanded),
          matching: find.byType(Column),
        ).first
      );
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
    });

    testWidgets('renders with different workout data', (WidgetTester tester) async {
      final differentWorkout = WorkoutItem(
        title: 'Evening Gym',
        type: 'Weightlifting',
        stats: '45 min • 280 cal',
        time: '1d ago',
        colorValue: 0xFF4ECDC4, // Green color
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutItemWidget(workout: differentWorkout),
          ),
        ),
      );

      // Verify the workout data is displayed correctly
      expect(find.text('Evening Gym'), findsOneWidget);
      expect(find.text('Weightlifting'), findsOneWidget);
      expect(find.text('45 min • 280 cal'), findsOneWidget);
      expect(find.text('1d ago'), findsOneWidget);
      
      // Verify the color is applied correctly
      final typeText = tester.widget<Text>(find.text('Weightlifting'));
      expect(typeText.style?.color, equals(const Color(0xFF4ECDC4)));
      
      // Check container color
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.fitness_center),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Color(0xFF4ECDC4).withOpacity(0.1)));
    });
  });
}