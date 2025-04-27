import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_database_input/presentation/widgets/macro_distribution_bar.dart';

void main() {
  group('MacroDistributionBar', () {
    testWidgets('should render correctly with balanced macros',
        (WidgetTester tester) async {
      // Arrange
      final nutrition = NutritionInfo(
        calories: 400.0,
        protein: 25.0, // 25% of calories
        carbs: 50.0, // 50% of calories
        fat: 11.1, // 25% of calories (fat has 9 calories per gram)
        saturatedFat: 3.0,
        sodium: 200.0,
        fiber: 5.0,
        sugar: 10.0,
        cholesterol: 50.0,
        nutritionDensity: 7.5,
        vitaminsAndMinerals: {},
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroDistributionBar(
              nutrition: nutrition,
              primaryGreen: const Color(0xFF4ECDC4),
              primaryPink: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('400 kcal'), findsOneWidget);
      expect(find.text('Protein: 25.0g'), findsOneWidget);
      expect(find.text('Carbs: 50.0g'), findsOneWidget);
      expect(find.text('Fat: 11.1g'), findsOneWidget);
    });

    testWidgets('should render correctly with high protein diet',
        (WidgetTester tester) async {
      // Arrange - high protein
      final nutrition = NutritionInfo(
        calories: 400.0,
        protein: 70.0, // 70% of calories
        carbs: 20.0, // 20% of calories
        fat: 4.4, // 10% of calories (fat has 9 calories per gram)
        saturatedFat: 1.5,
        sodium: 200.0,
        fiber: 3.0,
        sugar: 5.0,
        cholesterol: 80.0,
        nutritionDensity: 6.0,
        vitaminsAndMinerals: {},
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroDistributionBar(
              nutrition: nutrition,
              primaryGreen: const Color(0xFF4ECDC4),
              primaryPink: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('400 kcal'), findsOneWidget);
      expect(find.text('Protein: 70.0g'), findsOneWidget);
      expect(find.text('Carbs: 20.0g'), findsOneWidget);
      expect(find.text('Fat: 4.4g'), findsOneWidget);
    });

    testWidgets('should handle zero calorie nutrition info',
        (WidgetTester tester) async {
      // Arrange - zero calories
      final nutrition = NutritionInfo(
        calories: 0.0,
        protein: 0.0,
        carbs: 0.0,
        fat: 0.0,
        saturatedFat: 0.0,
        sodium: 0.0,
        fiber: 0.0,
        sugar: 0.0,
        cholesterol: 0.0,
        nutritionDensity: 0.0,
        vitaminsAndMinerals: {},
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroDistributionBar(
              nutrition: nutrition,
              primaryGreen: const Color(0xFF4ECDC4),
              primaryPink: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('0 kcal'), findsOneWidget);
      expect(find.text('Protein: 0.0g'), findsOneWidget);
      expect(find.text('Carbs: 0.0g'), findsOneWidget);
      expect(find.text('Fat: 0.0g'), findsOneWidget);
    });
  });
}
