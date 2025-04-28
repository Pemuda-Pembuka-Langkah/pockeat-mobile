// // Package imports:
// import 'package:flutter_test/flutter_test.dart';

// // Project imports:
// import 'package:pockeat/features/api_scan/models/food_analysis.dart';
// import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';

// void main() {
//   group('FoodLogHistoryItem', () {
//     test('should create a valid FoodLogHistoryItem', () {
//       final timestamp = DateTime.now();

//       final item = FoodLogHistoryItem(
//         id: '123',
//         title: 'Chicken Salad',
//         subtitle: '350 cal, 20g protein',
//         timestamp: timestamp,
//         calories: 350,
//         sourceId: 'source123',
//         imageUrl: 'https://example.com/image.jpg',
//         protein: 20,
//         carbs: 15,
//         fat: 12,
//       );

//       expect(item.id, '123');
//       expect(item.title, 'Chicken Salad');
//       expect(item.subtitle, '350 cal, 20g protein');
//       expect(item.timestamp, timestamp);
//       expect(item.calories, 350);
//       expect(item.sourceId, 'source123');
//       expect(item.imageUrl, 'https://example.com/image.jpg');
//       expect(item.protein, 20);
//       expect(item.carbs, 15);
//       expect(item.fat, 12);
//     });

//     test('should create FoodLogHistoryItem from FoodAnalysisResult', () {
//       final timestamp = DateTime.now();

//       final foodAnalysisResult = FoodAnalysisResult(
//         id: 'source123',
//         foodName: 'Chicken Salad',
//         foodImageUrl: 'https://example.com/image.jpg',
//         timestamp: timestamp,
//         nutritionInfo: NutritionInfo(
//           calories: 350,
//           protein: 20,
//           carbs: 15,
//           fat: 12,
//           sodium: 300,
//           sugar: 5,
//           fiber: 3,
//         ),
//         ingredients: [
//           Ingredient(name: 'Chicken', servings: 1),
//           Ingredient(name: 'Lettuce', servings: 2),
//         ],
//         warnings: [],
//       );

//       final item =
//           FoodLogHistoryItem.fromFoodAnalysisResult(foodAnalysisResult);

//       expect(item.title, 'Chicken Salad');
//       expect(item.subtitle.contains('350 cal'), isFalse);
//       expect(item.subtitle.contains('20g protein'), isTrue);
//       expect(item.timestamp, timestamp);
//       expect(item.calories, 350);
//       expect(item.sourceId, 'source123');
//       expect(item.imageUrl, 'https://example.com/image.jpg');
//       expect(item.protein, 20);
//       expect(item.carbs, 15);
//       expect(item.fat, 12);
//     });

//     test('should convert FoodLogHistoryItem to and from JSON', () {
//       final timestamp = DateTime.now();

//       final item = FoodLogHistoryItem(
//         id: '123',
//         title: 'Chicken Salad',
//         subtitle: '350 cal, 20g protein',
//         timestamp: timestamp,
//         calories: 350,
//         sourceId: 'source123',
//         imageUrl: 'https://example.com/image.jpg',
//         protein: 20,
//         carbs: 15,
//         fat: 12,
//       );

//       final json = item.toJson();
//       final fromJson = FoodLogHistoryItem.fromJson(json);

//       expect(fromJson.id, item.id);
//       expect(fromJson.title, item.title);
//       expect(fromJson.subtitle, item.subtitle);
//       expect(fromJson.timestamp.millisecondsSinceEpoch,
//           item.timestamp.millisecondsSinceEpoch);
//       expect(fromJson.calories, item.calories);
//       expect(fromJson.sourceId, item.sourceId);
//       expect(fromJson.imageUrl, item.imageUrl);
//       expect(fromJson.protein, item.protein);
//       expect(fromJson.carbs, item.carbs);
//       expect(fromJson.fat, item.fat);
//     });

//     group('timeAgo property', () {
//       test('should return "Just now" for current time', () {
//         final now = DateTime.now();
//         final item = FoodLogHistoryItem(
//           id: '123',
//           title: 'Test Food',
//           subtitle: 'Test subtitle',
//           timestamp: now,
//           calories: 100,
//         );

//         expect(item.timeAgo, 'Just now');
//       });

//       test('should return minutes ago', () {
//         final now = DateTime.now();
//         final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
//         final item = FoodLogHistoryItem(
//           id: '123',
//           title: 'Test Food',
//           subtitle: 'Test subtitle',
//           timestamp: fiveMinutesAgo,
//           calories: 100,
//         );

