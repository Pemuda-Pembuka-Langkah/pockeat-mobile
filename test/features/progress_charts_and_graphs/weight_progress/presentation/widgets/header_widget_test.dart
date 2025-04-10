import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/header_widget.dart';

void main() {
  group('HeaderWidget', () {
    // Test data - different BMI categories
    final healthyWeightStatus = WeightStatus(
      currentWeight: 70.0,
      weightLoss: 2.5,
      progressToGoal: 0.6,
      exerciseContribution: 0.7,
      dietContribution: 0.3,
      bmiValue: 22.5,
      bmiCategory: 'Healthy',
    );
    
    final underweightStatus = WeightStatus(
      currentWeight: 55.0,
      weightLoss: 0.5,
      progressToGoal: 0.2,
      exerciseContribution: 0.5,
      dietContribution: 0.5,
      bmiValue: 17.5,
      bmiCategory: 'Underweight',
    );
    
    final overweightStatus = WeightStatus(
      currentWeight: 85.0,
      weightLoss: 1.0,
      progressToGoal: 0.3,
      exerciseContribution: 0.6,
      dietContribution: 0.4,
      bmiValue: 28.0,
      bmiCategory: 'Overweight',
    );
    
    final obeseStatus = WeightStatus(
      currentWeight: 105.0,
      weightLoss: 0.0,
      progressToGoal: 0.0,
      exerciseContribution: 0.0,
      dietContribution: 0.0,
      bmiValue: 34.0,
      bmiCategory: 'Obese',
    );
    
    final Color primaryPink = const Color(0xFFFF6B6B);

    testWidgets('renders correctly with header title and badge', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              weightStatus: healthyWeightStatus,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Act - Find header elements
      final headerTitleFinder = find.text('Weight Progress');
      final consistentBadgeFinder = find.text('Consistent');
      final lastDaysFinder = find.text('Last 30 days');
      
      // Assert
      expect(headerTitleFinder, findsOneWidget);
      expect(consistentBadgeFinder, findsOneWidget);
      expect(lastDaysFinder, findsOneWidget);
    });
    
    testWidgets('achievement badge has correct styling', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              weightStatus: healthyWeightStatus,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Act - Find container for achievement badge
      final badgeTextFinder = find.text('Consistent');
      final badgeText = tester.widget<Text>(badgeTextFinder);
      
      // Get the badge container
      final badgeContainerFinder = find.ancestor(
        of: badgeTextFinder,
        matching: find.byType(Container),
      ).first;
      final badgeContainer = tester.widget<Container>(badgeContainerFinder);
      
      // Assert - Text styling
      expect(badgeText.style?.color, primaryPink);
      expect(badgeText.style?.fontSize, 12);
      expect(badgeText.style?.fontWeight, FontWeight.w500);
      
      // Container styling
      final decoration = badgeContainer.decoration as BoxDecoration;
      expect(decoration.color, primaryPink.withOpacity(0.1));
      expect(decoration.borderRadius, BorderRadius.circular(12));
      
      // Verify icon presence and styling
      final starIconFinder = find.byIcon(Icons.star);
      expect(starIconFinder, findsOneWidget);
      
      final starIcon = tester.widget<Icon>(starIconFinder);
      expect(starIcon.color, primaryPink);
      expect(starIcon.size, 14);
    });
    
    testWidgets('renders healthy BMI indicator correctly', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              weightStatus: healthyWeightStatus,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Act - Find BMI indicator elements
      final bmiValueFinder = find.text('22.5');
      final bmiCategoryFinder = find.text('Healthy');
      
      // Assert
      expect(bmiValueFinder, findsOneWidget);
      expect(bmiCategoryFinder, findsOneWidget);
      
      // BMI text styling
      final bmiValueText = tester.widget<Text>(bmiValueFinder);
      final bmiCategoryText = tester.widget<Text>(bmiCategoryFinder);
      
      // For Healthy, the color should be green
      final expectedColor = const Color(0xFF4ECDC4);
      expect(bmiValueText.style?.color, expectedColor);
      expect(bmiCategoryText.style?.color, expectedColor);
      
      // Container styling
      final bmiContainerFinder = find.ancestor(
        of: bmiValueFinder,
        matching: find.byType(Container),
      ).first;
      final bmiContainer = tester.widget<Container>(bmiContainerFinder);
      
      final decoration = bmiContainer.decoration as BoxDecoration;
      expect(decoration.color, expectedColor.withOpacity(0.1));
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.border?.top.color, expectedColor.withOpacity(0.2));
    });
    
    testWidgets('renders underweight BMI indicator correctly', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              weightStatus: underweightStatus,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Act - Find BMI indicator elements
      final bmiValueFinder = find.text('17.5');
      final bmiCategoryFinder = find.text('Underweight');
      
      // Assert
      expect(bmiValueFinder, findsOneWidget);
      expect(bmiCategoryFinder, findsOneWidget);
      
      // BMI text styling
      final bmiValueText = tester.widget<Text>(bmiValueFinder);
      final bmiCategoryText = tester.widget<Text>(bmiCategoryFinder);
      
      // For Underweight, the color should be yellow
      final expectedColor = const Color(0xFFFFB946);
      expect(bmiValueText.style?.color, expectedColor);
      expect(bmiCategoryText.style?.color, expectedColor);
      
      // Container styling
      final bmiContainerFinder = find.ancestor(
        of: bmiValueFinder,
        matching: find.byType(Container),
      ).first;
      final bmiContainer = tester.widget<Container>(bmiContainerFinder);
      
      final decoration = bmiContainer.decoration as BoxDecoration;
      expect(decoration.color, expectedColor.withOpacity(0.1));
    });
    
    testWidgets('renders overweight BMI indicator correctly', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              weightStatus: overweightStatus,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Act - Find BMI indicator elements
      final bmiValueFinder = find.text('28.0');
      final bmiCategoryFinder = find.text('Overweight');
      
      // Assert
      expect(bmiValueFinder, findsOneWidget);
      expect(bmiCategoryFinder, findsOneWidget);
      
      // BMI text styling
      final bmiValueText = tester.widget<Text>(bmiValueFinder);
      final bmiCategoryText = tester.widget<Text>(bmiCategoryFinder);
      
      // For Overweight, the color should be yellow
      final expectedColor = const Color(0xFFFFB946);
      expect(bmiValueText.style?.color, expectedColor);
      expect(bmiCategoryText.style?.color, expectedColor);
    });
    
    testWidgets('renders obese BMI indicator correctly with fallback color', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              weightStatus: obeseStatus,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Act - Find BMI indicator elements
      final bmiValueFinder = find.text('34.0');
      final bmiCategoryFinder = find.text('Obese');
      
      // Assert
      expect(bmiValueFinder, findsOneWidget);
      expect(bmiCategoryFinder, findsOneWidget);
      
      // BMI text styling
      final bmiValueText = tester.widget<Text>(bmiValueFinder);
      final bmiCategoryText = tester.widget<Text>(bmiCategoryFinder);
      
      // For other categories (Obese), the color should be pink (fallback)
      expect(bmiValueText.style?.color, primaryPink);
      expect(bmiCategoryText.style?.color, primaryPink);
    });
    
    testWidgets('main layout has correct structure and spacing', (WidgetTester tester) async {
      // Arrange - Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderWidget(
              weightStatus: healthyWeightStatus,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Act - Find main structural elements
      final mainRowFinder = find.byType(Row).first;
      final columnFinder = find.byType(Column);
      final sizedBoxFinders = find.byType(SizedBox);
      
      // Assert
      // Main row should exist and have MainAxisAlignment.spaceBetween
      final mainRow = tester.widget<Row>(mainRowFinder);
      expect(mainRow.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      
      // Should have at least 2 columns (left text column + BMI indicator column)
      expect(columnFinder, findsAtLeastNWidgets(2));
      
      // Should have SizedBox spacing elements
      expect(sizedBoxFinders, findsWidgets);
      
      // First column should have crossAxisAlignment.start
      final leftColumn = tester.widget<Column>(columnFinder.first);
      expect(leftColumn.crossAxisAlignment, CrossAxisAlignment.start);
    });
  });
}