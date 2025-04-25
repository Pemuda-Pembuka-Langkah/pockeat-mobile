// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/current_weight_card_widget.dart';

void main() {
  group('CurrentWeightCardWidget', () {
    // Test data
    final weightStatus = WeightStatus(
      currentWeight: 73.0,
      weightLoss: 2.5,
      progressToGoal: 0.65,
      exerciseContribution: 0.7,
      dietContribution: 0.3,
      bmiValue: 22.5,
      bmiCategory: 'Healthy',
    );
    
    final primaryGreen = const Color(0xFF4ECDC4);

    testWidgets('renders current weight and label correctly', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeightCardWidget(
              weightStatus: weightStatus,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Act - Find text elements
      final currentWeightText = find.text('73.0 kg');
      final currentWeightLabel = find.text('Current Weight');

      // Assert
      expect(currentWeightText, findsOneWidget);
      expect(currentWeightLabel, findsOneWidget);
    });

    testWidgets('renders weight loss section correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeightCardWidget(
              weightStatus: weightStatus,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Act - Find elements
      final weightLossText = find.text('2.5 kg');
      final fromStartingWeightText = find.text('from starting weight');
      final downwardArrowIcon = find.byIcon(Icons.arrow_downward);

      // Assert
      expect(weightLossText, findsOneWidget);
      expect(fromStartingWeightText, findsOneWidget);
      expect(downwardArrowIcon, findsOneWidget);
    });

    testWidgets('renders progress bar section correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeightCardWidget(
              weightStatus: weightStatus,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Act - Find elements
      final progressToGoalText = find.text('Progress to Goal');
      final progressPercentText = find.text('65%'); // 0.65 * 100 = 65%
      final progressBar = find.byType(LinearProgressIndicator);

      // Assert
      expect(progressToGoalText, findsOneWidget);
      expect(progressPercentText, findsOneWidget);
      expect(progressBar, findsOneWidget);

      // Verify progress bar value
      final progressIndicator = tester.widget<LinearProgressIndicator>(progressBar);
      expect(progressIndicator.value, 0.65);
      expect(progressIndicator.backgroundColor, Colors.grey[200]);
      expect((progressIndicator.valueColor as AlwaysStoppedAnimation<Color>).value, primaryGreen);
    });

    testWidgets('renders contribution percentages correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeightCardWidget(
              weightStatus: weightStatus,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Act - Find elements
      final exerciseContributionText = find.text('👟 Exercise: 70%'); // 0.7 * 100 = 70%
      final dietContributionText = find.text('🍎 Diet: 30%'); // 0.3 * 100 = 30%

      // Assert
      expect(exerciseContributionText, findsOneWidget);
      expect(dietContributionText, findsOneWidget);
    });

    testWidgets('renders container with proper decoration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeightCardWidget(
              weightStatus: weightStatus,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Act - Find element
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

    testWidgets('displays correct layout and spacings', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeightCardWidget(
              weightStatus: weightStatus,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Act
      final sizedBoxes = find.byType(SizedBox);
      final columns = find.byType(Column);
      final rows = find.byType(Row);

      // Assert - Check for spacings and layout structure
      expect(sizedBoxes, findsWidgets);
      expect(columns, findsWidgets);
      expect(rows, findsWidgets);
    });

    testWidgets('handles zero values properly', (WidgetTester tester) async {
      // Arrange - Create weight status with zero values
      final zeroWeightStatus = WeightStatus(
        currentWeight: 0.0,
        weightLoss: 0.0,
        progressToGoal: 0.0,
        exerciseContribution: 0.0,
        dietContribution: 0.0,
        bmiValue: 0.0,
        bmiCategory: '',
      );

      // Act - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeightCardWidget(
              weightStatus: zeroWeightStatus,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Assert - Check that zeros are displayed correctly
      // Use a simpler approach that doesn't rely on specific widget hierarchy
      
      // Verify that text with current weight appears somewhere (don't be too specific about location)
      final weightTexts = find.textContaining('0.0 kg');
      expect(weightTexts, findsWidgets); // We know there are multiple instances
      
      // Verify percentage texts
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('👟 Exercise: 0%'), findsOneWidget);
      expect(find.text('🍎 Diet: 0%'), findsOneWidget);
    });

    testWidgets('renders progress divider line in the proper position', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeightCardWidget(
              weightStatus: weightStatus,
              primaryGreen: primaryGreen,
            ),
          ),
        ),
      );

      // Act - Find positioned container (divider)
      final positionedFinder = find.byType(Positioned);
      
      // Assert
      expect(positionedFinder, findsOneWidget);
      
      final positioned = tester.widget<Positioned>(positionedFinder);
      expect(positioned.top, 0);
      expect(positioned.bottom, 0);
      
      // Find divider container
      final containerFinder = find.descendant(
        of: positionedFinder,
        matching: find.byType(Container),
      );
      
      // Get the render object to check actual size
      final containerRenderBox = tester.renderObject(containerFinder) as RenderBox;
      expect(containerRenderBox.size.width, 2.0);
      
      // Check the color directly from the Container widget
      final dividerContainer = tester.widget<Container>(containerFinder);
      expect(dividerContainer.color, Colors.white);
    });
  });
}
