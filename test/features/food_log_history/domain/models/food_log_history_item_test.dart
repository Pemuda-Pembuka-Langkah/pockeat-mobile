import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

void main() {
  group('FoodLogHistoryItem', () {
    test('should create a valid FoodLogHistoryItem', () {
      final timestamp = DateTime.now();

      final item = FoodLogHistoryItem(
        id: '123',
        title: 'Chicken Salad',
        subtitle: '350 cal, 20g protein',
        timestamp: timestamp,
        calories: 350,
        sourceId: 'source123',
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(item.id, '123');
      expect(item.title, 'Chicken Salad');
      expect(item.subtitle, '350 cal, 20g protein');
      expect(item.timestamp, timestamp);
      expect(item.calories, 350);
      expect(item.sourceId, 'source123');
      expect(item.imageUrl, 'https://example.com/image.jpg');
    });

    test('should create FoodLogHistoryItem from FoodAnalysisResult', () {
      final timestamp = DateTime.now();

      final foodAnalysisResult = FoodAnalysisResult(
        id: 'source123',
        foodName: 'Chicken Salad',
        foodImageUrl: 'https://example.com/image.jpg',
        timestamp: timestamp,
        nutritionInfo: NutritionInfo(
          calories: 350,
          protein: 20,
          carbs: 15,
          fat: 12,
          sodium: 300,
          sugar: 5,
          fiber: 3,
        ),
        ingredients: [
          Ingredient(name: 'Chicken', servings: 1),
          Ingredient(name: 'Lettuce', servings: 2),
        ],
        warnings: [],
      );

      final item =
          FoodLogHistoryItem.fromFoodAnalysisResult(foodAnalysisResult);

      expect(item.title, 'Chicken Salad');
      expect(item.subtitle.contains('350 cal'), isTrue);
      expect(item.subtitle.contains('20g protein'), isTrue);
      expect(item.timestamp, timestamp);
      expect(item.calories, 350);
      expect(item.sourceId, 'source123');
      expect(item.imageUrl, 'https://example.com/image.jpg');
    });

    test('should convert FoodLogHistoryItem to and from JSON', () {
      final timestamp = DateTime.now();

      final item = FoodLogHistoryItem(
        id: '123',
        title: 'Chicken Salad',
        subtitle: '350 cal, 20g protein',
        timestamp: timestamp,
        calories: 350,
        sourceId: 'source123',
        imageUrl: 'https://example.com/image.jpg',
      );

      final json = item.toJson();
      final fromJson = FoodLogHistoryItem.fromJson(json);

      expect(fromJson.id, item.id);
      expect(fromJson.title, item.title);
      expect(fromJson.subtitle, item.subtitle);
      expect(fromJson.timestamp.millisecondsSinceEpoch,
          item.timestamp.millisecondsSinceEpoch);
      expect(fromJson.calories, item.calories);
      expect(fromJson.sourceId, item.sourceId);
      expect(fromJson.imageUrl, item.imageUrl);
    });

    group('timeAgo property', () {
      test('should return "Just now" for current time', () {
        final now = DateTime.now();
        final item = FoodLogHistoryItem(
          id: '123',
          title: 'Test Food',
          subtitle: 'Test subtitle',
          timestamp: now,
          calories: 100,
        );

        expect(item.timeAgo, 'Just now');
      });

      test('should return minutes ago', () {
        final now = DateTime.now();
        final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
        final item = FoodLogHistoryItem(
          id: '123',
          title: 'Test Food',
          subtitle: 'Test subtitle',
          timestamp: fiveMinutesAgo,
          calories: 100,
        );

        expect(item.timeAgo, '5m ago');
      });

      test('should return hours ago', () {
        final now = DateTime.now();
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        final item = FoodLogHistoryItem(
          id: '123',
          title: 'Test Food',
          subtitle: 'Test subtitle',
          timestamp: twoHoursAgo,
          calories: 100,
        );

        expect(item.timeAgo, '2h ago');
      });

      test('should return days ago', () {
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        final item = FoodLogHistoryItem(
          id: '123',
          title: 'Test Food',
          subtitle: 'Test subtitle',
          timestamp: threeDaysAgo,
          calories: 100,
        );

        expect(item.timeAgo, '3d ago');
      });

      test('should return months ago', () {
        final now = DateTime.now();
        final twoMonthsAgo =
            now.subtract(const Duration(days: 60)); // ~2 months
        final item = FoodLogHistoryItem(
          id: '123',
          title: 'Test Food',
          subtitle: 'Test subtitle',
          timestamp: twoMonthsAgo,
          calories: 100,
        );

        expect(item.timeAgo, '2mo ago');
      });

      test('should return years ago', () {
        final now = DateTime.now();
        final oneYearAgo = now.subtract(const Duration(days: 366)); // ~1 year
        final item = FoodLogHistoryItem(
          id: '123',
          title: 'Test Food',
          subtitle: 'Test subtitle',
          timestamp: oneYearAgo,
          calories: 100,
        );

        expect(item.timeAgo, '1y ago');
      });
    });
  });
}
