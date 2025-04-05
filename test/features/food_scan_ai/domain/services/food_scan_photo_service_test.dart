import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/api_scan/services/food/nutrition_label_analysis_service.dart';

// Mock classes
class MockFoodImageAnalysisService extends Mock
    implements FoodImageAnalysisService {}

class MockFoodScanRepository extends Mock implements FoodScanRepository {}

class MockFile extends Mock implements File {}

class MockUuid extends Mock implements Uuid {}

class MockNutritionLabelAnalysisService extends Mock implements NutritionLabelAnalysisService {}

void main() {
  late FoodScanPhotoService foodScanPhotoService;
  late MockFoodImageAnalysisService mockFoodImageAnalysisService;
  late MockFoodScanRepository mockFoodScanRepository;
  late MockFile mockFile;
  late MockUuid mockUuid;
  late FoodAnalysisResult analysisResult;
  late FoodAnalysisResult correctedResult;
  late DateTime testDateTime;
  late MockNutritionLabelAnalysisService mockNutritionLabelAnalysisService;

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(MockFile());
    
    testDateTime = DateTime(2025, 3, 13); // Fixed test date
    
    analysisResult = FoodAnalysisResult(
      foodName: 'Test Food',
      ingredients: [Ingredient(name: 'Test Ingredient', servings: 1)],
      nutritionInfo: NutritionInfo(
        calories: 250,
        protein: 10,
        carbs: 30,
        fat: 12,
        sodium: 100,
        sugar: 10,
        fiber: 5,
      ),
      warnings: [],
      timestamp: testDateTime,
    );
    registerFallbackValue(analysisResult);
    registerFallbackValue('');
  });

  setUp(() {
    // Inisialisasi mocks
    mockFile = MockFile();
    mockUuid = MockUuid();

    // Initialize the corrected result
    correctedResult = FoodAnalysisResult(
      foodName: 'Corrected Food',
      ingredients: [
        Ingredient(name: 'Corrected Ingredient', servings: 2),
        Ingredient(name: 'New Ingredient', servings: 1),
      ],
      nutritionInfo: NutritionInfo(
        calories: 300,
        protein: 15,
        carbs: 25,
        fat: 15,
        sodium: 120,
        sugar: 8,
        fiber: 6,
      ),
      warnings: [],
      timestamp: testDateTime,
    );

    // Daftarkan mock services ke GetIt dengan cara yang aman
    final getIt = GetIt.instance;

    mockFoodScanRepository = MockFoodScanRepository();

    if (getIt.isRegistered<FoodScanRepository>()) {
      getIt.unregister<FoodScanRepository>();
    }
    getIt.registerSingleton<FoodScanRepository>(mockFoodScanRepository);

    mockNutritionLabelAnalysisService = MockNutritionLabelAnalysisService();

    if (getIt.isRegistered<NutritionLabelAnalysisService>()) {
      getIt.unregister<NutritionLabelAnalysisService>();
    }
    getIt.registerSingleton<NutritionLabelAnalysisService>(
        mockNutritionLabelAnalysisService);

    mockFoodImageAnalysisService = MockFoodImageAnalysisService();

    if (getIt.isRegistered<FoodImageAnalysisService>()) {
      getIt.unregister<FoodImageAnalysisService>();
    }

    getIt.registerSingleton<FoodImageAnalysisService>(
        mockFoodImageAnalysisService);

    foodScanPhotoService = FoodScanPhotoService();

    if (getIt.isRegistered<FoodScanPhotoService>()) {
      getIt.unregister<FoodScanPhotoService>();
    }
    getIt.registerSingleton<FoodScanPhotoService>(foodScanPhotoService);
  });

  tearDown(() {
    // Unregister semua mocks dari GetIt dengan cara yang aman
    final getIt = GetIt.instance;

    try {
      if (getIt.isRegistered<FoodImageAnalysisService>()) {
        getIt.unregister<FoodImageAnalysisService>();
      }
    } catch (e) {
      // Ignore error jika service belum terdaftar
    }

    try {
      if (getIt.isRegistered<FoodScanPhotoService>()) {
        getIt.unregister<FoodScanPhotoService>();
      }
    } catch (e) {
      // Ignore error jika service belum terdaftar
    }
  });

  group('analyzeFoodPhoto', () {
    test('should return FoodAnalysisResult when analysis is successful',
        () async {
      // Arrange
      final expectedResult = FoodAnalysisResult(
        foodName: 'Test Food',
        ingredients: [Ingredient(name: 'Test Ingredient', servings: 1)],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 10,
          carbs: 30,
          fat: 12,
          sodium: 100,
          sugar: 10,
          fiber: 5,
        ),
        warnings: [],
        timestamp: testDateTime,
      );

      when(() => mockFoodImageAnalysisService.analyze(any()))
          .thenAnswer((_) async => expectedResult);

      // Act
      final result = await foodScanPhotoService.analyzeFoodPhoto(mockFile);

      // Assert
      expect(result, equals(expectedResult));
      verify(() => mockFoodImageAnalysisService.analyze(mockFile)).called(1);
    });

    test('should throw Exception when analysis fails', () async {
      // Arrange
      when(() => mockFoodImageAnalysisService.analyze(any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => foodScanPhotoService.analyzeFoodPhoto(mockFile),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to analyze food photo'),
        )),
      );
      verify(() => mockFoodImageAnalysisService.analyze(mockFile)).called(1);
    });
  });

  group('saveFoodAnalysis', () {
    test('should return success message when saving is successful', () async {
      final uuid = '123e4567-e89b-12d3-a456-426614174000';

      when(() => mockUuid.v4()).thenReturn(uuid);
      when(() => mockFoodScanRepository.save(any(), any()))
          .thenAnswer((_) async => 'Successfully saved food analysis');

      // Act
      final result =
          await foodScanPhotoService.saveFoodAnalysis(analysisResult);

      // Assert
      expect(result, equals('Successfully saved food analysis'));
      verify(() => mockFoodScanRepository.save(any(), any())).called(1);
    });
  });

  group('correctFoodAnalysis', () {
    test('should return corrected FoodAnalysisResult when correction is successful',
        () async {
      // Arrange
      const userComment = 'This is brown rice, not white rice';

      when(() => mockFoodImageAnalysisService.correctAnalysis(any(), any()))
          .thenAnswer((_) async => correctedResult);

      // Act
      final result = await foodScanPhotoService.correctFoodAnalysis(
          analysisResult, userComment);

      // Assert
      expect(result, equals(correctedResult));
      verify(() => mockFoodImageAnalysisService.correctAnalysis(
          analysisResult, userComment)).called(1);
    });

    test('should throw Exception when correction fails', () async {
      // Arrange
      const userComment = 'This is brown rice, not white rice';

      when(() => mockFoodImageAnalysisService.correctAnalysis(any(), any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => foodScanPhotoService.correctFoodAnalysis(
            analysisResult, userComment),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to correct food analysis'),
        )),
      );
      verify(() => mockFoodImageAnalysisService.correctAnalysis(
          analysisResult, userComment)).called(1);
    });
  });

  group('getAllFoodAnalysis', () {
    test('should return list of FoodAnalysisResult when retrieval is successful',
        () async {
      // Arrange
      final expectedResults = [analysisResult, correctedResult];

      when(() => mockFoodScanRepository.getAll())
          .thenAnswer((_) async => expectedResults);

      // Act
      final results = await foodScanPhotoService.getAllFoodAnalysis();

      // Assert
      expect(results, equals(expectedResults));
      expect(results.length, equals(2));
      expect(results[0].timestamp, equals(testDateTime));
      expect(results[1].timestamp, equals(testDateTime));
      verify(() => mockFoodScanRepository.getAll()).called(1);
    });

    test('should return empty list when no food analysis results are found',
        () async {
      // Arrange
      when(() => mockFoodScanRepository.getAll())
          .thenAnswer((_) async => []);

      // Act
      final results = await foodScanPhotoService.getAllFoodAnalysis();

      // Assert
      expect(results, isEmpty);
      verify(() => mockFoodScanRepository.getAll()).called(1);
    });
  });

  group('analyzeNutritionLabelPhoto', () {
    test('should return FoodAnalysisResult when nutrition label analysis is successful',
        () async {
      // Arrange
      const double servingSize = 2.0;
      final expectedResult = FoodAnalysisResult(
        foodName: 'Test Food Label',
        ingredients: [Ingredient(name: 'Test Ingredient', servings: servingSize)],
        nutritionInfo: NutritionInfo(
          calories: 250 * servingSize,
          protein: 10 * servingSize,
          carbs: 30 * servingSize,
          fat: 12 * servingSize,
          sodium: 100 * servingSize,
          sugar: 10 * servingSize,
          fiber: 5 * servingSize,
        ),
        warnings: [],
        timestamp: testDateTime,
      );

      when(() => mockNutritionLabelAnalysisService.analyze(any(), any()))
          .thenAnswer((_) async => expectedResult);

      // Act
      final result = await foodScanPhotoService.analyzeNutritionLabelPhoto(
          mockFile, servingSize);

      // Assert
      expect(result, equals(expectedResult));
      verify(() => mockNutritionLabelAnalysisService.analyze(mockFile, servingSize))
          .called(1);
    });

    test('should throw Exception when nutrition label analysis fails', () async {
      // Arrange
      const double servingSize = 1.5;
      when(() => mockNutritionLabelAnalysisService.analyze(any(), any()))
          .thenThrow(Exception('Failed to process nutrition label'));

      // Act & Assert
      expect(
        () => foodScanPhotoService.analyzeNutritionLabelPhoto(mockFile, servingSize),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to analyze food photo'),
        )),
      );
      verify(() => mockNutritionLabelAnalysisService.analyze(mockFile, servingSize))
          .called(1);
    });
  });

  group('correctNutritionLabelAnalysis', () {
    test(
        'should return corrected FoodAnalysisResult when nutrition label correction is successful',
        () async {
      // Arrange
      const userComment = 'The serving size should be larger';
      const servingSize = 2.5;
      final expectedResult = FoodAnalysisResult(
        foodName: 'Corrected Label Food',
        ingredients: [
          Ingredient(name: 'Corrected Ingredient', servings: servingSize),
        ],
        nutritionInfo: NutritionInfo(
          calories: 300 * servingSize,
          protein: 15 * servingSize,
          carbs: 25 * servingSize,
          fat: 15 * servingSize,
          sodium: 120 * servingSize,
          sugar: 8 * servingSize,
          fiber: 6 * servingSize,
        ),
        warnings: [],
        timestamp: testDateTime,
      );

      when(() => mockNutritionLabelAnalysisService.correctAnalysis(
              any(), any(), any()))
          .thenAnswer((_) async => expectedResult);

      // Act
      final result = await foodScanPhotoService.correctNutritionLabelAnalysis(
          analysisResult, userComment, servingSize);

      // Assert
      expect(result, equals(expectedResult));
      verify(() => mockNutritionLabelAnalysisService.correctAnalysis(
          analysisResult, userComment, servingSize)).called(1);
    });

    test('should throw Exception when nutrition label correction fails', () async {
      // Arrange
      const userComment = 'The serving size should be larger';
      const servingSize = 2.5;

      when(() => mockNutritionLabelAnalysisService.correctAnalysis(
              any(), any(), any()))
          .thenThrow(Exception('Failed to process correction'));

      // Act & Assert
      expect(
        () => foodScanPhotoService.correctNutritionLabelAnalysis(
            analysisResult, userComment, servingSize),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to correct food analysis'),
        )),
      );
      verify(() => mockNutritionLabelAnalysisService.correctAnalysis(
          analysisResult, userComment, servingSize)).called(1);
    });
  });
}