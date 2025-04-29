import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/weight_progress_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/bmi_section.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_selection_tabs.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/week_selection_tabs.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/goal_progress_chart.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/calories_chart.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/circular_indicator_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';

// Import the generated mock file
import 'weight_progress_widget_test.mocks.dart';

// Helper method untuk membuat type-safe matcher
dynamic anyCalorieDataList() => argThat(isA<List<CalorieData>>());

@GenerateMocks([FoodLogHistoryService, FoodLogDataService])
void main() {
    late MockFoodLogDataService mockFoodLogDataService;
    late MockFoodLogHistoryService mockFoodLogHistoryService;
    final getIt = GetIt.instance;

    setUp(() {
        mockFoodLogDataService = MockFoodLogDataService();
        mockFoodLogHistoryService = MockFoodLogHistoryService();
        
        // Reset service locator before each test
        if (getIt.isRegistered<FoodLogDataService>()) {
            getIt.unregister<FoodLogDataService>();
        }

        // Setup default mock for getWeekCalorieData() without parameter
        when(mockFoodLogDataService.getWeekCalorieData(weeksAgo: 0)).thenAnswer((_) async => [
            CalorieData('Sun', 20.0, 30.0, 10.0, 300.0),
            CalorieData('Mon', 25.0, 35.0, 12.0, 350.0),
            CalorieData('Tue', 30.0, 40.0, 15.0, 400.0),
            CalorieData('Wed', 22.0, 33.0, 11.0, 320.0),
            CalorieData('Thu', 28.0, 38.0, 14.0, 390.0),
            CalorieData('Fri', 24.0, 36.0, 12.0, 340.0),
            CalorieData('Sat', 26.0, 42.0, 13.0, 380.0),
        ]);
        
        // Explicitly set up for last week (weeksAgo = 1)
        when(mockFoodLogDataService.getWeekCalorieData(weeksAgo: 1)).thenAnswer((_) async => [
            CalorieData('Sun', 40.0, 60.0, 20.0, 600.0), // Doubled values
            CalorieData('Mon', 50.0, 70.0, 24.0, 700.0),
            CalorieData('Tue', 60.0, 80.0, 30.0, 800.0),
            CalorieData('Wed', 44.0, 66.0, 22.0, 640.0),
            CalorieData('Thu', 56.0, 76.0, 28.0, 780.0),
            CalorieData('Fri', 48.0, 72.0, 24.0, 680.0),
            CalorieData('Sat', 52.0, 84.0, 26.0, 760.0),
        ]);
        
        // Explicitly set up for two weeks ago (weeksAgo = 2)
        when(mockFoodLogDataService.getWeekCalorieData(weeksAgo: 2)).thenAnswer((_) async => [
            CalorieData('Sun', 60.0, 90.0, 30.0, 900.0), // Tripled values
            CalorieData('Mon', 75.0, 105.0, 36.0, 1050.0),
            CalorieData('Tue', 90.0, 120.0, 45.0, 1200.0),
            CalorieData('Wed', 66.0, 99.0, 33.0, 960.0),
            CalorieData('Thu', 84.0, 114.0, 42.0, 1170.0),
            CalorieData('Fri', 72.0, 108.0, 36.0, 1020.0),
            CalorieData('Sat', 78.0, 126.0, 39.0, 1140.0),
        ]);

        // Explicitly set up for three weeks ago (weeksAgo = 3)
        when(mockFoodLogDataService.getWeekCalorieData(weeksAgo: 3)).thenAnswer((_) async => [
            CalorieData('Sun', 30.0, 45.0, 15.0, 450.0),
            CalorieData('Mon', 35.0, 50.0, 18.0, 500.0),
            CalorieData('Tue', 40.0, 55.0, 20.0, 550.0),
            CalorieData('Wed', 30.0, 45.0, 15.0, 450.0),
            CalorieData('Thu', 35.0, 50.0, 18.0, 500.0),
            CalorieData('Fri', 40.0, 55.0, 20.0, 550.0),
            CalorieData('Sat', 30.0, 45.0, 15.0, 450.0),
        ]);
        
        when(mockFoodLogDataService.getMonthCalorieData()).thenAnswer((_) async => [
            CalorieData('Week 1', 40.0, 60.0, 20.0, 600.0),
            CalorieData('Week 2', 50.0, 70.0, 25.0, 700.0),
            CalorieData('Week 3', 45.0, 65.0, 22.0, 650.0),
            CalorieData('Week 4', 55.0, 75.0, 28.0, 750.0),
        ]);
        
        // Setup calculateTotalCalories dengan matcher yang type-safe
        when(mockFoodLogDataService.calculateTotalCalories(anyCalorieDataList())).thenReturn(2480.0);
    });

    Widget createWidgetUnderTest() {
        return MaterialApp(
            home: MultiProvider(
                providers: [
                    Provider<FoodLogHistoryService>.value(value: mockFoodLogHistoryService),
                ],
                child: const WeightProgressWidget(),
            ),
        );
    }

    testWidgets('WeightProgressWidget initializes with service locator available', 
            (WidgetTester tester) async {
        // Set a consistent viewport size for tests
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        // Register service in service locator
        getIt.registerSingleton<FoodLogDataService>(mockFoodLogDataService);
        
        // Build widget
        await tester.pumpWidget(createWidgetUnderTest());
        
        // Wait for async operations
        await tester.pumpAndSettle();
        
        // Verify that the widget is rendered
        expect(find.byType(WeightProgressWidget), findsOneWidget);
        expect(find.byType(CircularIndicatorWidget), findsNWidgets(2));
        expect(find.byType(BMISection), findsOneWidget);
        expect(find.byType(PeriodSelectionTabs), findsOneWidget);
        expect(find.byType(GoalProgressChart), findsOneWidget);
        
        // Verify service was called
        verify(mockFoodLogDataService.getWeekCalorieData(weeksAgo: 0)).called(1);
        verify(mockFoodLogDataService.calculateTotalCalories(anyCalorieDataList())).called(1);
        
        // Reset viewport size after test
        addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
    });

    testWidgets('WeightProgressWidget changes data when week changes', 
            (WidgetTester tester) async {
        // Set a consistent viewport size for tests
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        // Register service in service locator
        getIt.registerSingleton<FoodLogDataService>(mockFoodLogDataService);
        
        // Build widget
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        
        // Verify initial state
        expect(find.byType(WeekSelectionTabs), findsOneWidget);
        expect(find.byType(CaloriesChart), findsOneWidget);
        
        // Get the WeekSelectionTabs widget
        final weekSelectionTabs = tester.widget<WeekSelectionTabs>(find.byType(WeekSelectionTabs));
        
        // Simulate selecting "Last week"
        weekSelectionTabs.onWeekSelected('Last week');
        await tester.pump();
        await tester.pumpAndSettle();
        
        // Verify that the service was called with weeksAgo = 1
        verify(mockFoodLogDataService.getWeekCalorieData(weeksAgo: 1)).called(1);
        verify(mockFoodLogDataService.calculateTotalCalories(anyCalorieDataList())).called(2); // Called on initial load and after selection
        
        // Reset viewport size after test
        addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
    });

    testWidgets('WeightProgressWidget changes data when period changes to Month', 
            (WidgetTester tester) async {
        // Set a consistent viewport size for tests
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        // Register service in service locator
        getIt.registerSingleton<FoodLogDataService>(mockFoodLogDataService);
        
        // Build widget
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        
        // Get the PeriodSelectionTabs widget
        final periodSelectionTabs = tester.widget<PeriodSelectionTabs>(find.byType(PeriodSelectionTabs));
        
        // Simulate selecting "1 Month"
        periodSelectionTabs.onPeriodSelected('1 Month');
        await tester.pump();
        await tester.pumpAndSettle();
        
        // Verify that the monthly data service was called
        verify(mockFoodLogDataService.getMonthCalorieData()).called(1);
        
        // Reset viewport size after test
        addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
    });

    testWidgets('WeightProgressWidget hides week selection and calories chart in All time mode', 
            (WidgetTester tester) async {
        // Set a consistent viewport size for tests
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        // Register service in service locator
        getIt.registerSingleton<FoodLogDataService>(mockFoodLogDataService);
        
        // Build widget
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        
        // Initially should find week selection tabs and calories chart
        expect(find.byType(WeekSelectionTabs), findsOneWidget);
        expect(find.byType(CaloriesChart), findsOneWidget);
        
        // Find PeriodSelectionTabs and simulate callback directly
        final periodSelectionTabs = tester.widget<PeriodSelectionTabs>(find.byType(PeriodSelectionTabs));
        periodSelectionTabs.onPeriodSelected('All time');
        
        // Wait for setState and async operations
        await tester.pump();
        await tester.pumpAndSettle();
        
        // Now WeekSelectionTabs and CaloriesChart should be hidden
        expect(find.byType(WeekSelectionTabs), findsNothing);
        expect(find.byType(CaloriesChart), findsNothing);
        
        // Reset viewport size after test
        addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
    });
    
    testWidgets('WeightProgressWidget handles service exceptions gracefully', 
            (WidgetTester tester) async {
        // Set a consistent viewport size for tests
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        // Register service in service locator
        getIt.registerSingleton<FoodLogDataService>(mockFoodLogDataService);
        
        // Setup exception behavior
        when(mockFoodLogDataService.getWeekCalorieData(weeksAgo: 2))
            .thenAnswer((_) async => throw Exception('Test exception'));
        
        // Build widget
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        
        // Get the WeekSelectionTabs widget
        final weekSelectionTabs = tester.widget<WeekSelectionTabs>(find.byType(WeekSelectionTabs));
        
        // Simulate selecting "2 wks. ago" which should throw an exception
        weekSelectionTabs.onWeekSelected('2 wks. ago');
        
        // Wait for setState and async operations
        await tester.pump();
        await tester.pumpAndSettle();
        
        // Should still render calories chart (with default data)
        expect(find.byType(CaloriesChart), findsOneWidget);
        
        // Reset viewport size after test
        addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
    });
}