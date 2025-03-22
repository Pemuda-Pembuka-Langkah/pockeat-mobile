// test/features/ai_api_scan/services/food/food_image_analysis_service_test.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

@GenerateMocks([
  FirebaseFirestore,
  QuerySnapshot,
  Query,
  DocumentReference,
  DocumentSnapshot,
  CollectionReference,
  http.Client,
])
import 'food_image_analysis_service_test.mocks.dart';

// Implementasi MockFile yang lebih baik
class MockFile implements File {
  final String _path;
  final Uint8List _bytes;
  final bool _exists;

  MockFile({
    required String path,
    required Uint8List bytes,
    bool exists = true,
  })  : _path = path,
        _bytes = bytes,
        _exists = exists;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  @override
  String get path => _path;

  @override
  bool existsSync() => _exists;

  @override
  Future<bool> exists() async => _exists;

  // Implement other required methods with empty implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpResponse extends Mock implements http.Response {}

// Fixed mock that doesn't use Mockito for the crucial parts
class MockGenerativeModelWrapper implements GenerativeModelWrapper {
  String? responseText;
  Exception? exceptionToThrow;
  bool wasCalled = false;

  @override
  Future<dynamic> generateContent(dynamic _) async {
    wasCalled = true;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return _MockGenerateContentResponse(responseText);
  }

  void setResponse(String? text) {
    responseText = text;
  }

  void setException(Exception exception) {
    exceptionToThrow = exception;
  }

