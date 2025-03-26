import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/nutrition_stat_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/progress_overview_widget.dart';

void main() {
  group('ProgressOverviewWidget', () {
    // Test data
    final calorieData = [
      CalorieData('M', 1800),
      CalorieData('T', 2100),
      CalorieData('W', 1950),
      CalorieData('T', 2200),
      CalorieData('F', 1750),
      CalorieData('S', 1900),
      CalorieData('S', 2050),
    ];

    final nutritionStats = [
      NutritionStat(
        label: 'Consumed',
        value: '1,850',
        color: const Color(0xFFFF6B6B), // Pink color
      ),
      NutritionStat(
        label: 'Burned',
        value: '450',
        color: const Color(0xFF4ECDC4), // Green color
      ),
      NutritionStat(
        label: 'Net',
        value: '1,400',
        color: const Color(0xFFFF6B6B), // Pink color
      ),
    ];

    final primaryGreen = const Color(0xFF4ECDC4);
    final primaryPink = const Color(0xFFFF6B6B);

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ProgressOverviewWidget(
            calorieData: calorieData,
            nutritionStats: nutritionStats,
            primaryGreen: primaryGreen,
            primaryPink: primaryPink,
          ),
        ),
      );
    }

    Widget createLoadingTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ProgressOverviewWidget(
            calorieData: calorieData,
            nutritionStats: nutritionStats,
            primaryGreen: primaryGreen,
            primaryPink: primaryPink,
            isLoading: true,
          ),
        ),
      );
    }

    testWidgets('renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(ProgressOverviewWidget), findsOneWidget);
    });

    testWidgets('renders with correct container styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Find Container by ancestor/descendant relationship to be more specific
      final containerFinder = find.ancestor(
        of: find.text('Daily Progress'),
        matching: find.byType(Container),
      ).first;
      
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      
      // Verify container styling
      expect(container.padding, equals(const EdgeInsets.all(20)));
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
      
      // Verify box shadow
      expect(decoration.boxShadow?.length, equals(1));
      final shadow = decoration.boxShadow![0];
      expect(shadow.color.alpha, equals(Colors.black.withOpacity(0.05).alpha));
      expect(shadow.blurRadius, equals(10));
      expect(shadow.offset, equals(const Offset(0, 2)));
    });

    testWidgets('renders header text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Find all Text widgets and filter to the ones we want
      final titleFinder = find.text('Daily Progress');
      final subtitleFinder = find.text('You\'re doing great!');
      
      expect(titleFinder, findsOneWidget);
      expect(subtitleFinder, findsOneWidget);
      
      // Verify text styling
      final titleText = tester.widget<Text>(titleFinder);
      expect(titleText.style?.fontSize, equals(16));
      expect(titleText.style?.fontWeight, equals(FontWeight.w600));
      expect(titleText.style?.color, equals(Colors.black87));
      
      final subtitleText = tester.widget<Text>(subtitleFinder);
      expect(subtitleText.style?.fontSize, equals(14));
      expect(subtitleText.style?.color, equals(Colors.black54));
    });

    testWidgets('renders goal percentage badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Verify goal percentage text
      final goalTextFinder = find.text('92% of goal');
      expect(goalTextFinder, findsOneWidget);
      
      // Find the container with the goal percentage
      final badgeContainer = find.ancestor(
        of: goalTextFinder,
        matching: find.byType(Container),
      ).first;
      
      final container = tester.widget<Container>(badgeContainer);
      final decoration = container.decoration as BoxDecoration;
      
      // Verify container styling
      expect(decoration.color, equals(primaryGreen.withOpacity(0.1)));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      
      // Verify the icon
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      
      // Verify text styling
      final percentageText = tester.widget<Text>(goalTextFinder);
      expect(percentageText.style?.color, equals(primaryGreen));
      expect(percentageText.style?.fontSize, equals(14));
      expect(percentageText.style?.fontWeight, equals(FontWeight.w600));
    });

    testWidgets('renders correct number of NutritionStatWidget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the number of nutrition stat widgets
      expect(find.byType(NutritionStatWidget), findsNWidgets(3));
      
      // Verify the stats are displayed with correct values
      for (var stat in nutritionStats) {
        expect(find.text(stat.label), findsOneWidget);
        expect(find.text(stat.value), findsOneWidget);
      }
    });

    // FIXED: Use pump() instead of pumpAndSettle() for CircularProgressIndicator tests
    testWidgets('renders CircularProgressIndicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(createLoadingTestWidget());
      // Just pump once without waiting for animations to settle
      await tester.pump();

      // Verify progress indicator is shown when loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SfCartesianChart), findsNothing);
    });

    testWidgets('handles empty calorie data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressOverviewWidget(
              calorieData: [],
              nutritionStats: nutritionStats,
              primaryGreen: primaryGreen,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify widget still renders with empty data
      expect(find.byType(SfCartesianChart), findsOneWidget);
      expect(find.text('Daily Progress'), findsOneWidget);
    });

    testWidgets('handles empty nutrition stats', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressOverviewWidget(
              calorieData: calorieData,
              nutritionStats: [],
              primaryGreen: primaryGreen,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify no nutrition stat widgets are rendered
      expect(find.byType(NutritionStatWidget), findsNothing);
      
      // But the rest of the widget still renders
      expect(find.text('Daily Progress'), findsOneWidget);
      expect(find.byType(SfCartesianChart), findsOneWidget);
    });

    // Group chart-specific tests separately
    group('chart tests', () {
      Widget buildChartWidget() {
        return MaterialApp(
          home: Scaffold(
            body: ProgressOverviewWidget(
              calorieData: calorieData,
              nutritionStats: nutritionStats,
              primaryGreen: primaryGreen,
              primaryPink: primaryPink,
            ),
          ),
        );
      }

      testWidgets('renders correct chart height', (WidgetTester tester) async {
        await tester.pumpWidget(buildChartWidget());
        await tester.pump(const Duration(milliseconds: 100));

        // Find SizedBox containing the chart
        final sizedBoxFinder = find.descendant(
          of: find.byType(ProgressOverviewWidget),
          matching: find.byType(SizedBox).last,
        );
        
        final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
        expect(sizedBox.height, equals(180));
      });

      testWidgets('renders correct spacing between elements', (WidgetTester tester) async {
        await tester.pumpWidget(buildChartWidget());
        await tester.pump(const Duration(milliseconds: 100));

        // Find specific SizedBoxes by their immediate surroundings
        final spacerBetweenTitleAndSubtitle = find.descendant(
          of: find.ancestor(
            of: find.text('Daily Progress'),
            matching: find.byType(Column),
          ),
          matching: find.byType(SizedBox),
        ).first;
        
        final spacerBoxTitleSubtitle = tester.widget<SizedBox>(spacerBetweenTitleAndSubtitle);
        expect(spacerBoxTitleSubtitle.height, equals(4));
        
        // Get all SizedBoxes with height 16 (not 20)
        final sixteenHeightSizedBoxes = tester.widgetList<SizedBox>(
          find.byWidgetPredicate((widget) => 
            widget is SizedBox && widget.height == 16.0
          )
        );
        
        // There should be at least 1 SizedBox with height 16.0
        expect(sixteenHeightSizedBoxes.length, greaterThanOrEqualTo(1));
        
        // Get all SizedBoxes with height 20
        final twentyHeightSizedBoxes = tester.widgetList<SizedBox>(
          find.byWidgetPredicate((widget) => 
            widget is SizedBox && widget.height == 20.0
          )
        );
        
        // There should be at least 1 SizedBox with height 20.0
        expect(twentyHeightSizedBoxes.length, greaterThanOrEqualTo(1));
        
        // Verify that the spacing SizedBoxes exist
        expect(find.byWidgetPredicate((widget) => 
          widget is SizedBox && (widget.height == 20.0 || widget.height == 16.0)
        ), findsAtLeast(2));
      });
    });
  });
}