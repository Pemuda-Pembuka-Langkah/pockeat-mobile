import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/presentation/screens/food_history_page.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';

@GenerateMocks([FoodLogHistoryService])
import 'food_history_page_test.mocks.dart';

void main() {
  late MockFoodLogHistoryService mockService;

  setUp(() {
    mockService = MockFoodLogHistoryService();
  });

  final testFoods = [
    FoodLogHistoryItem(
      id: 'food1',
      title: 'Chicken Salad',
      subtitle: '350 calories',
      timestamp: DateTime.now(),
      calories: 350,
      imageUrl: 'https://example.com/image1.jpg',
    ),
    FoodLogHistoryItem(
      id: 'food2',
      title: 'Pasta',
      subtitle: '450 calories',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      calories: 450,
      imageUrl: 'https://example.com/image2.jpg',
    ),
    FoodLogHistoryItem(
      id: 'food3',
      title: 'Burger',
      subtitle: '650 calories',
      timestamp: DateTime.now().subtract(const Duration(days: 30)),
      calories: 650,
      imageUrl: 'https://example.com/image3.jpg',
    ),
  ];

  Widget createFoodHistoryPage() {
    return MaterialApp(
      home: FoodHistoryPage(service: mockService),
      routes: {
        '/food-detail': (context) => const Scaffold(body: Text('Food Detail Page')),
      },
    );
  }

  group('FoodHistoryPage', () {
    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs()).thenAnswer((_) async {
        // Don't use a timer in tests as it causes pending timer issues
        return testFoods;
      });

      // Act - Only pump once to capture the loading state
      await tester.pumpWidget(createFoodHistoryPage());
      
      // Assert - initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display food list when loaded', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs()).thenAnswer((_) async => testFoods);

      // Act
      await tester.pumpWidget(createFoodHistoryPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Chicken Salad'), findsOneWidget);
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
    });

    testWidgets('should display empty state when no foods', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createFoodHistoryPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No food logs found'), findsOneWidget);
    });

    // testWidgets('should filter foods by date', (WidgetTester tester) async {
    //   // Arrange
    //   // Mock the initial getAllFoodLogs call
    //   when(mockService.getAllFoodLogs()).thenAnswer((_) async => testFoods);
      
    //   // Mock the getFoodLogsByDate call that will be made after selecting the date filter
    //   final filteredFoods = [testFoods[0]]; // Only the first food item
    //   when(mockService.getFoodLogsByDate(any)).thenAnswer((_) async => filteredFoods);

    //   // Act - Render the page
    //   await tester.pumpWidget(createFoodHistoryPage());
    //   await tester.pumpAndSettle();

    //   // Initially should show all foods
    //   expect(find.text('Chicken Salad'), findsOneWidget);
    //   expect(find.text('Pasta'), findsOneWidget);
    //   expect(find.text('Burger'), findsOneWidget);

    //   // Find and tap the date filter button
    //   final dateFilterButton = find.text('By Date');
    //   await tester.tap(dateFilterButton);
    //   await tester.pumpAndSettle();
      
    //   // Since we can't interact with the date picker in tests,
    //   // we'll verify that the service method was called with the right filter type
    //   // when the UI is updated after filter selection
      
    //   // Verify that the service method was called
    //   verify(mockService.getFoodLogsByDate(any)).called(1);
    // });

    testWidgets('should search foods by query', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs()).thenAnswer((_) async => testFoods);
      
      // Act
      await tester.pumpWidget(createFoodHistoryPage());
      await tester.pumpAndSettle();

      // Initially should show all foods
      expect(find.text('Chicken Salad'), findsOneWidget);
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);

      // Find the search field and enter text
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Chicken');
      await tester.pumpAndSettle();
      
      // The search is done locally in the _filterFoods method, not via a service call
      // So we don't need to verify a service method, just check if the UI is updated
      
      // After searching, only "Chicken Salad" should be visible
      expect(find.text('Chicken Salad'), findsOneWidget);
      expect(find.text('Pasta'), findsNothing);
      expect(find.text('Burger'), findsNothing);
    });

    testWidgets('should navigate to food detail page when tapping a food item', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs()).thenAnswer((_) async => testFoods);

      // Act
      await tester.pumpWidget(createFoodHistoryPage());
      await tester.pumpAndSettle();

      // Tap on a food item
      await tester.tap(find.text('Chicken Salad'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Food Detail Page'), findsOneWidget);
    });
  });
}
