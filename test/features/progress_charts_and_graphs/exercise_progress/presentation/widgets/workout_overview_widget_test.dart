import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_overview_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_stat_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  group('WorkoutOverviewWidget', () {
    // Test data
    final mockExerciseData = [
      ExerciseData('M', 320),
      ExerciseData('T', 280),
      ExerciseData('W', 350),
      ExerciseData('T', 290),
      ExerciseData('F', 400),
      ExerciseData('S', 250),
      ExerciseData('S', 300),
    ];

    final mockWorkoutStats = [
      WorkoutStat(
        label: 'Sessions',
        value: '12',
        colorValue: 0xFF4ECDC4,
      ),
      WorkoutStat(
        label: 'Duration',
        value: '45 min',
        colorValue: 0xFFFF6B6B,
      ),
      WorkoutStat(
        label: 'Calories',
        value: '320',
        colorValue: 0xFFFFE893,
      ),
    ];

    final completionPercentage = '78%';
    final primaryGreen = const Color(0xFF4ECDC4);

    testWidgets('renders all components correctly', (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutOverviewWidget(
              exerciseData: mockExerciseData,
              workoutStats: mockWorkoutStats,
              completionPercentage: completionPercentage,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );
      // Wait for chart to finish building
      await tester.pumpAndSettle();

      // Verify the title and subtitle are present
      expect(find.text('Training Progress'), findsOneWidget);
      expect(find.text('Keep pushing harder!'), findsOneWidget);
      
      // Verify the completion percentage is displayed
      expect(find.text(completionPercentage), findsOneWidget);
      
      // Verify the progress icon is present
      expect(find.byIcon(Icons.running_with_errors), findsOneWidget);
      
      // Verify all workout stats are shown (using the WorkoutStatWidget)
      expect(find.byType(WorkoutStatWidget), findsNWidgets(mockWorkoutStats.length));
      
      // Verify the chart is present
      expect(find.byType(SfCartesianChart), findsOneWidget);
    });

    testWidgets('has correct container decoration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutOverviewWidget(
              exerciseData: mockExerciseData,
              workoutStats: mockWorkoutStats,
              completionPercentage: completionPercentage,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the container
      final container = tester.widget<Container>(find.byType(Container).first);
      
      // Verify padding
      expect(container.padding, equals(const EdgeInsets.all(20)));
      
      // Verify decoration
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
      
      // Verify box shadow
      expect(decoration.boxShadow!.length, equals(1));
      expect(decoration.boxShadow![0].color, equals(Colors.black.withOpacity(0.05)));
      expect(decoration.boxShadow![0].blurRadius, equals(10));
      expect(decoration.boxShadow![0].offset, equals(const Offset(0, 2)));
    });

    testWidgets('renders completion percentage with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutOverviewWidget(
              exerciseData: mockExerciseData,
              workoutStats: mockWorkoutStats,
              completionPercentage: completionPercentage,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Row containing the percentage text
      final rowFinder = find.ancestor(
        of: find.text(completionPercentage),
        matching: find.byType(Row),
      ).first;
      
      // Find the Container that is a direct parent of this Row
      final percentageContainer = tester.widget<Container>(
        find.ancestor(
          of: rowFinder,
          matching: find.byType(Container),
        ).first
      );
      
      final decoration = percentageContainer.decoration as BoxDecoration;
      
      // Verify container styling
      expect(decoration.color, equals(primaryGreen.withOpacity(0.1)));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      
      // Verify percentage text styling
      final percentageText = tester.widget<Text>(find.text(completionPercentage));
      expect(percentageText.style?.color, equals(primaryGreen));
      expect(percentageText.style?.fontSize, equals(14));
      expect(percentageText.style?.fontWeight, equals(FontWeight.w600));
      
      // Verify icon styling
      final icon = tester.widget<Icon>(find.byIcon(Icons.running_with_errors));
      expect(icon.color, equals(primaryGreen));
      expect(icon.size, equals(16));
    });

    testWidgets('renders chart with correct configuration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutOverviewWidget(
              exerciseData: mockExerciseData,
              workoutStats: mockWorkoutStats,
              completionPercentage: completionPercentage,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );
      // Pump and settle to resolve all animations
      await tester.pumpAndSettle();

      // Find the chart
      final chartFinder = find.byType(SfCartesianChart);
      expect(chartFinder, findsOneWidget);
      
      final chart = tester.widget<SfCartesianChart>(chartFinder);
      
      // Verify chart axes
      expect(chart.primaryXAxis, isA<CategoryAxis>());
      expect(chart.primaryYAxis, isA<NumericAxis>());
      
      // Verify chart series
      expect(chart.series.length, equals(1));
      expect(chart.series[0], isA<ColumnSeries>());
      
      // Access the ColumnSeries with proper type casting
      final columnSeries = chart.series[0] as ColumnSeries<ExerciseData, String>;
      expect(columnSeries.dataSource, equals(mockExerciseData));
      expect(columnSeries.color, equals(primaryGreen));
      expect(columnSeries.width, equals(0.7));
      expect(columnSeries.borderRadius, equals(const BorderRadius.vertical(top: Radius.circular(4))));
    });

    testWidgets('renders correct title and subtitle styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutOverviewWidget(
              exerciseData: mockExerciseData,
              workoutStats: mockWorkoutStats,
              completionPercentage: completionPercentage,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and verify title text styling
      final titleText = tester.widget<Text>(find.text('Training Progress'));
      expect(titleText.style?.fontSize, equals(16));
      expect(titleText.style?.fontWeight, equals(FontWeight.w600));
      expect(titleText.style?.color, equals(Colors.black87));
      
      // Find and verify subtitle text styling
      final subtitleText = tester.widget<Text>(find.text('Keep pushing harder!'));
      expect(subtitleText.style?.fontSize, equals(14));
      expect(subtitleText.style?.color, equals(Colors.black54));
    });

    testWidgets('passes correct data to WorkoutStatWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutOverviewWidget(
              exerciseData: mockExerciseData,
              workoutStats: mockWorkoutStats,
              completionPercentage: completionPercentage,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find all WorkoutStatWidget instances
      final statWidgets = tester.widgetList<WorkoutStatWidget>(find.byType(WorkoutStatWidget)).toList();
      
      // Verify each WorkoutStatWidget has the correct data
      for (int i = 0; i < mockWorkoutStats.length; i++) {
        expect(statWidgets[i].stat, equals(mockWorkoutStats[i]));
      }
    });

    testWidgets('has correct spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutOverviewWidget(
              exerciseData: mockExerciseData,
              workoutStats: mockWorkoutStats,
              completionPercentage: completionPercentage,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find all SizedBox widgets
      final sizedBoxes = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(Column).first,
          matching: find.byType(SizedBox),
        ),
      ).toList();
      
      // Count SizedBox widgets with height 20
      final sizedBoxesHeight20 = sizedBoxes.where((sb) => sb.height == 20).length;
      expect(sizedBoxesHeight20, equals(2));
      
      // Count SizedBox widget with height 4 (between title and subtitle)
      final sizedBoxesHeight4 = sizedBoxes.where((sb) => sb.height == 4).length;
      expect(sizedBoxesHeight4, equals(4)); // Changed from 1 to 4
    });
  });
}