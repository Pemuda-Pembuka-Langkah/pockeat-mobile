import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/generative_model_wrapper.dart';

class GeminiServiceImpl implements GeminiService {
  final String apiKey;
  final GenerativeModelWrapper _modelWrapper;
  
  GeminiServiceImpl({
    required this.apiKey,
    GenerativeModelWrapper? modelWrapper
  }) : _modelWrapper = modelWrapper ?? RealGenerativeModelWrapper(GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
      ));

    factory GeminiServiceImpl.fromEnv() {
    final apiKey = dotenv.env['GOOGLE_GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GOOGLE_GEMINI_API_KEY not found in environment variables');
    }
    return GeminiServiceImpl(apiKey: apiKey);
  }
  
  @override
  Future<FoodAnalysisResult> analyzeFoodByText(String description) async {
    try {
      final prompt = '''
      Analyze this food description: "$description"
      
      Please analyze the ingredients and nutritional content based on this description.
      
      Provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with percentage composition and allergen status
      - Detailed nutrition information including calories, protein, carbs, fat, sodium, fiber, and sugar
      
      Return your response as a strict JSON object with this exact format:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "servings": number, # in grams
            "allergen": boolean
          }
        ],
        "nutrition_info": {
          "calories": number,
          "protein": number,
          "carbs": number,
          "fat": number,
          "sodium": number,
          "fiber": number,
          "sugar": number
        }
      }
      
      If you cannot identify the food or analyze it properly, use this format:
      {
        "error": "Description of the issue",
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
        }
      }
      ''';
      
      final response = await _modelWrapper.generateContent([Content.text(prompt)]);
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }
      
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
      throw GeminiServiceException("Error analyzing food: $e");
    }
  }
  
  @override
  Future<FoodAnalysisResult> analyzeFoodByImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      
      final prompt = '''
      Analyze this food image.
      
      Please identify what food this is and provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with percentage composition and allergen status
      - Detailed nutrition information including calories, protein, carbs, fat, sodium, fiber, and sugar
      
      Return your response as a strict JSON object with this exact format:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "percentage": number,
            "allergen": boolean
          }
        ],
        "nutrition_info": {
          "calories": number,
          "protein": number,
          "carbs": number,
          "fat": number,
          "sodium": number,
          "fiber": number,
          "sugar": number
        }
      }
      
      If no food is detected in the image or you cannot analyze it properly, use this format:
      {
        "error": "No food detected in image",
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
        }
      }
      ''';
      
      final response = await _modelWrapper.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes)
        ])
      ]);
      
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }
      
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
      throw GeminiServiceException("Error analyzing food image: $e");
    }
  }
  
  @override
  Future<FoodAnalysisResult> analyzeNutritionLabel(File imageFile, double servings) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      
      final prompt = '''
      Analyze this nutrition label image. The user will consume $servings servings.
      
      Please provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with percentage composition and allergen status
      - Detailed nutrition information including calories, protein, carbs, fat, sodium, fiber, and sugar
      
      Return your response as a strict JSON object with this exact format:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "percentage": number,
            "allergen": boolean
          }
        ],
        "nutrition_info": {
          "calories": number,
          "protein": number,
          "carbs": number,
          "fat": number,
          "sodium": number,
          "fiber": number,
          "sugar": number
        }
      }
      
      If no nutrition label is detected in the image or you cannot analyze it properly, use this format:
      {
        "error": "No nutrition label detected",
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
        }
      }
      ''';
      
      final response = await _modelWrapper.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes)
        ])
      ]);
      
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }
      
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
      throw GeminiServiceException("Error analyzing nutrition label: $e");
    }
  }
  
  @override
  Future<ExerciseAnalysisResult> analyzeExercise(String description, {double? userWeightKg}) async {
    try {
      final weightInfo = userWeightKg != null ? "The user weighs $userWeightKg kg." : "";
      
      final prompt = '''
      Calculate calories burned from this exercise description: "$description"
      $weightInfo
      
      Please analyze this exercise and provide:
      - Type of exercise
      - Calories burned
      - Duration in minutes
      - Intensity level
      - MET value
      
      Return your response as a strict JSON object with this exact format:
      {
        "exercise_type": "string",
        "calories_burned": number,
        "duration_minutes": number,
        "intensity_level": "string",
        "met_value": number
      }
      
      If you cannot determine the exercise details, use this format:
      {
        "error": "Could not determine exercise details",
        "exercise_type": "Unknown",
        "calories_burned": 0,
        "duration_minutes": 0,
        "intensity_level": "Unknown",
        "met_value": 0
      }
      ''';
      
      final response = await _modelWrapper.generateContent([Content.text(prompt)]);
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }
      
      return _parseExerciseResponse(response.text!, description);
    } catch (e) {
      throw GeminiServiceException("Error analyzing exercise: $e");
    }
  }
  
  FoodAnalysisResult _parseFoodAnalysisResponse(String responseText) {
    try {
      // Extract JSON from response text
      final jsonString = _extractJson(responseText);
      final jsonData = jsonDecode(jsonString);
      
      // Check for error field
      if (jsonData.containsKey('error') && jsonData['error'] is String) {
        // Error message in string format
        throw GeminiServiceException(jsonData['error']);
      } else if (jsonData.containsKey('error') && jsonData['error'] is Map) {
        // Error in object format
        throw GeminiServiceException(jsonData['error']['message'] ?? 'Unknown error');
      }
      
      // Parse food analysis result
      return FoodAnalysisResult.fromJson(jsonData);
    } catch (e) {
      throw GeminiServiceException("Failed to parse food analysis response: $e");
    }
  }
  
  ExerciseAnalysisResult _parseExerciseResponse(String responseText, String originalInput) {
    try {
      // Extract JSON from response text
      final jsonString = _extractJson(responseText);
      final jsonData = jsonDecode(jsonString);
      
      // Check for error 
      if (jsonData.containsKey('error')) {
        // We have an error but we'll still create a result with default values
        return ExerciseAnalysisResult(
          exerciseType: 'Unknown',
          duration: 'Not specified',
          intensity: 'Not specified',
          estimatedCalories: 0,
          metValue: 0.0,
          summary: 'Could not analyze exercise: ${jsonData['error']}',
          timestamp: DateTime.now(),
          originalInput: originalInput,
          missingInfo: ['exercise_type', 'duration', 'intensity'],
        );
      }
      
      // Map from API response format to app model format
      final exerciseType = jsonData['exercise_type'] ?? 'Unknown';
      final caloriesBurned = jsonData['calories_burned'] ?? 0;
      final durationMinutes = jsonData['duration_minutes'] ?? 0;
      final intensityLevel = jsonData['intensity_level'] ?? 'Unknown';
      final metValue = (jsonData['met_value'] ?? 0.0).toDouble();
      
      // Create a summary
      final summary = 'You performed $exerciseType for $durationMinutes minutes at $intensityLevel intensity, burning approximately $caloriesBurned calories.';
      
      // Determine duration string format
      final duration = '$durationMinutes minutes';
      
      // Create the exercise analysis result in the app's model format
      return ExerciseAnalysisResult(
        exerciseType: exerciseType,
        duration: duration,
        intensity: intensityLevel,
        estimatedCalories: caloriesBurned is int ? caloriesBurned : caloriesBurned.toInt(),
        metValue: metValue,
        summary: summary,
        timestamp: DateTime.now(),
        originalInput: originalInput,
      );
    } catch (e) {
      throw GeminiServiceException("Failed to parse exercise analysis response: $e");
    }
  }
  
  String _extractJson(String text) {
    try {
      // Try parsing the text directly first
      jsonDecode(text);
      return text;
    } catch (_) {
      // If direct parsing fails, try to extract JSON from the text
      final startIndex = text.indexOf('{');
      final endIndex = text.lastIndexOf('}');
      
      if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex) {
        final jsonString = text.substring(startIndex, endIndex + 1);
        // Validate that it's parseable
        jsonDecode(jsonString);
        return jsonString;
      }
      
      throw GeminiServiceException('No valid JSON found in response');
    }
  }
}