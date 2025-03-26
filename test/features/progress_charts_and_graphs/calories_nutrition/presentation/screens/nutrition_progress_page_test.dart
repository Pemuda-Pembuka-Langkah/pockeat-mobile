import 'dart:async'; // Add this missing import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/services/nutrition_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/screens/nutrition_progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/progress_overview_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/nutrient_progress_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/meal_patterns_widget.dart';

@GenerateMocks([NutritionService])
import 'nutrition_progress_page_test.mocks.dart';

void main() {
  late MockNutritionService mockService;

  // Sample test data
  final weeklyCalorieData = [
    CalorieData('M', 2100),
    CalorieData('T', 2300),
    CalorieData('W', 1950),
    CalorieData('T', 2200),
    CalorieData('F', 2400),
    CalorieData('S', 1800),
    CalorieData('S', 2000),
  ];

  final monthlyCalorieData = [
    CalorieData('Week 1', 2150),
    CalorieData('Week 2', 2250),
    CalorieData('Week 3', 2100),
    CalorieData('Week 4', 2300),
  ];

  final nutritionStats = [
    NutritionStat(
      label: 'Consumed',
      value: '1,850',
      color: const Color(0xFFFF6B6B),
    ),
    NutritionStat(
      label: 'Burned',
      value: '450',
      color: const Color(0xFF4ECDC4),
    ),
    NutritionStat(
      label: 'Net',
      value: '1,400',
      color: const Color(0xFFFF6B6B),
    ),
  ];

  final macroNutrients = [
    MacroNutrient(
      label: 'Protein',
      percentage: 25,
      detail: '75g/120g',
      color: const Color(0xFFFF6B6B),
    ),
    MacroNutrient(
      label: 'Carbs',
      percentage: 55,
      detail: '138g/250g',
      color: const Color(0xFF4ECDC4),
    ),
    MacroNutrient(
      label: 'Fat',
      percentage: 20,
      detail: '32g/65g',
      color: const Color(0xFFFFB946),
    ),
  ];

  final microNutrients = [
    MicroNutrient(
      nutrient: 'Fiber',
      current: '12g',
      target: '25g',
      progress: 0.48,
      color: const Color(0xFF4ECDC4),
    ),
    MicroNutrient(
      nutrient: 'Sugar',
      current: '18g',
      target: '30g',
      progress: 0.6,
      color: const Color(0xFFFF6B6B),
    ),
  ];

  final meals = [
    Meal(
      name: 'Breakfast',
      calories: 450,
      totalCalories: 2000,
      time: '8:00 AM',
      color: const Color(0xFF4ECDC4),
    ),
    Meal(
      name: 'Lunch',
      calories: 650,
      totalCalories: 2000,
      time: '1:00 PM',
      color: const Color(0xFFFF6B6B),
    ),
    Meal(
      name: 'Dinner',
      calories: 550,
      totalCalories: 2000,
      time: '7:00 PM',
      color: const Color(0xFFFFB946),
    ),
  ];

  setUp(() {
    mockService = MockNutritionService();
  });

  // Helper to setup standard mocked responses
  void setupMockResponses() {
    when(mockService.getCalorieData(any)).thenAnswer((_) async => weeklyCalorieData);
    when(mockService.getNutrientStats()).thenAnswer((_) async => nutritionStats);
    when(mockService.getMacroNutrients()).thenAnswer((_) async => macroNutrients);
    when(mockService.getMicroNutrients()).thenAnswer((_) async => microNutrients);
    when(mockService.getMeals()).thenAnswer((_) async => meals);
  }

  // Helper to create test widget
  Widget createTestWidget() {
    return MaterialApp(
      home: NutritionProgressPage(
        service: mockService,
      ),
    );
  }

  group('NutritionProgressPage', () {
    testWidgets('renders loading indicator initially', (WidgetTester tester) async {
      // Create completers for all the futures
      final calorieCompleter = Completer<List<CalorieData>>();
      final statsCompleter = Completer<List<NutritionStat>>();
      final macroCompleter = Completer<List<MacroNutrient>>();
      final microCompleter = Completer<List<MicroNutrient>>();
      final mealsCompleter = Completer<List<Meal>>();
      
      // Setup mock responses with Completers
      when(mockService.getCalorieData(any)).thenAnswer((_) => calorieCompleter.future);
      when(mockService.getNutrientStats()).thenAnswer((_) => statsCompleter.future);
      when(mockService.getMacroNutrients()).thenAnswer((_) => macroCompleter.future);
      when(mockService.getMicroNutrients()).thenAnswer((_) => microCompleter.future);
      when(mockService.getMeals()).thenAnswer((_) => mealsCompleter.future);

      // Build the widget
      await tester.pumpWidget(createTestWidget());

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(HeaderWidget), findsNothing);
      
      // Complete all futures to finish loading
      calorieCompleter.complete(weeklyCalorieData);
      statsCompleter.complete(nutritionStats);
      macroCompleter.complete(macroNutrients);
      microCompleter.complete(microNutrients);
      mealsCompleter.complete(meals);
      
      // Use pumpAndSettle to ensure all animations and futures are complete
      await tester.pumpAndSettle();
      
      // Verify loading is gone and widgets are displayed
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(HeaderWidget), findsOneWidget);
    });

    testWidgets('renders all widgets after data loads', (WidgetTester tester) async {
      // Setup mock responses with immediate responses
      setupMockResponses();

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      
      // Initial state is loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for loading to complete
      await tester.pumpAndSettle(); // Use pumpAndSettle to wait for all futures

      // Verify all widgets are rendered
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(HeaderWidget), findsOneWidget);
      expect(find.byType(ProgressOverviewWidget), findsOneWidget);
      expect(find.byType(NutrientProgressWidget), findsOneWidget);
      expect(find.byType(MealPatternsWidget), findsOneWidget);
      
      // Verify main SizedBoxes by finding ones with specific height
      // that are direct children of the Column
      final mainColumn = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Column),
      ).first;
      
      final sizedBoxes = find.descendant(
        of: mainColumn,
        matching: find.byWidgetPredicate((widget) => 
          widget is SizedBox && widget.height == 24.0
        ),
      );
      
      expect(sizedBoxes, findsNWidgets(3));
    });

    testWidgets('handles toggle view correctly', (WidgetTester tester) async {
      // Setup different responses for weekly and monthly views
      when(mockService.getCalorieData(true)).thenAnswer((_) async => weeklyCalorieData);
      when(mockService.getCalorieData(false)).thenAnswer((_) async => monthlyCalorieData);
      when(mockService.getNutrientStats()).thenAnswer((_) async => nutritionStats);
      when(mockService.getMacroNutrients()).thenAnswer((_) async => macroNutrients);
      when(mockService.getMicroNutrients()).thenAnswer((_) async => microNutrients);
      when(mockService.getMeals()).thenAnswer((_) async => meals);

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      
      // Wait for initial data to load
      await tester.pumpAndSettle();

      // Verify initial state is weekly
      final headerWidget = tester.widget<HeaderWidget>(find.byType(HeaderWidget));
      expect(headerWidget.isWeeklyView, isTrue);
      
      // Find the toggle function and call it directly to change to monthly view
      final toggleFunction = headerWidget.onToggleView;
      
      // Call the toggle function to change to monthly view
      toggleFunction(false);
      
      // Wait for toggle to complete
      await tester.pumpAndSettle();
      
      // Verify monthly data was requested
      verify(mockService.getCalorieData(false)).called(1);
    });

    testWidgets('handles no-op toggle view', (WidgetTester tester) async {
      // Setup mock responses
      setupMockResponses();

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get the initial HeaderWidget
      HeaderWidget headerWidget = tester.widget<HeaderWidget>(find.byType(HeaderWidget));
      expect(headerWidget.isWeeklyView, isTrue);
      
      // Call toggle with the same value (weekly -> weekly)
      headerWidget.onToggleView(true);
      await tester.pumpAndSettle();
      
      // Verify no extra calls were made to get data (only the initial call)
      verify(mockService.getCalorieData(true)).called(1);
    });

    testWidgets('handles error during data initialization', (WidgetTester tester) async {
      // Setup mock responses with error
      when(mockService.getCalorieData(any)).thenThrow(Exception('Failed to load calorie data'));
      when(mockService.getNutrientStats()).thenAnswer((_) async => nutritionStats);
      when(mockService.getMacroNutrients()).thenAnswer((_) async => macroNutrients);
      when(mockService.getMicroNutrients()).thenAnswer((_) async => microNutrients);
      when(mockService.getMeals()).thenAnswer((_) async => meals);

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      
      // Wait for error to be processed
      await tester.pumpAndSettle();

      // Should show loading finished but no data
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(HeaderWidget), findsOneWidget);
    });

    testWidgets('handles error during toggle view', (WidgetTester tester) async {
      // Setup initial successful responses
      when(mockService.getCalorieData(true)).thenAnswer((_) async => weeklyCalorieData);
      when(mockService.getNutrientStats()).thenAnswer((_) async => nutritionStats);
      when(mockService.getMacroNutrients()).thenAnswer((_) async => macroNutrients);
      when(mockService.getMicroNutrients()).thenAnswer((_) async => microNutrients);
      when(mockService.getMeals()).thenAnswer((_) async => meals);
      
      // But monthly view will fail
      when(mockService.getCalorieData(false)).thenThrow(Exception('Failed to load monthly data'));

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get the HeaderWidget and toggle to monthly
      HeaderWidget headerWidget = tester.widget<HeaderWidget>(find.byType(HeaderWidget));
      headerWidget.onToggleView(false);
      
      // Wait for toggle attempt to complete
      await tester.pumpAndSettle();
      
      // Page should recover and show the UI without crashing
      expect(find.byType(HeaderWidget), findsOneWidget);
    });

    testWidgets('color constants are set correctly', (WidgetTester tester) async {
      // Setup mock responses
      setupMockResponses();

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Find the ProgressOverviewWidget
      final progressOverviewWidget = tester.widget<ProgressOverviewWidget>(find.byType(ProgressOverviewWidget));
      
      // Verify colors are passed correctly
      expect(progressOverviewWidget.primaryGreen, equals(const Color(0xFF4ECDC4)));
      expect(progressOverviewWidget.primaryPink, equals(const Color(0xFFFF6B6B)));
      
      // Find the MealPatternsWidget
      final mealPatternsWidget = tester.widget<MealPatternsWidget>(find.byType(MealPatternsWidget));
      
      // Verify color is passed correctly
      expect(mealPatternsWidget.primaryGreen, equals(const Color(0xFF4ECDC4)));
      
      // Find the HeaderWidget
      final headerWidget = tester.widget<HeaderWidget>(find.byType(HeaderWidget));
      
      // Verify color is passed correctly
      expect(headerWidget.primaryColor, equals(const Color(0xFFFF6B6B)));
    });

    testWidgets('layout has correct spacing', (WidgetTester tester) async {
      // Setup mock responses
      setupMockResponses();

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Find the main layout column
      final mainColumn = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Column),
      ).first;
      
      // Find the SizedBoxes that are direct children of the main column
      final spacers = find.descendant(
        of: mainColumn,
        matching: find.byWidgetPredicate((widget) => 
          widget is SizedBox && widget.height == 24.0
        ), // Fixed missing closing parenthesis
      );
      
      // Verify we have 3 spacers with height 24.0
      expect(spacers, findsNWidgets(3));
    });
    
    testWidgets('verify text content in widgets', (WidgetTester tester) async {
      // Setup mock responses
      setupMockResponses();

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Verify nutritional stats text content
      expect(find.text('Consumed'), findsOneWidget);
      expect(find.text('1,850'), findsOneWidget);
      expect(find.text('Burned'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);
      expect(find.text('Net'), findsOneWidget);
      expect(find.text('1,400'), findsOneWidget);
      
      // Verify macro nutrients labels
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
      
      // Verify macro nutrients details
      expect(find.text('75g/120g'), findsOneWidget);
      expect(find.text('138g/250g'), findsOneWidget);
      expect(find.text('32g/65g'), findsOneWidget);
      
      // Verify meal names
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
    });
    
    testWidgets('properly refreshes UI when data changes', (WidgetTester tester) async {
      // Setup mock responses
      setupMockResponses();

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Change data
      final updatedCalorieData = [
        CalorieData('M', 1500),
        CalorieData('T', 1800),
        CalorieData('W', 2000),
        CalorieData('T', 1900),
        CalorieData('F', 2100),
        CalorieData('S', 1600),
        CalorieData('S', 1700),
      ];
      
      // Update mock to return new data
      when(mockService.getCalorieData(true)).thenAnswer((_) async => updatedCalorieData);
      
      // Trigger a reload by toggling to monthly and back to weekly
      final headerWidget = tester.widget<HeaderWidget>(find.byType(HeaderWidget));
      headerWidget.onToggleView(false);
      await tester.pumpAndSettle();
      
      // Change back to weekly with new data
      when(mockService.getCalorieData(false)).thenAnswer((_) async => monthlyCalorieData);
      
      headerWidget.onToggleView(true);
      await tester.pumpAndSettle();
      
      // Verify data was updated
      verify(mockService.getCalorieData(true)).called(2); // Initial + after toggle back
    });
  });
}