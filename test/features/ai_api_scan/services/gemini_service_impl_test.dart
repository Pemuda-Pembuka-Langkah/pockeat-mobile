// test/features/ai_api_scan/services/gemini_service_impl_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

// Define mock classes with mocktail
class MockFoodTextAnalysisService extends Mock implements FoodTextAnalysisService {}
class MockFoodImageAnalysisService extends Mock implements FoodImageAnalysisService {}
class MockNutritionLabelAnalysisService extends Mock implements NutritionLabelAnalysisService {}
class MockExerciseAnalysisService extends Mock implements ExerciseAnalysisService {}
class MockFile extends Mock implements File {}

void main() {
  late MockFoodTextAnalysisService mockTextService;
  late MockFoodImageAnalysisService mockImageService;
  late MockNutritionLabelAnalysisService mockNutritionService;
  late MockExerciseAnalysisService mockExerciseService;
  late GeminiServiceImpl service;
  late MockFile mockFile;

  setUp(() {
    mockTextService = MockFoodTextAnalysisService();
    mockImageService = MockFoodImageAnalysisService();
    mockNutritionService = MockNutritionLabelAnalysisService();
    mockExerciseService = MockExerciseAnalysisService();
    mockFile = MockFile();
    
    // Register fallbacks for function argument types
    registerFallbackValue('dummy-text');
    registerFallbackValue(File('dummy-path'));
    registerFallbackValue(1.0);
    
    service = GeminiServiceImpl(
      foodTextAnalysisService: mockTextService,
      foodImageAnalysisService: mockImageService,
      nutritionLabelService: mockNutritionService,
      exerciseAnalysisService: mockExerciseService,
    );
  });

  group('GeminiServiceImpl', () {
    test('should delegate analyzeFoodByText to food text analysis service', () async {
      // Arrange
      const description = 'Apple pie';
      final expectedResult = FoodAnalysisResult(
        foodName: 'Apple Pie',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 2,
          carbs: 40,
          fat: 12,
          sodium: 150,
          fiber: 3,
          sugar: 10,
        ),
        warnings: [],
      );
      
      // Setup the mock
      when(() => mockTextService.analyze(any()))
        .thenAnswer((_) async => expectedResult);
      
      // Act
      final result = await service.analyzeFoodByText(description);
      
      // Assert
      expect(result, equals(expectedResult));
      verify(() => mockTextService.analyze(description)).called(1);
    });

    test('should delegate analyzeFoodByImage to food image analysis service', () async {
      // Arrange
      final expectedResult = FoodAnalysisResult(
        foodName: 'Burger',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 25,
          carbs: 35,
          fat: 22,
          sodium: 800,
          fiber: 2,
          sugar: 8,
        ),
        warnings: [],
      );
      
      // Setup the mock
      when(() => mockImageService.analyze(any()))
        .thenAnswer((_) async => expectedResult);
      
      // Act
      final result = await service.analyzeFoodByImage(mockFile);
      
      // Assert
      expect(result, equals(expectedResult));
      verify(() => mockImageService.analyze(mockFile)).called(1);
    });

    test('should delegate analyzeNutritionLabel to nutrition label service', () async {
      // Arrange
      const servings = 2.5;
      final expectedResult = FoodAnalysisResult(
        foodName: 'Cereal',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 120,
          protein: 3,
          carbs: 24,
          fat: 1,
          sodium: 210,
          fiber: 3,
          sugar: 12,
        ),
        warnings: [],
      );
      
      // Setup the mock
      when(() => mockNutritionService.analyze(any(), any()))
        .thenAnswer((_) async => expectedResult);
      
      // Act
      final result = await service.analyzeNutritionLabel(mockFile, servings);
      
      // Assert
      expect(result, equals(expectedResult));
      verify(() => mockNutritionService.analyze(mockFile, servings)).called(1);
    });

    test('should delegate analyzeExercise to exercise analysis service', () async {
      // Arrange
      const description = 'Running 5km';
      const weight = 70.0;
      final expectedResult = ExerciseAnalysisResult(
        exerciseType: 'Running',
        duration: '30 minutes',
        intensity: 'Moderate',
        estimatedCalories: 350,
        metValue: 8.5,
        summary: 'You performed Running for 30 minutes at Moderate intensity, burning approximately 350 calories.',
        timestamp: DateTime.now(),
        originalInput: description,
      );
      
      // Setup the mock
      when(() => mockExerciseService.analyze(any(), userWeightKg: any(named: 'userWeightKg')))
        .thenAnswer((_) async => expectedResult);
      
      // Act
      final result = await service.analyzeExercise(description, userWeightKg: weight);
      
      // Assert
      expect(result.exerciseType, equals(expectedResult.exerciseType));
      expect(result.duration, equals(expectedResult.duration));
      expect(result.intensity, equals(expectedResult.intensity));
      expect(result.estimatedCalories, equals(expectedResult.estimatedCalories));
      expect(result.metValue, equals(expectedResult.metValue));
      verify(() => mockExerciseService.analyze(description, userWeightKg: weight)).called(1);
    });
  });
}