// test/pockeat/features/ai_api_scan/services/test_gemini_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart' as gemini;
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';

/// A test implementation of GeminiService that returns predefined responses
/// instead of making real API calls.
class TestGeminiService implements gemini.GeminiService {
  // Mock responses for food text analysis
  final Map<String, String> _foodTextResponses = {};
  
  // Mock responses for food image analysis (using file path as key)
  final Map<String, String> _foodImageResponses = {};
  
  // Mock responses for nutrition label analysis (using file path as key)
  final Map<String, String> _nutritionLabelResponses = {};
  
  // Mock responses for exercise analysis
  final Map<String, String> _exerciseResponses = {};
  
  // Keep track of all method calls for verification
  final List<String> calls = [];
  
  // Set mock responses for testing
  void setFoodTextResponse(String description, String jsonResponse) {
    _foodTextResponses[description] = jsonResponse;
  }
  
  void setFoodImageResponse(String filePath, String jsonResponse) {
    _foodImageResponses[filePath] = jsonResponse;
  }
  
  void setNutritionLabelResponse(String filePath, double servings, String jsonResponse) {
    _nutritionLabelResponses['${filePath}_${servings}'] = jsonResponse;
  }
  
  void setExerciseResponse(String description, String jsonResponse) {
    _exerciseResponses[description] = jsonResponse;
  }
  
  void setExerciseResponseWithWeight(String description, double weight, String jsonResponse) {
    _exerciseResponses['${description}_w${weight}'] = jsonResponse;
  }
  
  @override
  Future<FoodAnalysisResult> analyzeFoodByText(String description) async {
    calls.add('analyzeFoodByText: $description');
    
    // Return predefined response or default if not found
    final response = _foodTextResponses[description] ?? 
        '{"food_name":"Test Food","ingredients":[],"nutrition_info":{"calories":100,"protein":1,"carbs":10,"fat":1,"sodium":10,"fiber":1,"sugar":5}}';
    
    try {
      return FoodAnalysisResult.fromJson(jsonDecode(response));
    } catch (e) {
      throw gemini.GeminiServiceException('Failed to parse response: $e');
    }
  }
  
  @override
  Future<FoodAnalysisResult> analyzeFoodByImage(File imageFile) async {
    final path = imageFile.path;
    calls.add('analyzeFoodByImage: $path');
    
    // Return predefined response or default if not found
    final response = _foodImageResponses[path] ?? 
        '{"food_name":"Test Image Food","ingredients":[],"nutrition_info":{"calories":200,"protein":10,"carbs":20,"fat":5,"sodium":30,"fiber":2,"sugar":10}}';
    
    try {
      return FoodAnalysisResult.fromJson(jsonDecode(response));
    } catch (e) {
      throw GeminiServiceException('Failed to parse response: $e');
    }
  }
  
  @override
  Future<FoodAnalysisResult> analyzeNutritionLabel(File imageFile, double servings) async {
    final path = imageFile.path;
    final key = '${path}_${servings}';
    calls.add('analyzeNutritionLabel: $key');
    
    // Return predefined response or default if not found
    final response = _nutritionLabelResponses[key] ?? 
        '{"food_name":"Test Nutrition Label","ingredients":[],"nutrition_info":{"calories":300,"protein":15,"carbs":30,"fat":10,"sodium":100,"fiber":3,"sugar":15}}';
    
    try {
      return FoodAnalysisResult.fromJson(jsonDecode(response));
    } catch (e) {
      throw GeminiServiceException('Failed to parse response: $e');
    }
  }
  
  @override
  Future<ExerciseAnalysisResult> analyzeExercise(String description, {double? userWeightKg}) async {
    // Create a key that includes weight if provided
    final key = userWeightKg != null ? '${description}_w${userWeightKg}' : description;
    calls.add('analyzeExercise: $key');
    
    // Return predefined response or default if not found
    final response = _exerciseResponses[key] ?? 
        '{"exercise_type":"Running","calories_burned":300,"duration_minutes":30,"intensity_level":"Moderate","met_value":7.0}';
    
    try {
      final jsonData = jsonDecode(response);
      
      return ExerciseAnalysisResult(
        exerciseType: jsonData['exercise_type'] ?? 'Unknown',
        duration: '${jsonData['duration_minutes'] ?? 0} minutes',
        intensity: jsonData['intensity_level'] ?? 'Not specified',
        estimatedCalories: (jsonData['calories_burned'] ?? 0) is int 
            ? (jsonData['calories_burned'] ?? 0) 
            : (jsonData['calories_burned'] ?? 0).toInt(),
        metValue: (jsonData['met_value'] ?? 0.0).toDouble(),
        summary: 'Test exercise analysis',
        timestamp: DateTime.now(),
        originalInput: description,
      );
    } catch (e) {
      throw GeminiServiceException('Failed to parse response: $e');
    }
  }
  
  // Simulate an error response
  void throwError(String method, String errorMessage) {
    if (method == 'analyzeFoodByText') {
      _foodTextResponses['_ERROR_'] = 'ERROR';
    } else if (method == 'analyzeFoodByImage') {
      _foodImageResponses['_ERROR_'] = 'ERROR';
    } else if (method == 'analyzeNutritionLabel') {
      _nutritionLabelResponses['_ERROR_'] = 'ERROR';
    } else if (method == 'analyzeExercise') {
      _exerciseResponses['_ERROR_'] = 'ERROR';
    }
    
    throw gemini.GeminiServiceException(errorMessage);
  }
}

