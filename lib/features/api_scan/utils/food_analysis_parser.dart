import 'dart:convert';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodAnalysisParser {
  static FoodAnalysisResult parse(String jsonText) {
    try {
      final jsonData = jsonDecode(jsonText);
      return parseMap(jsonData);
    } catch (e) {
      throw ApiServiceException("Failed to parse food analysis response: $e");
    }
  }

  static FoodAnalysisResult parseMap(Map<String, dynamic> jsonData) {
    try {
      print("Debug: Processing food analysis response");
      print("Debug: Error field value: ${jsonData['error']}");
      print("Debug: Food name: ${jsonData['food_name']}");

      // Check for error field in different formats
      if (jsonData.containsKey('error') && jsonData['error'] != null) {
        print("Debug: Error field is not null, throwing exception");
        String errorMessage = jsonData['error'] is String
            ? jsonData['error']
            : jsonData['error'] is Map
                ? (jsonData['error']['message'] ?? 'Unknown error')
                : 'Unknown error';
        throw ApiServiceException(errorMessage);
      }
      print("Debug: Passed error check");

      // If food_name is "Unknown" and we have nutrition values all at zero,
      // it might be an error case not explicitly marked with an error field
      if (jsonData['food_name'] == 'Unknown' &&
          jsonData.containsKey('nutrition_info') &&
          _isEmptyNutrition(jsonData['nutrition_info'])) {
        print("Debug: Unknown food with empty nutrition, throwing exception");
        throw ApiServiceException(
            "Cannot identify food from provided information");
      }
      print("Debug: Passed unknown food check");

      // If we get here, proceed with normal parsing
      print("Debug: Creating FoodAnalysisResult");
      final foodName = jsonData['food_name'] ?? '';
      final ingredients = _parseIngredients(jsonData['ingredients']);
      final nutritionInfo =
          NutritionInfo.fromJson(jsonData['nutrition_info'] ?? {});
      final warnings = jsonData['warnings'] ?? [];

      // Proses timestamp
      DateTime parsedTimestamp;
      if (jsonData['timestamp'] != null) {
        if (jsonData['timestamp'] is Timestamp) {
          parsedTimestamp = (jsonData['timestamp'] as Timestamp).toDate();
        } else if (jsonData['timestamp'] is int) {
          parsedTimestamp =
              DateTime.fromMillisecondsSinceEpoch(jsonData['timestamp'] as int);
        } else if (jsonData['timestamp'] is String) {
          try {
            parsedTimestamp = DateTime.parse(jsonData['timestamp'] as String);
          } catch (e) {
            parsedTimestamp = DateTime.now();
          }
        } else {
          parsedTimestamp = DateTime.now();
        }
      } else {
        parsedTimestamp = DateTime.now();
      }

      print("Debug: All fields validated successfully");

      var result = FoodAnalysisResult(
        foodName: foodName,
        ingredients: ingredients,
        nutritionInfo: nutritionInfo,
        warnings: warnings is List ? List<String>.from(warnings) : <String>[],
        timestamp: parsedTimestamp,
        isLowConfidence: jsonData['is_low_confidence'] ?? false,
      );
      print("Debug: Successfully created FoodAnalysisResult");
      return result;
    } catch (e) {
      print("Debug: Caught exception in parseMap: $e");
      if (e is ApiServiceException) {
        rethrow;
      }
      throw ApiServiceException("Failed to parse food analysis data: $e");
    }
  }

  // Helper method to check if nutrition info is empty/zeros
  static bool _isEmptyNutrition(Map<String, dynamic> nutritionInfo) {
    final values = [
      nutritionInfo['calories'],
      nutritionInfo['protein'],
      nutritionInfo['carbs'],
      nutritionInfo['fat'],
      nutritionInfo['sodium'],
      nutritionInfo['fiber'],
      nutritionInfo['sugar'],
    ];

    // Check if all values are null, 0, or "0"
    return values.every((value) =>
        value == null ||
        value == 0 ||
        value == 0.0 ||
        value == "0" ||
        value == "0.0");
  }

  static List<Ingredient> _parseIngredients(dynamic ingredients) {
    if (ingredients == null) return [];

    if (ingredients is List) {
      return ingredients
          .map((item) => item is Map<String, dynamic>
              ? Ingredient(
                  name: item['name'] ?? 'Unknown ingredient',
                  servings: _parseDouble(item['servings'] ?? 0),
                )
              : Ingredient(name: 'Unknown ingredient', servings: 0))
          .toList();
    }

    return [];
  }

  // Helper method to parse doubles from various formats
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