  // Implement other required methods with empty implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockGenerateContentResponse {
  final String? _text;
  _MockGenerateContentResponse(this._text);
  String? get text => _text;
}

// Custom DocumentSnapshot implementation that doesn't use Mockito
class CustomMockDocumentSnapshot<T extends Map<String, dynamic>>
    implements QueryDocumentSnapshot<T> {
  final String _id;
  final T _data;

  CustomMockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  T data() => _data;

  // Implement other required methods with empty implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Custom QuerySnapshot implementation that doesn't use Mockito
class CustomMockQuerySnapshot<T extends Map<String, dynamic>>
    implements QuerySnapshot<T> {
  final List<QueryDocumentSnapshot<T>> _docs;

  CustomMockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot<T>> get docs => _docs;

  // Implement other required methods with empty implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Implementasi MockFile yang lebih baik
class _ErrorMockFile implements File {
  final String _path;
  final Exception _error;

  _ErrorMockFile({
    required String path,
    required Exception error,
  })  : _path = path,
        _error = error;

  @override
  Future<Uint8List> readAsBytes() async {
    throw _error;
  }

  @override
  String get path => _path;

  @override
  bool existsSync() => false;

  @override
  Future<bool> exists() async => false;

  // Implement other required methods with empty implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Subclass FoodImageAnalysisService untuk mock metode _downloadImageBytes
class TestFoodImageAnalysisService extends FoodImageAnalysisService {
  TestFoodImageAnalysisService({
    required super.apiKey,
    required super.firestore,
    required super.customModelWrapper,
    required super.accurateModelWrapper,
  });

  @override
  Future<Uint8List?> _downloadImageBytes(String imageUrl) async {
    // Selalu mengembalikan null untuk tes
    return null;
  }
}

void main() {
  late FoodImageAnalysisService service;
  late MockFirebaseFirestore mockFirestore;
  late MockGenerativeModelWrapper mockModelWrapper;
  late MockGenerativeModelWrapper mockAccurateModelWrapper;
  late MockFile mockFile;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;

  const String testApiKey = 'test-api-key';
  final testImageBytes = Uint8List.fromList([1, 2, 3, 4]);

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockModelWrapper = MockGenerativeModelWrapper();
    mockAccurateModelWrapper = MockGenerativeModelWrapper();
    mockFile = MockFile(path: '/test/path/to/image.jpg', bytes: testImageBytes);
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();

    // Setup Firestore mocks, hanya collection dan orderBy
    when(mockFirestore.collection('fooddataset')).thenReturn(mockCollection);
    when(mockCollection.orderBy('title')).thenReturn(mockQuery);

    // Mengembalikan baris yang dikomentari
    when(mockQuery.startAt(any)).thenReturn(mockQuery);
    when(mockQuery.endAt(any)).thenReturn(mockQuery);
    when(mockQuery.limit(any)).thenReturn(mockQuery);

    service = TestFoodImageAnalysisService(
      apiKey: testApiKey,
      firestore: mockFirestore,
      customModelWrapper: mockModelWrapper,
      accurateModelWrapper: mockAccurateModelWrapper,
    );
  });

  group('FoodImageAnalysisService', () {
    group('analyze', () {
      test('should successfully analyze food image with similar foods found',
          () async {
        // Setup test data
        mockModelWrapper.setResponse(
            '{"food_name": "Pizza", "description": "Pepperoni pizza with cheese"}');

        // Create a custom document for high confidence match
        final Map<String, dynamic> docData = {
          'title': 'Pepperoni Pizza',
          'cleaned_ingredients': 'Dough, Tomato Sauce, Cheese, Pepperoni',
          'image_url': 'http://example.com/pizza.jpg',
        };
        final customDoc =
            CustomMockDocumentSnapshot<Map<String, dynamic>>('pizza1', docData);
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([customDoc]);

        // Setup query chain
        when(mockQuery.startAt(any)).thenReturn(mockQuery);
        when(mockQuery.endAt(any)).thenReturn(mockQuery);
        when(mockQuery.limit(any)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup accurate model response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Pepperoni Pizza",
          "ingredients": [
            {"name": "Dough", "servings": 120},
            {"name": "Tomato Sauce", "servings": 50},
            {"name": "Cheese", "servings": 80},
            {"name": "Pepperoni", "servings": 30}
          ],
          "nutrition_info": {
            "calories": 350,
            "protein": 15,
            "carbs": 40,
            "fat": 14,
            "sodium": 700,
            "fiber": 2,
            "sugar": 3
          },
          "warnings": ["High sodium content"]
        }
        ''');

        // Execute the analyze method
        final result = await service.analyze(mockFile);

        // Verify the result
        expect(result.foodName, 'Pepperoni Pizza');
        expect(result.ingredients.length, 4);
        expect(result.nutritionInfo.calories, 350);
        expect(result.warnings, contains('High sodium content'));
        expect(result.isLowConfidence, false);

        // Verify interactions
        expect(mockModelWrapper.wasCalled, true);
        expect(mockAccurateModelWrapper.wasCalled, true);
        verify(mockFirestore.collection('fooddataset')).called(1);
      });

      test('should analyze with low confidence when no similar foods found',
          () async {
        // Setup test data
        mockModelWrapper.setResponse(
            '{"food_name": "Exotic Dish", "description": "Unknown food"}');

        // Set up empty query results
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([]);

        // Setup query chain
        when(mockQuery.startAt(any)).thenReturn(mockQuery);
        when(mockQuery.endAt(any)).thenReturn(mockQuery);
        when(mockQuery.limit(any)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup accurate model response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Exotic Rice Dish",
          "ingredients": [
            {"name": "Rice", "servings": 150},
            {"name": "Vegetables", "servings": 100},
            {"name": "Sauce", "servings": 30}
          ],
          "nutrition_info": {
            "calories": 300,
            "protein": 5,
            "carbs": 50,
            "fat": 8,
            "sodium": 400,
            "fiber": 3,
            "sugar": 2
          },
          "warnings": []
        }
        ''');

        // Execute the analyze method
        final result = await service.analyze(mockFile);

        // Verify the result
        expect(result.foodName, 'Exotic Rice Dish');
        expect(result.ingredients.length, 3);
        expect(result.isLowConfidence, true);
        expect(
            result.warnings, contains(FoodAnalysisResult.lowConfidenceWarning));

        // Verify interactions
        expect(mockModelWrapper.wasCalled, true);
        expect(mockAccurateModelWrapper.wasCalled, true);
      });

      test(
          'should analyze with low confidence when similar foods have low score',
          () async {
        // Setup test data
        mockModelWrapper.setResponse(
            '{"food_name": "Mystery Dish", "description": "Food on a plate"}');

        // Prepare custom document with low score potential
        final Map<String, dynamic> docData = {
          'title': 'Some Food',
          'cleaned_ingredients': 'Ingredients',
          'image_url': '',
        };
        final customDoc = CustomMockDocumentSnapshot<Map<String, dynamic>>(
            'lowscore', docData);
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([customDoc]);

        // Setup query chain
        when(mockQuery.startAt(any)).thenReturn(mockQuery);
        when(mockQuery.endAt(any)).thenReturn(mockQuery);
        when(mockQuery.limit(any)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup accurate model response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Mixed Plate",
          "ingredients": [
            {"name": "Various Foods", "servings": 200}
          ],
          "nutrition_info": {
            "calories": 450,
            "protein": 20,
            "carbs": 55,
            "fat": 15,
            "sodium": 600,
            "fiber": 4,
            "sugar": 8
          },
          "warnings": ["High sodium content"]
        }
        ''');

        // Execute the analyze method
        final result = await service.analyze(mockFile);

        // Verify the result
        expect(result.foodName, 'Mixed Plate');
        expect(result.isLowConfidence, true);
        expect(
            result.warnings, contains(FoodAnalysisResult.lowConfidenceWarning));
        expect(result.warnings, contains('High sodium content'));
      });

      test('should throw exception when API returns no text', () async {
        // Setup test data
        mockModelWrapper.setResponse(null);

        // Execute and verify exception
        expect(
            () => service.analyze(mockFile),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('No response text generated'))));
      });

      test('should handle malformed JSON in response', () async {
        // Setup test data
        mockModelWrapper.setResponse('Not valid JSON');

        // Execute and verify exception
        expect(() => service.analyze(mockFile),
            throwsA(isA<GeminiServiceException>()));
      });

      test('should handle error reading image file', () async {
        // Setup file read error dengan membuat MockFile baru yang melempar exception
        final errorMockFile = _ErrorMockFile(
          path: '/test/path/to/image.jpg',
          error: FileSystemException('Error reading file'),
        );

        // Execute and verify exception
        expect(
            () => service.analyze(errorMockFile),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('Error identifying food'))));
      });

      test('should handle "No food detected in image" response', () async {
        // Setup test data
        mockModelWrapper.setResponse(
            '{"food_name": "Unknown", "description": "Cannot identify any food"}');

        // Set up empty query results to trigger low confidence path
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([]);
        when(mockQuery.startAt(any)).thenReturn(mockQuery);
        when(mockQuery.endAt(any)).thenReturn(mockQuery);
        when(mockQuery.limit(any)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup accurate model response with "No food detected" (tanpa field error)
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Unknown",
          "ingredients": [],
          "nutrition_info": {
            "calories": 0,
            "protein": 0,
            "carbs": 0,
            "fat": 0,
            "sodium": 0,
            "fiber": 0,
            "sugar": 0
          },
          "warnings": ["No food detected in image"]
        }
        ''');

        // Execute the analyze method
        final result = await service.analyze(mockFile);

        // Verify the result
        expect(result.foodName, 'Unknown');
        expect(result.ingredients.isEmpty, true);
        expect(result.nutritionInfo.calories, 0);
        expect(result.isLowConfidence, true);
        expect(
            result.warnings, contains(FoodAnalysisResult.lowConfidenceWarning));
        expect(result.warnings, contains('No food detected in image'));
      });

      test('should handle error in _analyzeWithReferences', () async {
        // Setup test data for initial identification
        mockModelWrapper.setResponse(
            '{"food_name": "Pizza", "description": "Pepperoni pizza with cheese"}');

        // Create a custom document for high confidence match
        final Map<String, dynamic> docData = {
          'title': 'Pepperoni Pizza',
          'cleaned_ingredients': 'Dough, Tomato Sauce, Cheese, Pepperoni',
          'image_url': 'http://example.com/pizza.jpg',
        };
        final customDoc =
            CustomMockDocumentSnapshot<Map<String, dynamic>>('pizza1', docData);
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([customDoc]);

        // Setup query chain for high confidence path
        when(mockQuery.startAt(any)).thenReturn(mockQuery);
        when(mockQuery.endAt(any)).thenReturn(mockQuery);
        when(mockQuery.limit(any)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup error in accurate model
        mockAccurateModelWrapper.setException(
            GeminiServiceException('Error in reference analysis'));

        // Execute and verify exception
        expect(
            () => service.analyze(mockFile),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('Error in reference analysis'))));
      });

      test('should handle error in _findSimilarFoods', () async {
        // Setup test data for initial identification
        mockModelWrapper.setResponse(
            '{"food_name": "Pizza", "description": "Pepperoni pizza with cheese"}');

        // Setup Firestore error
        when(mockQuery.startAt(any)).thenReturn(mockQuery);
        when(mockQuery.endAt(any)).thenReturn(mockQuery);
        when(mockQuery.limit(any)).thenReturn(mockQuery);
        when(mockQuery.get()).thenThrow(
            FirebaseException(plugin: 'firestore', message: 'Firestore error'));

        // Execute and verify exception
        expect(
            () => service.analyze(mockFile),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('Error finding similar foods'))));
      });
    });

    group('correctAnalysis', () {
      test('should correctly update food analysis based on user feedback',
          () async {
        // Create original result with http URL instead of file path
        final originalResult = FoodAnalysisResult(
          foodName: 'Hamburger',
          ingredients: [
            Ingredient(name: 'Beef Patty', servings: 120),
            Ingredient(name: 'Bun', servings: 60),
            Ingredient(name: 'Lettuce', servings: 20),
            Ingredient(name: 'Tomato', servings: 30),
          ],
          nutritionInfo: NutritionInfo(
            calories: 450,
            protein: 25,
            carbs: 40,
            fat: 20,
            sodium: 800,
            fiber: 3,
            sugar: 5,
          ),
          warnings: ['High sodium content'],
          isLowConfidence: false,
          foodImageUrl: 'http://example.com/burger.jpg',
        );

        // Setup correction response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Cheeseburger",
          "ingredients": [
            {"name": "Beef Patty", "servings": 120},
            {"name": "Cheese", "servings": 30},
            {"name": "Bun", "servings": 60},
            {"name": "Lettuce", "servings": 20},
            {"name": "Tomato", "servings": 30}
          ],
          "nutrition_info": {
            "calories": 550,
            "protein": 28,
            "carbs": 40,
            "fat": 30,
            "sodium": 950,
            "fiber": 3,
            "sugar": 6
          },
          "warnings": ["High sodium content"]
        }
        ''');

        // Execute correction
        final correctedResult = await service.correctAnalysis(originalResult,
            "It's actually a cheeseburger, you missed the cheese!");

        // Verify the corrected result
        expect(correctedResult.foodName, 'Cheeseburger');
        expect(correctedResult.ingredients.length, 5);
        expect(
            correctedResult.ingredients.any((i) => i.name == 'Cheese'), isTrue);
        expect(correctedResult.nutritionInfo.calories, 550);
        expect(correctedResult.foodImageUrl, originalResult.foodImageUrl);
        expect(correctedResult.isLowConfidence, originalResult.isLowConfidence);

        // Verify interactions
        expect(mockAccurateModelWrapper.wasCalled, true);
      });

      test('should preserve low confidence flag on corrections', () async {
        // Create low confidence original result with http URL
        final originalResult = FoodAnalysisResult(
          foodName: 'Unknown Food',
          ingredients: [
            Ingredient(name: 'Various Ingredients', servings: 100),
          ],
          nutritionInfo: NutritionInfo(
            calories: 300,
            protein: 10,
            carbs: 30,
            fat: 15,
            sodium: 400,
            fiber: 2,
            sugar: 5,
          ),
          warnings: [FoodAnalysisResult.lowConfidenceWarning],
          isLowConfidence: true,
          foodImageUrl: 'http://example.com/unknown-food.jpg',
        );

        // Setup correction response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Chicken Salad",
          "ingredients": [
            {"name": "Chicken", "servings": 100},
            {"name": "Lettuce", "servings": 50},
            {"name": "Tomato", "servings": 30}
          ],
          "nutrition_info": {
            "calories": 250,
            "protein": 30,
            "carbs": 10,
            "fat": 12,
            "sodium": 300,
            "fiber": 4,
            "sugar": 3
          },
          "warnings": []
        }
        ''');

        // Execute correction
        final correctedResult = await service.correctAnalysis(
            originalResult, "It's a chicken salad");

        // Verify the result maintains low confidence
        expect(correctedResult.foodName, 'Chicken Salad');
        expect(correctedResult.isLowConfidence, true);
        expect(correctedResult.warnings,
            contains(FoodAnalysisResult.lowConfidenceWarning));
        expect(correctedResult.foodImageUrl, originalResult.foodImageUrl);
      });

      test('should handle error in correction', () async {
        // Create original result
        final originalResult = FoodAnalysisResult(
          foodName: 'Pasta',
          ingredients: [
            Ingredient(name: 'Pasta', servings: 120),
            Ingredient(name: 'Tomato Sauce', servings: 100),
          ],
          nutritionInfo: NutritionInfo(
            calories: 350,
            protein: 12,
            carbs: 70,
            fat: 5,
            sodium: 400,
            fiber: 4,
            sugar: 6,
          ),
          warnings: [],
          isLowConfidence: false,
        );

        // Setup generation error
        mockAccurateModelWrapper.setException(Exception('API error'));

        // Execute and verify exception
        expect(
            () => service.correctAnalysis(originalResult, "Add meatballs"),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('Error correcting food analysis'))));
      });

      test('should handle web image URLs in correction', () async {
        // Create original result with web URL
        final originalResult = FoodAnalysisResult(
          foodName: 'Sushi',
          ingredients: [
            Ingredient(name: 'Rice', servings: 100),
            Ingredient(name: 'Fish', servings: 50),
            Ingredient(name: 'Seaweed', servings: 10),
          ],
          nutritionInfo: NutritionInfo(
            calories: 300,
            protein: 20,
            carbs: 40,
            fat: 5,
            sodium: 300,
            fiber: 1,
            sugar: 2,
          ),
          warnings: [],
          isLowConfidence: false,
          foodImageUrl: 'http://example.com/sushi.jpg',
        );

        // Setup correction response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Sushi Roll",
          "ingredients": [
            {"name": "Rice", "servings": 100},
            {"name": "Fish", "servings": 50},
            {"name": "Seaweed", "servings": 10},
            {"name": "Avocado", "servings": 30}
          ],
          "nutrition_info": {
            "calories": 340,
            "protein": 20,
            "carbs": 40,
            "fat": 10,
            "sodium": 300,
            "fiber": 3,
            "sugar": 2
          },
          "warnings": []
        }
        ''');

        // Execute correction
        final correctedResult = await service.correctAnalysis(
            originalResult, "Add avocado to the ingredients");

        // Verify the result
        expect(correctedResult.foodName, 'Sushi Roll');
        expect(correctedResult.ingredients.length, 4);
        expect(correctedResult.ingredients.any((i) => i.name == 'Avocado'),
            isTrue);
        expect(correctedResult.foodImageUrl, originalResult.foodImageUrl);
      });

      test('should handle null foodImageUrl in correction', () async {
        // Create original result with null foodImageUrl
        final originalResult = FoodAnalysisResult(
          foodName: 'Pasta',
          ingredients: [
            Ingredient(name: 'Pasta', servings: 120),
            Ingredient(name: 'Tomato Sauce', servings: 100),
          ],
          nutritionInfo: NutritionInfo(
            calories: 350,
            protein: 12,
            carbs: 70,
            fat: 5,
            sodium: 400,
            fiber: 4,
            sugar: 6,
          ),
          warnings: [],
          isLowConfidence: false,
          foodImageUrl: null, // Null foodImageUrl
        );

        // Setup correction response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Pasta with Meatballs",
          "ingredients": [
            {"name": "Pasta", "servings": 120},
            {"name": "Tomato Sauce", "servings": 100},
            {"name": "Meatballs", "servings": 80}
          ],
          "nutrition_info": {
            "calories": 450,
            "protein": 25,
            "carbs": 70,
            "fat": 12,
            "sodium": 500,
            "fiber": 4,
            "sugar": 6
          },
          "warnings": ["High sodium content"]
        }
        ''');

        // Execute correction
        final correctedResult = await service.correctAnalysis(
            originalResult, "Add meatballs to the pasta");

        // Verify the result
        expect(correctedResult.foodName, 'Pasta with Meatballs');
        expect(correctedResult.ingredients.length, 3);
        expect(correctedResult.ingredients.any((i) => i.name == 'Meatballs'),
            isTrue);
        expect(correctedResult.nutritionInfo.calories, 450);
        expect(correctedResult.foodImageUrl, null);
        expect(correctedResult.warnings, contains('High sodium content'));
      });
    });
  });
}