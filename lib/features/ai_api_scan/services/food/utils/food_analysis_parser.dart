// lib/features/ai_api_scan/utils/food_analysis_parser.dart
import 'dart:convert';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

class FoodAnalysisParser {
  static FoodAnalysisResult parse(String jsonText) {
    try {
      final jsonData = jsonDecode(jsonText);

      // Check for error field
      if (jsonData.containsKey('error') && jsonData['error'] is String) {
        throw GeminiServiceException(jsonData['error']);
      } else if (jsonData.containsKey('error') && jsonData['error'] is Map) {
        throw GeminiServiceException(
            jsonData['error']['message'] ?? 'Unknown error');
      }

      return FoodAnalysisResult.fromJson(jsonData);
    } catch (e) {
      throw GeminiServiceException(
          "Failed to parse food analysis response: $e");
    }
  }
}