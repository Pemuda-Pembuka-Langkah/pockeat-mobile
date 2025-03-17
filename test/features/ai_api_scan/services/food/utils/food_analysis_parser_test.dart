// test/features/ai_api_scan/services/food/food_analysis_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/food_analysis_parser.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

void main() {
  group('FoodAnalysisParser', () {
    test('parse should successfully parse valid JSON', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Apple Pie",
        "ingredients": [
          {
            "name": "Apples",
            "servings": 50
          },
          {
            "name": "Flour",
            "servings": 25
          }
        ],
        "nutrition_info": {
          "calories": 250,
          "protein": 2,
          "carbs": 40,
          "fat": 12,
          "sodium": 150,
          "fiber": 3,
          "sugar": 25
        },
        "warnings": ["High sugar content"]
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.foodName, equals('Apple Pie'));
      expect(result.ingredients.length, equals(2));
      expect(result.ingredients[0].name, equals('Apples'));
      expect(result.ingredients[0].servings, equals(50));
      expect(result.nutritionInfo.calories, equals(250));
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('High sugar content'));
    });

    test('parse should handle minimal valid JSON with default values', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Simple Food"
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.foodName, equals('Simple Food'));
      expect(result.ingredients, isEmpty);
      expect(result.nutritionInfo.calories, equals(0));
      expect(result.nutritionInfo.protein, equals(0));
      expect(result.nutritionInfo.carbs, equals(0));
      expect(result.nutritionInfo.fat, equals(0));
      expect(result.warnings, isEmpty);
    });

    test('parse should handle error as string correctly', () {
      // Arrange
      final jsonText = '{"error": "No food detected in image"}';

      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(jsonText),
        throwsA(isA<GeminiServiceException>().having((e) => e.message,
            'message', contains('No food detected in image'))),
      );
    });

    test('parse should handle error as Map correctly', () {
      // Arrange
      final jsonText = '{"error": {"message": "Custom error message"}}';

      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(jsonText),
        throwsA(isA<GeminiServiceException>().having(
            (e) => e.message, 'message', contains('Custom error message'))),
      );
    });

    test('parse should handle error as Map without message correctly', () {
      // Arrange
      final jsonText = '{"error": {}}'; // Empty error Map

      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(jsonText),
        throwsA(isA<GeminiServiceException>()
            .having((e) => e.message, 'message', contains('Unknown error'))),
      );
    });

    test('parse should handle invalid JSON format', () {
      // Arrange
      final jsonText = '{invalid json}';

      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(jsonText),
        throwsA(isA<GeminiServiceException>().having((e) => e.message,
            'message', contains('Error parsing food analysis'))),
      );
    });

    test('parse should handle null input', () {
      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(""),
        throwsA(isA<GeminiServiceException>().having((e) => e.message,
            'message', contains('Error parsing food analysis'))),
      );
    });

    test('parse should handle empty input', () {
      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(''),
        throwsA(isA<GeminiServiceException>().having((e) => e.message,
            'message', contains('Error parsing food analysis'))),
      );
    });

    test('parse should handle whitespace-only input', () {
      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse('  \n  \t  '),
        throwsA(isA<GeminiServiceException>().having((e) => e.message,
            'message', contains('Error parsing food analysis'))),
      );
    });

    test('parse should handle JSON array instead of object', () {
      // Arrange
      final jsonText = '[]';

      // Act & Assert
      expect(
        () => FoodAnalysisParser.parse(jsonText),
        throwsA(isA<GeminiServiceException>().having((e) => e.message,
            'message', contains('Error parsing food analysis'))),
      );
    });

    test('parse should handle complex nutrition values', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Complex Nutritional Food",
        "nutrition_info": {
          "calories": "250.75",
          "protein": 2.5,
          "carbs": "40.25",
          "fat": 12.75,
          "sodium": "150.5",
          "fiber": 3.5,
          "sugar": "25.25"
        }
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.nutritionInfo.calories, equals(250.75));
      expect(result.nutritionInfo.protein, equals(2.5));
      expect(result.nutritionInfo.carbs, equals(40.25));
      expect(result.nutritionInfo.fat, equals(12.75));
      expect(result.nutritionInfo.sodium, equals(150.5));
      expect(result.nutritionInfo.fiber, equals(3.5));
      expect(result.nutritionInfo.sugar, equals(25.25));
    });

    test('parse should handle nutrition values with invalid formats', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Invalid Nutritional Food",
        "nutrition_info": {
          "calories": "not a number",
          "protein": "invalid",
          "carbs": "N/A",
          "fat": "",
          "sodium": null,
          "fiber": {},
          "sugar": []
        }
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.nutritionInfo.calories, equals(0));
      expect(result.nutritionInfo.protein, equals(0));
      expect(result.nutritionInfo.carbs, equals(0));
      expect(result.nutritionInfo.fat, equals(0));
      expect(result.nutritionInfo.sodium, equals(0));
      expect(result.nutritionInfo.fiber, equals(0));
      expect(result.nutritionInfo.sugar, equals(0));
    });

    test('parse should handle ingredients with various formats', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Mixed Ingredients",
        "ingredients": [
          {"name": "Valid Ingredient", "servings": 50},
          {"name": "String Serving", "servings": "25.5"},
          {"name": "Invalid Serving", "servings": "not a number"},
          {"name": "Null Serving", "servings": null},
          {"name": "Object Serving", "servings": {}},
          {"name": "Array Serving", "servings": []},
          {"name": "", "servings": 0}
        ]
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.ingredients.length, equals(7));
      expect(result.ingredients[0].name, equals('Valid Ingredient'));
      expect(result.ingredients[0].servings, equals(50));
      expect(result.ingredients[1].name, equals('String Serving'));
      expect(result.ingredients[1].servings, equals(25.5));
      expect(result.ingredients[2].name, equals('Invalid Serving'));
      expect(result.ingredients[2].servings, equals(0));
      expect(result.ingredients[3].name, equals('Null Serving'));
      expect(result.ingredients[3].servings, equals(0));
      expect(result.ingredients[4].name, equals('Object Serving'));
      expect(result.ingredients[4].servings, equals(0));
      expect(result.ingredients[5].name, equals('Array Serving'));
      expect(result.ingredients[5].servings, equals(0));
      expect(result.ingredients[6].name, equals(''));
      expect(result.ingredients[6].servings, equals(0));
    });

    test('parse should handle invalid ingredients format', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Bad Ingredients",
        "ingredients": "not an array"
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.ingredients, isEmpty);
    });

    test('parse should handle object ingredients format', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Object Ingredients",
        "ingredients": {"key": "value"}
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.ingredients, isEmpty);
    });

    test('parse should handle ingredients with missing fields', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Missing Fields",
        "ingredients": [
          {"servings": 50},
          {"name": "Only Name"},
          {}
        ]
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.ingredients.length, equals(3));
      expect(result.ingredients[0].name, equals(''));
      expect(result.ingredients[0].servings, equals(50));
      expect(result.ingredients[1].name, equals('Only Name'));
      expect(result.ingredients[1].servings, equals(0));
      expect(result.ingredients[2].name, equals(''));
      expect(result.ingredients[2].servings, equals(0));
    });

    test('parse should handle ingredients with non-object items', () {
      // Arrange
      final jsonText = '''
      {
        "food_name": "Invalid Items",
        "ingredients": [
          {"name": "Valid", "servings": 50},
          "string item",
          123,
          null,
          [],
          true
        ]
      }
      ''';

      // Act
      final result = FoodAnalysisParser.parse(jsonText);

      // Assert
      expect(result.ingredients.length, equals(1));
      expect(result.ingredients[0].name, equals('Valid'));
      expect(result.ingredients[0].servings, equals(50));
    });
  });
}
