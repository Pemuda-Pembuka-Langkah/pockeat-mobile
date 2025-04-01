import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/weekly_analysis_widget.dart';

void main() {
  // Test data
  final testWeeklyAnalysis = WeeklyAnalysis(
    weightChange: '-1.2 kg',
    caloriesBurned: '3,500 kcal',
    progressRate: '0.3 kg/week',
    weeklyGoalPercentage: 0.75,
  );
  
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryPink = const Color(0xFFFF6B6B);

  // Function to build the testable widget
  Widget buildTestWidget({
    WeeklyAnalysis? analysis,
    Color? green,
    Color? pink,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WeeklyAnalysisWidget(
          weeklyAnalysis: analysis ?? testWeeklyAnalysis,
          primaryGreen: green ?? primaryGreen,
          primaryPink: pink ?? primaryPink,
        ),
      ),
    );
  }

  group('WeeklyAnalysisWidget', () {
    testWidgets('renders correctly with all components', (WidgetTester tester) async {
      // Arrange & Act - Build widget
      await tester.pumpWidget(buildTestWidget());

      // Assert - Find header
      expect(find.text('This Week\'s Analysis'), findsOneWidget);
      
      // Check if analysis items are present
      expect(find.text('Weight Change'), findsOneWidget);
      expect(find.text('-1.2 kg'), findsOneWidget);
      expect(find.text('Calories Burned'), findsOneWidget);
      expect(find.text('3,500 kcal'), findsOneWidget);
      expect(find.text('Progress Rate'), findsOneWidget);
      expect(find.text('0.3 kg/week'), findsOneWidget);
      
      // Check for progress indicator and percentage text
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('75% of weekly goal achieved'), findsOneWidget);
    });

    testWidgets('renders analysis items with correct colors', (WidgetTester tester) async {
      // Arrange & Act - Build widget
      await tester.pumpWidget(buildTestWidget());
      
      // Assert - Find icon widgets and verify their colors
      final weightChangeIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
      expect(weightChangeIcon.color, primaryGreen);
      
      final caloriesBurnedIcon = tester.widget<Icon>(find.byIcon(Icons.local_fire_department));
      expect(caloriesBurnedIcon.color, primaryPink);
      
      final progressRateIcon = tester.widget<Icon>(find.byIcon(Icons.speed));
      expect(progressRateIcon.color, const Color(0xFFFFB946));
      
      // Verify that we can find the ancestor containers containing the icons
      // But don't assert findsOneWidget since there may be multiple Container ancestors
      expect(find.ancestor(
        of: find.byIcon(Icons.arrow_downward),
        matching: find.byType(Container)
      ), findsWidgets);
      
      expect(find.ancestor(
        of: find.byIcon(Icons.local_fire_department),
        matching: find.byType(Container)
      ), findsWidgets);
      
      expect(find.ancestor(
        of: find.byIcon(Icons.speed),
        matching: find.byType(Container)
      ), findsWidgets);
    });
    
    testWidgets('progress indicator has correct value and colors', (WidgetTester tester) async {
      // Arrange & Act - Build widget
      await tester.pumpWidget(buildTestWidget());
      
      // Assert - Find and verify progress indicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      
      expect(progressIndicator.value, 0.75);
      expect(progressIndicator.backgroundColor, Colors.grey[200]);
      
      // Check the valueColor (requires a little more work to get the exact color)
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, primaryGreen);
    });
    
    testWidgets('displays correct percentage text based on weeklyGoalPercentage', (WidgetTester tester) async {
      // Arrange - Create test data with different percentage
      final customAnalysis = WeeklyAnalysis(
        weightChange: '-0.5 kg',
        caloriesBurned: '2,200 kcal',
        progressRate: '0.1 kg/week',
        weeklyGoalPercentage: 0.33,
      );
      
      // Act - Build widget with custom data
      await tester.pumpWidget(buildTestWidget(analysis: customAnalysis));
      
      // Assert - Find and verify percentage text
      expect(find.text('33% of weekly goal achieved'), findsOneWidget);
    });
    
    testWidgets('renders with custom colors', (WidgetTester tester) async {
      // Arrange - Set custom colors
      final customGreen = Colors.green.shade700;
      final customPink = Colors.pink.shade300;
      
      // Act - Build widget with custom colors
      await tester.pumpWidget(buildTestWidget(
        green: customGreen,
        pink: customPink,
      ));
      
      // Assert - Check if custom colors are applied to icons and progress indicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, customGreen);
      
      // Check icon colors directly instead of container background colors
      final caloriesBurnedIcon = tester.widget<Icon>(find.byIcon(Icons.local_fire_department));
      expect(caloriesBurnedIcon.color, customPink);
      
      final weightChangeIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
      expect(weightChangeIcon.color, customGreen);
    });
    
    testWidgets('analysis items have proper styling and layout', (WidgetTester tester) async {
      // Arrange & Act - Build widget
      await tester.pumpWidget(buildTestWidget());
      
      // Assert - Test that the container has proper decoration
      // Find the main container - need to use more specific approach
      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      
      // Get the outermost container which should be the main one
      final mainContainer = containers.first;
      
      final boxDecoration = mainContainer.decoration as BoxDecoration;
      expect(boxDecoration.borderRadius, BorderRadius.circular(16));
      expect(boxDecoration.color, Colors.white);
      expect(boxDecoration.border, Border.all(color: Colors.grey[200]!));
      
      // Test that the icons have proper size
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
      expect(icon.size, 20);
      expect(icon.color, primaryGreen);
      
      // Test that the value text has proper style
      final valueText = tester.widget<Text>(find.text('-1.2 kg'));
      expect((valueText.style as TextStyle).fontWeight, FontWeight.w600);
      expect((valueText.style as TextStyle).fontSize, 14);
      
      // Test that the label text has proper style
      final labelText = tester.widget<Text>(find.text('Weight Change'));
      expect((labelText.style as TextStyle).fontSize, 12);
      expect((labelText.style as TextStyle).color, Colors.grey[600]);
    });
  });
}