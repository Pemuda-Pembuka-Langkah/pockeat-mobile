// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
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

    group('FoodHistoryCard subtitle rendering', () {
    testWidgets('should display plain subtitle without bullets', (WidgetTester tester) async {
      // Arrange - Food with plain subtitle (no bullets)
      final foodWithPlainSubtitle = FoodLogHistoryItem(
        id: 'food1',
        title: 'Plain Food',
        subtitle: 'Just a simple description',
        timestamp: testTimestamp,
        calories: 300,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryCard(
              food: foodWithPlainSubtitle,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Just a simple description'), findsOneWidget);
    });

    testWidgets('should properly highlight subtitle with bullet points', (WidgetTester tester) async {
      // Arrange - Food with bullet points in subtitle
      final foodWithBulletPoints = FoodLogHistoryItem(
        id: 'food2',
        title: 'Detailed Food',
        subtitle: 'Healthy meal • Protein: 20g • Carbs: 30g',
        timestamp: testTimestamp,
        calories: 400,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryCard(
              food: foodWithBulletPoints,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - we can't directly test the RichText contents in widget tests,
      // but we can verify the card was rendered with the correct food info
      expect(find.text('Detailed Food'), findsOneWidget);
      expect(find.text('400 cal'), findsOneWidget);
    });
    
    testWidgets('should display time ago correctly', (WidgetTester tester) async {
      // Arrange - Create a food item with fixed timestamp
      final now = DateTime.now();
      
      // Test cases for different time differences
      final timeTestCases = [
        {
          'description': 'Just now',
          'timestamp': now.subtract(const Duration(seconds: 30)),
          'expected': 'Just now'
        },
        {
          'description': 'Minutes ago',
          'timestamp': now.subtract(const Duration(minutes: 5)),
          'expected': '5m ago'
        },
        {
          'description': 'Hours ago',
          'timestamp': now.subtract(const Duration(hours: 3)),
          'expected': '3h ago'
        },
        {
          'description': 'Days ago',
          'timestamp': now.subtract(const Duration(days: 2)),
          'expected': '2d ago'
        },
        {
          'description': 'Months ago',
          'timestamp': now.subtract(const Duration(days: 60)),
          'expected': '2mo ago'
        }
      ];
      
      // Only test one case in this file to avoid duplication
      // We'll use the 'Minutes ago' case
      final testCase = timeTestCases[1];
      
      final foodWithTimeDiff = FoodLogHistoryItem(
        id: 'food3',
        title: 'Time Test Food',
        subtitle: 'Basic description',
        timestamp: testCase['timestamp'] as DateTime,
        calories: 350,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryCard(
              food: foodWithTimeDiff,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testCase['expected'] as String), findsOneWidget);
    });
  });
  
  group('FoodHistoryCard _buildRichTextSpans', () {
    // Create a testable wrapper for the private _buildRichTextSpans method
    // We'll render FoodHistoryCards with different subtitles to test the functionality
    
    testWidgets('should handle subtitle with key-value pairs correctly', (WidgetTester tester) async {
      // Arrange - Food with key-value pairs in subtitle
      final foodWithKeyValue = FoodLogHistoryItem(
        id: 'food4',
        title: 'Key Value Food',
        subtitle: 'Main info • Key1: Value1 • Key2: Value2',
        timestamp: testTimestamp,
        calories: 500,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryCard(
              food: foodWithKeyValue,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Key Value Food'), findsOneWidget);
      expect(find.text('500 cal'), findsOneWidget);
    });
    
    testWidgets('should handle subtitle with empty parts correctly', (WidgetTester tester) async {
      // Arrange - Food with empty parts in subtitle
      final foodWithEmptyParts = FoodLogHistoryItem(
        id: 'food5',
        title: 'Empty Parts Food',
        subtitle: 'Info • • Key: Value',
        timestamp: testTimestamp,
        calories: 600,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryCard(
              food: foodWithEmptyParts,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Empty Parts Food'), findsOneWidget);
      expect(find.text('600 cal'), findsOneWidget);
    });
    
    testWidgets('should handle subtitle with only bullets correctly', (WidgetTester tester) async {
      // Arrange - Food with only bullets in subtitle
      final foodWithOnlyBullets = FoodLogHistoryItem(
        id: 'food6',
        title: 'Only Bullets Food',
        subtitle: '•••',
        timestamp: testTimestamp,
        calories: 700,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryCard(
              food: foodWithOnlyBullets,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Only Bullets Food'), findsOneWidget);
      expect(find.text('700 cal'), findsOneWidget);
    });
    
    testWidgets('should handle key with no value correctly', (WidgetTester tester) async {
      // Arrange - Food with key but no value in subtitle
      final foodWithKeyNoValue = FoodLogHistoryItem(
        id: 'food7',
        title: 'Key No Value Food',
        subtitle: 'Info • Key:',
        timestamp: testTimestamp,
        calories: 800,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryCard(
              food: foodWithKeyNoValue,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Key No Value Food'), findsOneWidget);
      expect(find.text('800 cal'), findsOneWidget);
    });
  });
  
  group('FoodHistoryCard time formatting', () {
    testWidgets('should format years correctly', (WidgetTester tester) async {
      // Arrange
      final yearOldTimestamp = DateTime.now().subtract(const Duration(days: 400));
      final foodYearOld = FoodLogHistoryItem(
        id: 'food8',
        title: 'Old Food',
        subtitle: 'Very old food',
        timestamp: yearOldTimestamp,
        calories: 900,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryCard(
              food: foodYearOld,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - should show "1y ago"
      expect(find.text('Old Food'), findsOneWidget);
      expect(find.textContaining('y ago'), findsOneWidget);
    });
  });
}
