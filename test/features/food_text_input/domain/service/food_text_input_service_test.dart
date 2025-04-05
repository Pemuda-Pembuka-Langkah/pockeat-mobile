import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:uuid/uuid.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

@GenerateMocks([FoodTextAnalysisService, FoodTextInputRepository, Uuid])
import 'food_text_input_service_test.mocks.dart';

void main() {
  late FoodTextInputService foodTextInputService;
  late MockFoodTextAnalysisService mockFoodTextAnalysisService;
  late MockFoodTextInputRepository mockFoodTextInputRepository;
  late MockUuid mockUuid;

  setUp(() {
    mockFoodTextAnalysisService = MockFoodTextAnalysisService();
    mockFoodTextInputRepository = MockFoodTextInputRepository();
    mockUuid = MockUuid();

    // ✅ Directly instantiate FoodTextInputService with mocked dependencies
    foodTextInputService = FoodTextInputService(
      mockFoodTextAnalysisService,
      mockFoodTextInputRepository,
    );
  });

  group('FoodTextInputService', () {
    final testDateTime = DateTime(2023, 1, 1);
    final testFoodAnalysis = FoodAnalysisResult(
      id: '123',
      foodName: 'Test Food',
      ingredients: [
        Ingredient(name: 'Test Ingredient', servings: 100),
      ],
      nutritionInfo: NutritionInfo(
        calories: 200,
        protein: 10,
        carbs: 20,
        fat: 5,
        sodium: 300,
        fiber: 5,
        sugar: 10,
      ),
      warnings: ['Test warning'],
      timestamp: testDateTime,
    );

    test('analyzeFoodText should return analysis result', () async {
      when(mockFoodTextAnalysisService.analyze('test food'))
          .thenAnswer((_) async => testFoodAnalysis);

      final result = await foodTextInputService.analyzeFoodText('test food');

      expect(result, equals(testFoodAnalysis));
      verify(mockFoodTextAnalysisService.analyze('test food')).called(1);
    });

    test('analyzeFoodText should handle errors', () async {
      when(mockFoodTextAnalysisService.analyze('error text'))
          .thenThrow(Exception('Analysis error'));

      expect(() => foodTextInputService.analyzeFoodText('error text'),
          throwsA(isA<Exception>()));
      verify(mockFoodTextAnalysisService.analyze('error text')).called(1);
    });

    test('saveFoodAnalysis should save analysis with existing ID', () async {
      when(mockFoodTextInputRepository.save(testFoodAnalysis, '123'))
          .thenAnswer((_) async => 'save-id-123');

      final result =
          await foodTextInputService.saveFoodAnalysis(testFoodAnalysis);

      expect(result, 'Food analysis saved successfully');
      verify(mockFoodTextInputRepository.save(testFoodAnalysis, '123'))
          .called(1);
    });

    test('saveFoodAnalysis should handle errors', () async {
      when(mockFoodTextInputRepository.save(any, any))
          .thenThrow(Exception('Save error'));

      expect(() => foodTextInputService.saveFoodAnalysis(testFoodAnalysis),
          throwsA(isA<Exception>()));
      verify(mockFoodTextInputRepository.save(testFoodAnalysis, '123'))
          .called(1);
    });

    test('correctFoodAnalysis should return corrected analysis', () async {
      final correctedAnalysis =
          testFoodAnalysis.copyWith(foodName: 'Corrected Food');
      when(mockFoodTextAnalysisService.correctAnalysis(
              testFoodAnalysis, 'correction comment'))
          .thenAnswer((_) async => correctedAnalysis);

      final result = await foodTextInputService.correctFoodAnalysis(
          testFoodAnalysis, 'correction comment');

      expect(result, equals(correctedAnalysis));
      verify(mockFoodTextAnalysisService.correctAnalysis(
              testFoodAnalysis, 'correction comment'))
          .called(1);
    });

    test('correctFoodAnalysis should handle errors', () async {
      when(mockFoodTextAnalysisService.correctAnalysis(any, any))
          .thenThrow(Exception('Correction error'));

      expect(
          () => foodTextInputService.correctFoodAnalysis(
              testFoodAnalysis, 'correction comment'),
          throwsA(isA<Exception>()));
      verify(mockFoodTextAnalysisService.correctAnalysis(
              testFoodAnalysis, 'correction comment'))
          .called(1);
    });

    test('getAllFoodAnalysis should return all food analysis results',
        () async {
      final List<FoodAnalysisResult> analysisResults = [testFoodAnalysis];
      when(mockFoodTextInputRepository.getAll())
          .thenAnswer((_) async => analysisResults);

      final results = await foodTextInputService.getAllFoodAnalysis();

      expect(results, equals(analysisResults));
      verify(mockFoodTextInputRepository.getAll()).called(1);
    });
  });
}