//         expect(item.timeAgo, '5m ago');
//       });

//       test('should return hours ago', () {
//         final now = DateTime.now();
//         final twoHoursAgo = now.subtract(const Duration(hours: 2));
//         final item = FoodLogHistoryItem(
//           id: '123',
//           title: 'Test Food',
//           subtitle: 'Test subtitle',
//           timestamp: twoHoursAgo,
//           calories: 100,
//         );

//         expect(item.timeAgo, '2h ago');
//       });

//       test('should return days ago', () {
//         final now = DateTime.now();
//         final threeDaysAgo = now.subtract(const Duration(days: 3));
//         final item = FoodLogHistoryItem(
//           id: '123',
//           title: 'Test Food',
//           subtitle: 'Test subtitle',
//           timestamp: threeDaysAgo,
//           calories: 100,
//         );

//         expect(item.timeAgo, '3d ago');
//       });

//       test('should return months ago', () {
//         final now = DateTime.now();
//         final twoMonthsAgo =
//             now.subtract(const Duration(days: 60)); // ~2 months
//         final item = FoodLogHistoryItem(
//           id: '123',
//           title: 'Test Food',
//           subtitle: 'Test subtitle',
//           timestamp: twoMonthsAgo,
//           calories: 100,
//         );

//         expect(item.timeAgo, '2mo ago');
//       });

//       test('should return years ago', () {
//         final now = DateTime.now();
//         final oneYearAgo = now.subtract(const Duration(days: 366)); // ~1 year
//         final item = FoodLogHistoryItem(
//           id: '123',
//           title: 'Test Food',
//           subtitle: 'Test subtitle',
//           timestamp: oneYearAgo,
//           calories: 100,
//         );

//         expect(item.timeAgo, '1y ago');
//       });
//     });
    
//     group('Edge cases', () {
//       test('should handle null macronutrient values', () {
//         final timestamp = DateTime.now();
//         final item = FoodLogHistoryItem(
//           id: '123',
//           title: 'Chicken Salad',
//           subtitle: '350 cal',
//           timestamp: timestamp,
//           calories: 350,
//           // Leaving macronutrient fields as null
//         );
        
//         expect(item.protein, isNull);
//         expect(item.carbs, isNull);
//         expect(item.fat, isNull);
        
//         // Test JSON serialization with null values
//         final json = item.toJson();
//         final fromJson = FoodLogHistoryItem.fromJson(json);
        
//         expect(fromJson.protein, isNull);
//         expect(fromJson.carbs, isNull);
//         expect(fromJson.fat, isNull);
//       });
      
//       test('should handle different numeric types for macronutrients', () {
//         final timestamp = DateTime.now();
//         final item = FoodLogHistoryItem(
//           id: '123',
//           title: 'Chicken Salad',
//           subtitle: '350 cal',
//           timestamp: timestamp,
//           calories: 350,
//           protein: 20.5,  // Double value
//           carbs: 15,      // Integer value
//           fat: 12.3,      // Double value
//         );
        
//         expect(item.protein, 20.5);
//         expect(item.carbs, 15);
//         expect(item.fat, 12.3);
        
//         // Test JSON serialization with different numeric types
//         final json = item.toJson();
//         final fromJson = FoodLogHistoryItem.fromJson(json);
        
//         expect(fromJson.protein, 20.5);
//         expect(fromJson.carbs, 15);
//         expect(fromJson.fat, 12.3);
//       });
      
//       test('should correctly handle FoodAnalysisResult with zero values', () {
//         final timestamp = DateTime.now();

//         final foodAnalysisResult = FoodAnalysisResult(
//           id: 'source123',
//           foodName: 'Diet Water',
//           foodImageUrl: 'https://example.com/water.jpg',
//           timestamp: timestamp,
//           nutritionInfo: NutritionInfo(
//             calories: 0,
//             protein: 0,
//             carbs: 0,
//             fat: 0,
//             sodium: 0,
//             sugar: 0,
//             fiber: 0,
//           ),
//           ingredients: [],
//           warnings: [],
//         );

//         final item = FoodLogHistoryItem.fromFoodAnalysisResult(foodAnalysisResult);

//         expect(item.calories, 0);
//         expect(item.protein, 0);
//         expect(item.carbs, 0);
//         expect(item.fat, 0);
//       });
//     });
//   });
// }
