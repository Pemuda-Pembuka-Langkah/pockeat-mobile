// lib/features/ai_api_scan/utils/food_analysis_parser.dart
import 'dart:convert';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

class FoodAnalysisParser {
static FoodAnalysisResult parse(String jsonText) {
  try {
    // Handle empty input
    if (jsonText.trim().isEmpty) {
      throw FormatException("Empty input");
    }
    
    final dynamic jsonData = jsonDecode(jsonText);
    
    // Check if jsonData is a Map
    if (jsonData is! Map<String, dynamic>) {
      throw FormatException("Expected JSON object, got ${jsonData.runtimeType}");
    }

    // Check for error field
    if (jsonData.containsKey('error') && jsonData['error'] is String) {
      throw GeminiServiceException(jsonData['error']);
    } else if (jsonData.containsKey('error') && jsonData['error'] is Map) {
      throw GeminiServiceException(
          jsonData['error']['message'] ?? 'Unknown error');
    }

    // Handle ingredients safely
    if (jsonData.containsKey('ingredients') && jsonData['ingredients'] is List) {
      final List<dynamic> ingredients = jsonData['ingredients'] as List;
      final List<Map<String, dynamic>> validIngredients = [];
      
      for (final item in ingredients) {
        if (item is Map<String, dynamic>) {
          validIngredients.add(item);
        }
      }
      
      jsonData['ingredients'] = validIngredients;
    }

    // Check if there's a low confidence flag in warnings
    final hasLowConfidenceWarning = jsonData.containsKey('warnings') && 
        jsonData['warnings'] is List &&
        (jsonData['warnings'] as List).any((warning) => 
            warning.toString().contains('confidence is low'));
    
    // Set the low confidence flag based on explicit property or warning content
    if (!jsonData.containsKey('is_low_confidence') && hasLowConfidenceWarning) {
      jsonData['is_low_confidence'] = true;
    }

    return FoodAnalysisResult.fromJson(jsonData);
  } catch (e) {
    throw GeminiServiceException("Error parsing food analysis: $e");
  }
}
}