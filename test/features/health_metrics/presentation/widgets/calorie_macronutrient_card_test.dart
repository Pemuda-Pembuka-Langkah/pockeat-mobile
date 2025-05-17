// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/widgets/calorie_macronutrient_card.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/macronutrient_bar.dart';

void main() {
  group('CalorieMacronutrientCard', () {
    final double testTdee = 2250;
    final Map<String, double> testMacros = {
      'Protein': 120,
      'Carbs': 200,
      'Fat': 80,
    };
    final Color primaryGreen = Colors.green;
    final Color textDarkColor = Colors.black87;

    testWidgets('should render calorie target and macronutrient bar', (WidgetTester tester) async {
      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalorieMacronutrientCard(
              tdee: testTdee,
              macros: testMacros,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify content is rendered correctly
      expect(find.text('Daily Calorie Target'), findsOneWidget);
      expect(find.text('2250 kcal'), findsOneWidget);
      expect(find.text('Macronutrient Breakdown'), findsOneWidget);
      
      // Check that the MacronutrientBar is included
      expect(find.byType(MacronutrientBar), findsOneWidget);
    });

    testWidgets('should format calorie value correctly', (WidgetTester tester) async {
      // Arrange - test with decimal value
      final double decimalTdee = 2250.75;

      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalorieMacronutrientCard(
              tdee: decimalTdee,
              macros: testMacros,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify the TDEE is rounded to the nearest integer
      expect(find.text('2251 kcal'), findsOneWidget);
    });

    testWidgets('should use provided colors', (WidgetTester tester) async {
      // Arrange - custom colors
      final Color customGreen = Colors.blue;
      final Color customTextColor = Colors.red;

      // Act - build widget with custom colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalorieMacronutrientCard(
              tdee: testTdee,
              macros: testMacros,
              primaryGreen: customGreen,
              textDarkColor: customTextColor,
            ),
          ),
        ),
      );

      // Assert - verify colors are applied
      // Find the fire icon and check its color
      final icon = tester.widget<Icon>(find.byIcon(Icons.local_fire_department));
      expect(icon.color, equals(customGreen));
      
      // Find the calorie value text and check its color
      final calorieText = tester.widget<Text>(find.text('2250 kcal'));
      expect(calorieText.style?.color, equals(customGreen));
      
      // Find the title text and check its color
      final titleText = tester.widget<Text>(find.text('Daily Calorie Target'));
      expect(titleText.style?.color, equals(customTextColor));
    });

    testWidgets('should pass macros data to MacronutrientBar', (WidgetTester tester) async {
      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalorieMacronutrientCard(
              tdee: testTdee,
              macros: testMacros,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - find the MacronutrientBar and check its macros
      final macroBar = tester.widget<MacronutrientBar>(find.byType(MacronutrientBar));
      expect(macroBar.macros, equals(testMacros));
      expect(macroBar.defaultColor, equals(primaryGreen));
      expect(macroBar.textDarkColor, equals(textDarkColor));
    });

    testWidgets('should have proper layout and styling', (WidgetTester tester) async {
      // Act - build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalorieMacronutrientCard(
              tdee: testTdee,
              macros: testMacros,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
            ),
          ),
        ),
      );

      // Assert - verify widget hierarchy
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      
      // Find the main container and check its decoration
      final mainContainer = tester.widget<Container>(find.byType(Container).first);
      final decoration = mainContainer.decoration as BoxDecoration;
      
      // Check container styling
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.border, isA<Border>());
      
      // Verify padding is applied
      expect(mainContainer.padding, equals(const EdgeInsets.all(20)));
    });
  });
}
