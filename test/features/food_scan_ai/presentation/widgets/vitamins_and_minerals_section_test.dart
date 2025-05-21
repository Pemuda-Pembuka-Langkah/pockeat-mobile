// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/vitamins_and_minerals_section.dart';

void main() {
  const primaryColor = Color(0xFF4ECDC4);
  late FoodAnalysisResult foodWithVitamins;
  late FoodAnalysisResult foodWithNoVitamins;

  setUp(() {
    // Create a test food with vitamins and minerals
    final Map<String, double> vitaminsMap = {
      'vitamin_a': 45.0,
      'vitamin_c': 80.5,
      'calcium': 120.0,
      'iron': 8.2,
      'potassium': 235.0,
      'vitamin_d': 10.0,
    };

    foodWithVitamins = FoodAnalysisResult(
      foodName: 'Test Food',
      ingredients: [],
      nutritionInfo: NutritionInfo(
        calories: 250,
        protein: 15,
        carbs: 30,
        fat: 10,
        sodium: 200,
        fiber: 5,
        sugar: 8,
        vitaminsAndMinerals: vitaminsMap,
      ),
    );

    // Create a test food with no vitamins and minerals
    foodWithNoVitamins = FoodAnalysisResult(
      foodName: 'Test Food No Vitamins',
      ingredients: [],
      nutritionInfo: NutritionInfo(
        calories: 250,
        protein: 15,
        carbs: 30,
        fat: 10,
        sodium: 200,
        fiber: 5,
        sugar: 8,
        vitaminsAndMinerals: {},
      ),
    );
  });

  group('VitaminsAndMineralsSection', () {
    testWidgets('renders loading state when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VitaminsAndMineralsSection(
              isLoading: true,
              food: null,
              primaryColor: primaryColor,
            ),
          ),
        ),
      );

      // Verify the loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify no details are shown while loading
      expect(find.text('Vitamins & Minerals Details'), findsNothing);
    });

    testWidgets('renders loading state when food is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VitaminsAndMineralsSection(
              isLoading: false,
              food: null,
              primaryColor: primaryColor,
            ),
          ),
        ),
      );

      // Verify the loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('formats nutrient names correctly',
        (WidgetTester tester) async {
      // Create widget instance to access formatNutrientName
      const widget = VitaminsAndMineralsSection(
        isLoading: false,
        food: null, // Not used for this test
        primaryColor: primaryColor,
      );

      // Test formatting of different nutrient names
      expect(widget.formatNutrientName('vitamin_a'), equals('Vitamin A'));
      expect(widget.formatNutrientName('vitamin_b12'), equals('Vitamin B12'));
      expect(widget.formatNutrientName('iron'), equals('Iron'));
      expect(widget.formatNutrientName('calcium_d'), equals('Calcium D'));
      expect(widget.formatNutrientName(''), equals(''));
    });

    testWidgets('displays message when no vitamins and minerals data available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitaminsAndMineralsSection(
              isLoading: false,
              food: foodWithNoVitamins,
              primaryColor: primaryColor,
            ),
          ),
        ),
      );

      // Verify the section title is displayed
      expect(find.text('Vitamins & Minerals'), findsOneWidget);

      // Verify no data message is displayed
      expect(
        find.text(
            'No vitamins and minerals information available for this food'),
        findsOneWidget,
      );

      // Verify the info icon is displayed
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Verify no expansion tile is shown
      expect(find.text('Vitamins & Minerals Details'), findsNothing);
    });

    testWidgets('displays vitamins and minerals when data is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitaminsAndMineralsSection(
              isLoading: false,
              food: foodWithVitamins,
              primaryColor: primaryColor,
            ),
          ),
        ),
      );

      // Verify the section title is displayed
      expect(find.text('Vitamins & Minerals'), findsOneWidget);

      // Verify top nutrients heading is shown
      expect(find.text('Top Nutrients'), findsOneWidget);
      
      // Verify the expansion tile is shown
      expect(find.text('View All Nutrients'), findsOneWidget);

      // Verify the top 4 vitamins are shown in grid
      expect(find.byType(GridView), findsOneWidget);

      // Tap the expansion tile to expand it
      await tester.tap(find.text('View All Nutrients'));
      await tester.pumpAndSettle();

      // Check for specific vitamin names (formatted properly)
      expect(find.text('Vitamin A'), findsAtLeastNWidgets(1));
      expect(find.text('Vitamin C'), findsAtLeastNWidgets(1));
      expect(find.text('Calcium'), findsAtLeastNWidgets(1));
      expect(find.text('Iron'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays top 4 vitamins in grid view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VitaminsAndMineralsSection(
                isLoading: false,
                food: foodWithVitamins,
                primaryColor: primaryColor,
              ),
            ),
          ),
        ),
      );

      // The grid should have 4 items
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(
          (gridView.childrenDelegate as SliverChildListDelegate)
              .children
              .length,
          4);

      // Check for all vitamins in collapsed view
      expect(find.text('Vitamin A'), findsOneWidget);
      expect(find.text('45.0mg'), findsOneWidget);

      expect(find.text('Vitamin C'), findsOneWidget);
      expect(find.text('80.5mg'), findsOneWidget);
    });

    testWidgets('has correct styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitaminsAndMineralsSection(
              isLoading: false,
              food: foodWithVitamins,
              primaryColor: primaryColor,
            ),
          ),
        ),
      );

      // Verify padding
      final paddingWidget = tester.widget<Padding>(find.byType(Padding).first);
      expect(paddingWidget.padding, equals(const EdgeInsets.all(16.0)));

      // Verify section header style
      final sectionTitle =
          tester.widget<Text>(find.text('Vitamins & Minerals'));
      expect(sectionTitle.style?.fontSize, equals(18));
      expect(sectionTitle.style?.fontWeight, equals(FontWeight.bold));

      // Verify container decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(VitaminsAndMineralsSection),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(12)));
    });

    testWidgets('expansion tile works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VitaminsAndMineralsSection(
                isLoading: false,
                food: foodWithVitamins,
                primaryColor: primaryColor,
              ),
            ),
          ),
        ),
      );

      // Verify expansion tile is initially collapsed
      final initialFinder = find.text('Vitamin A: 45.0mg');
      expect(initialFinder, findsNothing);

      // Tap to expand
      await tester.tap(find.text('View All Nutrients'));
      await tester.pumpAndSettle();

      // Verify expanded content is visible
      expect(find.text('Vitamin A: 45.0mg'), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.text('View All Nutrients'));
      await tester.pumpAndSettle();

      // Verify content is hidden
      expect(find.text('Vitamin A: 45.0mg'), findsNothing);
    });

    testWidgets('vitamin entries in expanded list have correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VitaminsAndMineralsSection(
                isLoading: false,
                food: foodWithVitamins,
                primaryColor: primaryColor,
              ),
            ),
          ),
        ),
      );

      // Tap to expand the details
      await tester.tap(find.text('View All Nutrients'));
      await tester.pumpAndSettle();

      // Find all vitamin chip containers in the expanded section
      final vitaminContainers = find.descendant(
        of: find.byType(Wrap),
        matching: find.byType(Container),
      );

      expect(vitaminContainers.evaluate().isNotEmpty, isTrue, 
          reason: 'Should find vitamin entries in the Wrap');

      // We need at least one container to test
      if (vitaminContainers.evaluate().isNotEmpty) {
        final containerWidget = tester.widget<Container>(vitaminContainers.first);
        final decoration = containerWidget.decoration as BoxDecoration;
        
        // Check container decoration
        expect(decoration.color, equals(Colors.blue[50]));
        expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
        expect(decoration.border, isNotNull);
      }
    });
  });
}
