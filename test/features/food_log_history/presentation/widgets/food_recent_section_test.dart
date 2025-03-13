import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_recent_section.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';

@GenerateMocks([FoodLogHistoryService])
import 'food_recent_section_test.mocks.dart';

void main() {
  late MockFoodLogHistoryService mockService;

  setUp(() {
    mockService = MockFoodLogHistoryService();
  });

  group('FoodRecentSection Widget', () {
    final foodItems = [
      FoodLogHistoryItem(
        id: 'food1',
        title: 'Chicken Salad',
        subtitle: '350 cal, 20g protein',
        timestamp: DateTime.now(),
        calories: 350,
        sourceId: 'source1',
        imageUrl: 'https://example.com/image1.jpg',
      ),
      FoodLogHistoryItem(
        id: 'food2',
        title: 'Pasta',
        subtitle: '450 cal, 15g protein',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        calories: 450,
        sourceId: 'source2',
        imageUrl: 'https://example.com/image2.jpg',
      ),
    ];

    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      // Arrange - Use a Completer to control when the future completes
      when(mockService.getAllFoodLogs(limit: 5)).thenAnswer((_) async {
        // Don't use a timer in tests as it causes pending timer issues
        return foodItems;
      });
      
      // Act - Only pump once to capture the loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
            ),
          ),
        ),
      );
      
      // Assert - initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display food items when loaded', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs(limit: 5)).thenAnswer((_) async => foodItems);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Chicken Salad'), findsOneWidget);
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Recent Foods'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display empty state when no foods', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs(limit: 5)).thenAnswer((_) async => []);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - check for the actual empty state message used in the implementation
      expect(find.text('No food history yet'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // testWidgets('should display error state when error occurs', (WidgetTester tester) async {
    //   // Arrange
    //   when(mockService.getAllFoodLogs(limit: 5)).thenThrow(Exception('Failed to load foods'));

    //   // Act
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: FoodRecentSection(
    //           service: mockService,
    //           limit: 5,
    //         ),
    //       ),
    //     ),
    //   );
    //   await tester.pumpAndSettle();

    //   // Assert - check for the error message pattern used in the implementation
    //   expect(find.textContaining('Error loading foods'), findsOneWidget);
    //   expect(find.byType(CircularProgressIndicator), findsNothing);
    // });

    testWidgets('should navigate to food detail when tapping a food item', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs(limit: 5)).thenAnswer((_) async => foodItems);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/food-detail': (context) => const Scaffold(body: Text('Food Detail')),
          },
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the first food item
      await tester.tap(find.text('Chicken Salad'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Food Detail'), findsOneWidget);
    });
  });
}
