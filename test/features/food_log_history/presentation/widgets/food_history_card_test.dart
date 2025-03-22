import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_history_card.dart';

void main() {
  // Use a fixed timestamp for testing to avoid timing issues
  final testTimestamp = DateTime(2023, 1, 1, 10, 30);

  final testFood = FoodLogHistoryItem(
    id: 'food1',
    title: 'Chicken Salad',
    subtitle: '350 calories',
    timestamp: testTimestamp,
    calories: 350,
    imageUrl: 'https://example.com/image1.jpg',
  );

  testWidgets('FoodHistoryCard displays food information correctly',
      (WidgetTester tester) async {
    // Arrange
    bool tapped = false;

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodHistoryCard(
            food: testFood,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Chicken Salad'), findsOneWidget);
    expect(find.text('350 calories'), findsOneWidget);

    // Check for time display - using the _getTimeAgo method which returns a relative time
    // Since the test timestamp is fixed, we can check for any time indicator
    expect(find.textContaining('ago'), findsOneWidget);

    // Test tapping the card
    await tester.tap(find.byType(FoodHistoryCard));
    expect(tapped, true);
  });

  testWidgets('FoodHistoryCard displays placeholder when no image URL',
      (WidgetTester tester) async {
    // Arrange
    final foodWithoutImage = FoodLogHistoryItem(
      id: 'food2',
      title: 'Pasta',
      subtitle: '450 calories',
      timestamp: testTimestamp,
      calories: 450,
      imageUrl: null,
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodHistoryCard(
            food: foodWithoutImage,
            onTap: () {},
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('450 calories'), findsOneWidget);

    // Check for restaurant icon instead of cart_fill
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
  });
}
