// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
// import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
// import 'package:pockeat/features/food_log_history/services/food_log_history_service_impl.dart';
// import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
// import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

// @GenerateMocks([FoodScanRepository])
// import 'food_log_history_service_test.mocks.dart';

// void main() {
//   late MockFoodScanRepository mockFoodScanRepository;
//   late FoodLogHistoryService foodLogHistoryService;
  
//   setUp(() {
//     mockFoodScanRepository = MockFoodScanRepository();
//     foodLogHistoryService = FoodLogHistoryServiceImpl(
//       foodScanRepository: mockFoodScanRepository,
//     );
//   });
  
//   group('FoodLogHistoryService', () {
//     final now = DateTime.now();
//     final yesterday = now.subtract(const Duration(days: 1));
//     final lastMonth = DateTime(now.year, now.month - 1, 15);
    
//     final foodAnalysisResults = [
//       FoodAnalysisResult(
//         id: 'food1',
//         foodName: 'Chicken Salad',
//         foodImageUrl: 'https://example.com/image1.jpg',
//         timestamp: now,
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
//           Ingredient(name: 'Chicken', servings: 1.0),
//           Ingredient(name: 'Lettuce', servings: 0.5),
//         ],
//         warnings: [],
//       ),
//       FoodAnalysisResult(
//         id: 'food2',
//         foodName: 'Pasta',
//         foodImageUrl: 'https://example.com/image2.jpg',
//         timestamp: yesterday,
//         nutritionInfo: NutritionInfo(
//           calories: 450,
//           protein: 15,
//           carbs: 60,
//           fat: 10,
//           sodium: 200,
//           sugar: 3,
//           fiber: 2,
//         ),
//         ingredients: [
//           Ingredient(name: 'Pasta', servings: 1.0),
//           Ingredient(name: 'Tomato Sauce', servings: 0.5),
//         ],
//         warnings: [],
//       ),
//       FoodAnalysisResult(
//         id: 'food3',
//         foodName: 'Burger',
//         foodImageUrl: 'https://example.com/image3.jpg',
//         timestamp: lastMonth,
//         nutritionInfo: NutritionInfo(
//           calories: 650,
//           protein: 30,
//           carbs: 40,
//           fat: 35,
//           sodium: 800,
//           sugar: 8,
//           fiber: 1,
//         ),
//         ingredients: [
//           Ingredient(name: 'Beef Patty', servings: 1.0),
//           Ingredient(name: 'Bun', servings: 1.0),
//         ],
//         warnings: ['High sodium content'],
//       ),
//     ];
    
//     test('getAllFoodLogs should return all food logs', () async {
//       // Arrange
//       when(mockFoodScanRepository.getAll(
//         orderBy: anyNamed('orderBy'),
//         descending: anyNamed('descending'),
//         limit: anyNamed('limit'),
//       )).thenAnswer((_) async => foodAnalysisResults);
      
//       // Act
//       final result = await foodLogHistoryService.getAllFoodLogs();
      
//       // Assert
//       expect(result.length, 3);
//       expect(result[0].title, 'Chicken Salad');
//       expect(result[1].title, 'Pasta');
//       expect(result[2].title, 'Burger');
      
//       verify(mockFoodScanRepository.getAll(
//         orderBy: anyNamed('orderBy'),
//         descending: anyNamed('descending'),
//         limit: anyNamed('limit'),
//       )).called(1);
//     });
    
//     test('getAllFoodLogs with limit should return limited food logs', () async {
//       // Arrange
//       when(mockFoodScanRepository.getAll(
//         orderBy: anyNamed('orderBy'),
//         descending: anyNamed('descending'),
//         limit: 2,
//       )).thenAnswer((_) async => foodAnalysisResults.take(2).toList());
      
//       // Act
//       final result = await foodLogHistoryService.getAllFoodLogs(limit: 2);
      
//       // Assert
//       expect(result.length, 2);
//       expect(result[0].title, 'Chicken Salad');
//       expect(result[1].title, 'Pasta');
      
//       verify(mockFoodScanRepository.getAll(
//         orderBy: anyNamed('orderBy'),
//         descending: anyNamed('descending'),
//         limit: 2,
//       )).called(1);
//     });
    
//     test('getFoodLogsByDate should return food logs for a specific date', () async {
//       // Arrange
//       when(mockFoodScanRepository.getAnalysisResultsByDate(any, limit: anyNamed('limit')))
//           .thenAnswer((_) async => [foodAnalysisResults[0]]);
      
//       // Act
//       final result = await foodLogHistoryService.getFoodLogsByDate(now);
      
//       // Assert
//       expect(result.length, 1);
//       expect(result[0].title, 'Chicken Salad');
      
//       verify(mockFoodScanRepository.getAnalysisResultsByDate(any, limit: anyNamed('limit'))).called(1);
//     });
    
//     test('getFoodLogsByMonth should return food logs for a specific month', () async {
//       // Arrange
//       when(mockFoodScanRepository.getAnalysisResultsByMonth(any, any, limit: anyNamed('limit')))
//           .thenAnswer((_) async => [foodAnalysisResults[0], foodAnalysisResults[1]]);
      
//       // Act
//       final result = await foodLogHistoryService.getFoodLogsByMonth(now.month, now.year);
      
//       // Assert
//       expect(result.length, 2);
//       expect(result[0].title, 'Chicken Salad');
//       expect(result[1].title, 'Pasta');
      
//       verify(mockFoodScanRepository.getAnalysisResultsByMonth(any, any, limit: anyNamed('limit'))).called(1);
//     });
    
//     test('searchFoodLogs should return food logs matching the query', () async {
//       // Arrange
//       when(mockFoodScanRepository.getAll(
//         orderBy: anyNamed('orderBy'),
//         descending: anyNamed('descending'),
//         limit: anyNamed('limit'),
//       )).thenAnswer((_) async => foodAnalysisResults);
      
//       // Act
//       final result = await foodLogHistoryService.searchFoodLogs('chicken');
      
//       // Assert
//       expect(result.length, 1);
//       expect(result[0].title, 'Chicken Salad');
      
//       verify(mockFoodScanRepository.getAll(
//         orderBy: anyNamed('orderBy'),
//         descending: anyNamed('descending'),
//         limit: anyNamed('limit'),
//       )).called(1);
//     });
//   });
// }
