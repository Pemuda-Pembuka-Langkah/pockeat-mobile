import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';

// Mock classes
class MockFoodImageAnalysisService extends Mock
    implements FoodImageAnalysisService {}

class MockFoodScanRepository extends Mock implements FoodScanRepository {}

class MockFile extends Mock implements File {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late FoodScanPhotoService foodScanPhotoService;
  late MockFoodImageAnalysisService mockFoodImageAnalysisService;
  late MockFoodScanRepository mockFoodScanRepository;
  late MockFile mockFile;
  late MockUuid mockUuid;
  late FoodAnalysisResult analysisResult;
  late FoodAnalysisResult correctedResult;

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(MockFile());

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
    );

    // Daftarkan mock services ke GetIt dengan cara yang aman
    final getIt = GetIt.instance;

    mockFoodScanRepository = MockFoodScanRepository();

    if (getIt.isRegistered<FoodScanRepository>()) {
      getIt.unregister<FoodScanRepository>();
    }
    getIt.registerSingleton<FoodScanRepository>(mockFoodScanRepository);

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
          .thenThrow(Exception('Service error'));

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

    test('should handle empty user comment', () async {
      // Arrange
      const userComment = '';

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

    test('should forward specific error message from service', () async {
      // Arrange
      const userComment = 'This is brown rice';
      const specificError = 'Cannot process image correction';

      when(() => mockFoodImageAnalysisService.correctAnalysis(any(), any()))
          .thenThrow(Exception(specificError));

      // Act & Assert
      expect(
        () => foodScanPhotoService.correctFoodAnalysis(
            analysisResult, userComment),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains(specificError),
        )),
      );
    });
  });
}