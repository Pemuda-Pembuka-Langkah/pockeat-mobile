// test/features/ai_api_scan/services/food/food_text_analysis_service_test.dart

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
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
import 'food_text_analysis_service_test.mocks.dart';

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

// Subclass FoodTextAnalysisService to mock _downloadImageBytes method
class TestFoodTextAnalysisService extends FoodTextAnalysisService {
  TestFoodTextAnalysisService({
    required super.apiKey,
    required super.firestore,
    required super.customModelWrapper,
    required super.accurateModelWrapper,
  });

  @override
  Future<Uint8List?> _downloadImageBytes(String imageUrl) async {
    // Always return null for tests
    return null;
  }
}

void main() {
  late FoodTextAnalysisService service;
  late MockFirebaseFirestore mockFirestore;
  late MockGenerativeModelWrapper mockModelWrapper;
  late MockGenerativeModelWrapper mockAccurateModelWrapper;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;

  const String testApiKey = 'test-api-key';
  const String testFoodDescription = 'Chicken pasta with tomato sauce';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockModelWrapper = MockGenerativeModelWrapper();
    mockAccurateModelWrapper = MockGenerativeModelWrapper();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();

    // Setup Firestore mocks
    when(mockFirestore.collection('fooddataset')).thenReturn(mockCollection);
    when(mockCollection.orderBy('title')).thenReturn(mockQuery);
    when(mockQuery.startAt(any)).thenReturn(mockQuery);
    when(mockQuery.endAt(any)).thenReturn(mockQuery);
    when(mockQuery.limit(any)).thenReturn(mockQuery);

    service = TestFoodTextAnalysisService(
      apiKey: testApiKey,
      firestore: mockFirestore,
      customModelWrapper: mockModelWrapper,
      accurateModelWrapper: mockAccurateModelWrapper,
    );
  });

  group('FoodTextAnalysisService', () {
    group('analyze', () {
      test('should successfully analyze food text with similar foods found',
          () async {
        // Setup test data
        mockModelWrapper.setResponse(
            '{"food_name": "Pasta", "description": "Chicken pasta with tomato sauce"}');

        // Create a custom document for high confidence match
        final Map<String, dynamic> docData = {
          'title': 'Chicken Pasta',
          'cleaned_ingredients': 'Pasta, Chicken, Tomato Sauce, Herbs',
          'image_url': 'http://example.com/pasta.jpg',
        };
        final customDoc =
            CustomMockDocumentSnapshot<Map<String, dynamic>>('pasta1', docData);
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([customDoc]);

        // Setup query response
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup accurate model response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Chicken Pasta with Tomato Sauce",
          "ingredients": [
            {"name": "Pasta", "servings": 120},
            {"name": "Chicken", "servings": 100},
            {"name": "Tomato Sauce", "servings": 80},
            {"name": "Herbs", "servings": 5}
          ],
          "nutrition_info": {
            "calories": 450,
            "protein": 30,
            "carbs": 60,
            "fat": 10,
            "sodium": 600,
            "fiber": 4,
            "sugar": 8
          },
          "warnings": ["High sodium content"]
        }
        ''');

        // Execute the analyze method
        final result = await service.analyze(testFoodDescription);

        // Verify the result
        expect(result.foodName, 'Chicken Pasta with Tomato Sauce');
        expect(result.ingredients.length, 4);
        expect(result.nutritionInfo.calories, 450);
        expect(result.warnings, contains('High sodium content'));
        expect(result.isLowConfidence, false);
        expect(result.foodImageUrl, 'http://example.com/pasta.jpg');

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

        // Setup query response
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup accurate model for direct analysis
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
        final result = await service.analyze('Some exotic dish with rice');

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
            '{"food_name": "Vague Dish", "description": "Food with ingredients"}');

        // Prepare custom document with potentially low score
        final Map<String, dynamic> docData = {
          'title': 'Some Food',
          'cleaned_ingredients': 'Various Ingredients',
          'image_url': '',
        };
        final customDoc = CustomMockDocumentSnapshot<Map<String, dynamic>>(
            'lowscore', docData);
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([customDoc]);

        // Setup query response
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup accurate model for direct analysis
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Generic Mixed Dish",
          "ingredients": [
            {"name": "Various Components", "servings": 250}
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
        final result = await service.analyze('Some vague food description');

        // Verify the result
        expect(result.foodName, 'Generic Mixed Dish');
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
            () => service.analyze(testFoodDescription),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('No response text generated'))));
      });

      test('should handle malformed JSON in response', () async {
        // Setup test data
        mockModelWrapper.setResponse('Not valid JSON');

        // Execute and verify exception
        expect(() => service.analyze(testFoodDescription),
            throwsA(isA<GeminiServiceException>()));
      });

      test('should handle error in _findSimilarFoods', () async {
        // Setup test data for initial identification
        mockModelWrapper.setResponse(
            '{"food_name": "Pizza", "description": "Cheese pizza"}');

        // Setup Firestore error
        when(mockQuery.get()).thenThrow(
            FirebaseException(plugin: 'firestore', message: 'Firestore error'));

        // Execute and verify exception
        expect(
            () => service.analyze(testFoodDescription),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('Error finding similar foods'))));
      });

      test('should handle error in _analyzeWithReferences', () async {
        // Setup test data for initial identification
        mockModelWrapper.setResponse(
            '{"food_name": "Pizza", "description": "Cheese pizza"}');

        // Create a custom document for high confidence match
        final Map<String, dynamic> docData = {
          'title': 'Cheese Pizza',
          'cleaned_ingredients': 'Dough, Tomato Sauce, Cheese',
          'image_url': 'http://example.com/pizza.jpg',
        };
        final customDoc =
            CustomMockDocumentSnapshot<Map<String, dynamic>>('pizza1', docData);
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([customDoc]);

        // Setup query response
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup error in accurate model
        mockAccurateModelWrapper.setException(
            GeminiServiceException('Error in reference analysis'));

        // Execute and verify exception
        expect(
            () => service.analyze(testFoodDescription),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('Error in reference analysis'))));
      });

      test('should handle "Unknown food" response', () async {
        // Setup test data for initial identification
        mockModelWrapper.setResponse(
            '{"food_name": "Unknown", "description": "Cannot identify this food"}');

        // Set up empty query results to trigger low confidence path
        final customQuerySnapshot =
            CustomMockQuerySnapshot<Map<String, dynamic>>([]);
        when(mockQuery.get()).thenAnswer((_) async => customQuerySnapshot);

        // Setup accurate model response WITHOUT the error field that would cause the parser to throw
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
          "warnings": ["No identifiable food in description"]
        }
        ''');

        // Execute the analyze method
        final result = await service.analyze('incomprehensible food description');

        // Verify the result
        expect(result.foodName, 'Unknown');
        expect(result.ingredients.isEmpty, true);
        expect(result.nutritionInfo.calories, 0);
        expect(result.isLowConfidence, true);
        expect(
            result.warnings, contains(FoodAnalysisResult.lowConfidenceWarning));
      });
    });

    group('correctAnalysis', () {
      test('should correctly update food analysis based on user feedback',
          () async {
        // Create original result with image URL
        final originalResult = FoodAnalysisResult(
          foodName: 'Pasta',
          ingredients: [
            Ingredient(name: 'Pasta', servings: 120),
            Ingredient(name: 'Tomato Sauce', servings: 80),
          ],
          nutritionInfo: NutritionInfo(
            calories: 350,
            protein: 10,
            carbs: 60,
            fat: 5,
            sodium: 400,
            fiber: 3,
            sugar: 6,
          ),
          warnings: [],
          isLowConfidence: false,
          foodImageUrl: 'http://example.com/pasta.jpg',
        );

        // Setup correction response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Chicken Pasta",
          "ingredients": [
            {"name": "Pasta", "servings": 120},
            {"name": "Chicken", "servings": 100},
            {"name": "Tomato Sauce", "servings": 80}
          ],
          "nutrition_info": {
            "calories": 450,
            "protein": 25,
            "carbs": 60,
            "fat": 10,
            "sodium": 450,
            "fiber": 3,
            "sugar": 6
          },
          "warnings": []
        }
        ''');

        // Execute correction
        final correctedResult = await service.correctAnalysis(originalResult,
            "It actually has chicken in it too");

        // Verify the corrected result
        expect(correctedResult.foodName, 'Chicken Pasta');
        expect(correctedResult.ingredients.length, 3);
        expect(correctedResult.ingredients.any((i) => i.name == 'Chicken'), isTrue);
        expect(correctedResult.nutritionInfo.calories, 450);
        expect(correctedResult.foodImageUrl, originalResult.foodImageUrl);
        expect(correctedResult.isLowConfidence, originalResult.isLowConfidence);

        // Verify interactions
        expect(mockAccurateModelWrapper.wasCalled, true);
      });

      test('should preserve low confidence flag on corrections', () async {
        // Create low confidence original result
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
          foodImageUrl: null,
        );

        // Setup correction response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Vegetable Stir Fry",
          "ingredients": [
            {"name": "Mixed Vegetables", "servings": 200},
            {"name": "Rice", "servings": 150},
            {"name": "Sauce", "servings": 30}
          ],
          "nutrition_info": {
            "calories": 350,
            "protein": 8,
            "carbs": 60,
            "fat": 10,
            "sodium": 500,
            "fiber": 6,
            "sugar": 8
          },
          "warnings": ["High sodium content"]
        }
        ''');

        // Execute correction
        final correctedResult = await service.correctAnalysis(
            originalResult, "It's a vegetable stir fry with rice");

        // Verify the result maintains low confidence
        expect(correctedResult.foodName, 'Vegetable Stir Fry');
        expect(correctedResult.isLowConfidence, true);
        expect(correctedResult.warnings,
            contains(FoodAnalysisResult.lowConfidenceWarning));
        expect(correctedResult.warnings, contains('High sodium content'));
        expect(correctedResult.foodImageUrl, null);
      });

      test('should handle error in correction', () async {
        // Create original result
        final originalResult = FoodAnalysisResult(
          foodName: 'Salad',
          ingredients: [
            Ingredient(name: 'Lettuce', servings: 100),
            Ingredient(name: 'Tomato', servings: 50),
            Ingredient(name: 'Cucumber', servings: 50),
          ],
          nutritionInfo: NutritionInfo(
            calories: 100,
            protein: 3,
            carbs: 15,
            fat: 2,
            sodium: 150,
            fiber: 5,
            sugar: 8,
          ),
          warnings: [],
          isLowConfidence: false,
        );

        // Setup generation error
        mockAccurateModelWrapper.setException(Exception('API error'));

        // Execute and verify exception
        expect(
            () => service.correctAnalysis(originalResult, "Add chicken to the salad"),
            throwsA(isA<GeminiServiceException>().having((e) => e.message,
                'message', contains('Error correcting food analysis'))));
      });

      test('should handle null foodImageUrl in correction', () async {
        // Create original result with null foodImageUrl
        final originalResult = FoodAnalysisResult(
          foodName: 'Smoothie',
          ingredients: [
            Ingredient(name: 'Banana', servings: 120),
            Ingredient(name: 'Milk', servings: 200),
            Ingredient(name: 'Honey', servings: 15),
          ],
          nutritionInfo: NutritionInfo(
            calories: 220,
            protein: 5,
            carbs: 40,
            fat: 4,
            sodium: 80,
            fiber: 3,
            sugar: 25,
          ),
          warnings: ['High sugar content'],
          isLowConfidence: false,
          foodImageUrl: null,
        );

        // Setup correction response
        mockAccurateModelWrapper.setResponse('''
        {
          "food_name": "Banana Strawberry Smoothie",
          "ingredients": [
            {"name": "Banana", "servings": 120},
            {"name": "Strawberries", "servings": 80},
            {"name": "Milk", "servings": 200},
            {"name": "Honey", "servings": 15}
          ],
          "nutrition_info": {
            "calories": 240,
            "protein": 6,
            "carbs": 45,
            "fat": 4,
            "sodium": 80,
            "fiber": 5,
            "sugar": 30
          },
          "warnings": ["High sugar content"]
        }
        ''');

        // Execute correction
        final correctedResult = await service.correctAnalysis(
            originalResult, "Added strawberries to the smoothie");

        // Verify the result
        expect(correctedResult.foodName, 'Banana Strawberry Smoothie');
        expect(correctedResult.ingredients.length, 4);
        expect(correctedResult.ingredients.any((i) => i.name == 'Strawberries'),
            isTrue);
        expect(correctedResult.nutritionInfo.sugar, 30);
        expect(correctedResult.foodImageUrl, null);
        expect(correctedResult.warnings, contains('High sugar content'));
      });
    });
  });
}