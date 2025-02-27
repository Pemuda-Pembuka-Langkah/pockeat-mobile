// lib/pockeat/features/ai_api_scan/services/gemini_service_impl.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/models/exercise_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

class GeminiServiceImpl implements GeminiService {
  final http.Client client;
  final String apiKey;
  
  GeminiServiceImpl({required this.client, required this.apiKey});
  
  @override
  Future<FoodAnalysisResult> analyzeFoodByText(String description) {
    // Not implemented yet - will fail tests
    throw UnimplementedError();
  }
  
  @override
  Future<FoodAnalysisResult> analyzeFoodByImage(File imageFile) {
    // Not implemented yet - will fail tests
    throw UnimplementedError();
  }
  
  @override
  Future<FoodAnalysisResult> analyzeNutritionLabel(File imageFile, double servings) {
    // Not implemented yet - will fail tests
    throw UnimplementedError();
  }
  
  @override
  Future<ExerciseAnalysisResult> analyzeExercise(String description, {double? userWeightKg}) {
    // Not implemented yet - will fail tests
    throw UnimplementedError();
  }
}

class GeminiServiceException implements Exception {
  final String message;
  
  GeminiServiceException(this.message);
  
  @override
  String toString() => 'GeminiServiceException: $message';
}
