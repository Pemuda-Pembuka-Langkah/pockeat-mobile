// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/goals_card_widget.dart';

void main() {
  group('GoalsCardWidget', () {
    // Test data
    final onTrackWeightGoal = WeightGoal(
      startingWeight: '75.5 kg',
      startingDate: 'Dec 1, 2024',
      targetWeight: '70.0 kg',
      targetDate: 'Mar 1, 2025',
      remainingWeight: '3.0 kg',
      daysLeft: '35 days left',
      isOnTrack: true,
      insightMessage: 'Maintaining current activity level, you\'ll reach your goal 5 days ahead of schedule!',
    );
    
    final offTrackWeightGoal = WeightGoal(
      startingWeight: '75.5 kg',
      startingDate: 'Dec 1, 2024',
      targetWeight: '70.0 kg',
      targetDate: 'Mar 1, 2025',
      remainingWeight: '4.5 kg',
      daysLeft: '35 days left',
      isOnTrack: false,
      insightMessage: 'You need to increase activity by 20% to reach your goal on time.',
    );
    
    final Color primaryGreen = const Color(0xFF4ECDC4);
    final Color primaryPink = const Color(0xFFFF6B6B);
    final Color primaryYellow = const Color(0xFFFFE893);

    Widget buildTestableWidget({required WeightGoal weightGoal}) {
      return MaterialApp(
        home: Scaffold(
          body: GoalsCardWidget(
            weightGoal: weightGoal,
            primaryGreen: primaryGreen,
            primaryPink: primaryPink,
            primaryYellow: primaryYellow,
          ),
        ),
      );
    }

    testWidgets('renders with all the required data when on track', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(buildTestableWidget(weightGoal: onTrackWeightGoal));

      // Act - Find text elements
      final weightGoalsText = find.text('Weight Goals');
      final onTrackText = find.text('On Track');
      final startingText = find.text('Starting');
      final targetText = find.text('Target');
      final toGoText = find.text('To Go');
      final insightText = find.text(onTrackWeightGoal.insightMessage);

      // Assert
      expect(weightGoalsText, findsOneWidget);
      expect(onTrackText, findsOneWidget);
      expect(startingText, findsOneWidget);
      expect(targetText, findsOneWidget);
      expect(toGoText, findsOneWidget);
      expect(insightText, findsOneWidget);
    });

    testWidgets('renders Off Track status when not on track', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestableWidget(weightGoal: offTrackWeightGoal));

      // Act
      final offTrackText = find.text('Off Track');

      // Assert
      expect(offTrackText, findsOneWidget);
      expect(find.text('On Track'), findsNothing);
    });

    testWidgets('displays correct weight values from model', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestableWidget(weightGoal: onTrackWeightGoal));

      // Act - Find specific weight values
      final startingWeightText = find.text(onTrackWeightGoal.startingWeight);
      final targetWeightText = find.text(onTrackWeightGoal.targetWeight);
      final remainingWeightText = find.text(onTrackWeightGoal.remainingWeight);

      // Assert
      expect(startingWeightText, findsOneWidget);
      expect(targetWeightText, findsOneWidget);
      expect(remainingWeightText, findsOneWidget);
    });

    testWidgets('displays correct date values from model', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestableWidget(weightGoal: onTrackWeightGoal));

      // Act - Find specific date values
      final startingDateText = find.text(onTrackWeightGoal.startingDate);
      final targetDateText = find.text(onTrackWeightGoal.targetDate);
      final daysLeftText = find.text(onTrackWeightGoal.daysLeft);

      // Assert
      expect(startingDateText, findsOneWidget);
      expect(targetDateText, findsOneWidget);
      expect(daysLeftText, findsOneWidget);
    });

    testWidgets('renders all icons correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestableWidget(weightGoal: onTrackWeightGoal));

      // Act - Find specific icons
      final historyIcon = find.byIcon(Icons.history);
      final flagIcon = find.byIcon(Icons.flag);
      final trendingDownIcon = find.byIcon(Icons.trending_down);
      final tipsIcon = find.byIcon(Icons.tips_and_updates);

      // Assert
      expect(historyIcon, findsOneWidget);
      expect(flagIcon, findsOneWidget);
      expect(trendingDownIcon, findsOneWidget);
      expect(tipsIcon, findsOneWidget);
    });

    testWidgets('renders container with proper decoration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestableWidget(weightGoal: onTrackWeightGoal));

      // Act - Find main container
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      // Assert
      expect(container.padding, const EdgeInsets.all(16));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.border, Border.all(color: Colors.grey[200]!));
      expect(decoration.boxShadow!.length, 1);
    });

    testWidgets('has the correct layout structure', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestableWidget(weightGoal: onTrackWeightGoal));

      // Act
      final columnFinder = find.byType(Column);
      final rowFinder = find.byType(Row);
      final sizedBoxFinder = find.byType(SizedBox);
      
      // Find the row that contains goal details and dividers
      final goalDetailsRow = find.byType(Row).at(1);
      
      // Find containers inside this row that are likely to be dividers
      // by checking their rendered size
      int dividerCount = 0;
      final containersInRow = find.descendant(
        of: goalDetailsRow,
        matching: find.byType(Container),
      );
      
      for (int i = 0; i < tester.widgetList(containersInRow).length; i++) {
        final containerFinder = containersInRow.at(i);
        final renderBox = tester.renderObject<RenderBox>(containerFinder);
        
        // If it's very narrow (width ~= 1) and has decent height, it's likely a divider
        if (renderBox.size.width <= 2.0 && renderBox.size.height >= 35.0) {
          dividerCount++;
        }
      }

      // Assert
      expect(columnFinder, findsWidgets);
      expect(rowFinder, findsWidgets);
      expect(sizedBoxFinder, findsWidgets);
      expect(dividerCount, 2); // There should be 2 dividers between the 3 goal sections
    });

    testWidgets('_buildGoalDetail creates correct structure for each goal section', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestableWidget(weightGoal: onTrackWeightGoal));

      // Find all goal detail sections
      final startingSection = find.ancestor(
        of: find.text('Starting'),
        matching: find.byType(Column),
      ).first;

      // Get the column with the detail
      final startingColumn = tester.widget<Column>(startingSection);
      
      // Verify structure: Container > Icon, SizedBox, Text(value), Text(label), Text(subtitle)
      expect(startingColumn.children.length, 5);
      expect(startingColumn.children[0] is Container, true);
      expect(startingColumn.children[1] is SizedBox, true);
      expect(startingColumn.children[2] is Text, true);
      expect(startingColumn.children[3] is Text, true);
      expect(startingColumn.children[4] is Text, true);
      
      // Verify icon container decoration
      final iconContainer = startingColumn.children[0] as Container;
      expect(iconContainer.padding, const EdgeInsets.all(8));
      final containerDecoration = iconContainer.decoration as BoxDecoration;
      expect(containerDecoration.color, primaryPink.withOpacity(0.1));
      expect(containerDecoration.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('insight container has correct styling', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestableWidget(weightGoal: onTrackWeightGoal));

      // Find the insight container (it's the last container in the main column)
      final insightContainerFinder = find.ancestor(
        of: find.text(onTrackWeightGoal.insightMessage),
        matching: find.byType(Container),
      ).first;
      
      final insightContainer = tester.widget<Container>(insightContainerFinder);
      
      // Verify decoration
      expect(insightContainer.padding, const EdgeInsets.all(12));
      final decoration = insightContainer.decoration as BoxDecoration;
      expect(decoration.color, primaryYellow.withOpacity(0.1));
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.border!.top.color, primaryYellow.withOpacity(0.2));
    });
  });
}
