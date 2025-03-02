// lib/pockeat/features/ai_api_scan/services/gemini_service_impl.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';

class GeminiServiceImpl implements GeminiService {
  final GenerativeModel model;
  final String apiKey;
  
  GeminiServiceImpl({
    required this.apiKey,
    GenerativeModel? model
  }) : model = model ?? GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
      );

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
      
     //print("Sending prompt to Gemini for food description: $description");
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text == null) {
        ////print("ERROR: No response text generated from Gemini API");
        throw GeminiServiceException('No response text generated');
      }
      
      ////print the raw response text for debugging
      ////print("===== RAW GEMINI RESPONSE =====");
      ////print(response.text);
      ////print("===============================");
      
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
      ////print("ERROR during Gemini API call: $e");
      ////print("Stack trace: ${StackTrace.current}");
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
      
     //print("Sending image prompt to Gemini...");
      final response = await model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes)
        ])
      ]);
      
      if (response.text == null) {
       //print("ERROR: No response text generated from Gemini API for image");
        throw GeminiServiceException('No response text generated');
      }
      
      ////print the raw response text for debugging
     //print("===== RAW GEMINI IMAGE RESPONSE =====");
     //print(response.text);
     //print("====================================");
      
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
     //print("ERROR during Gemini image API call: $e");
     //print("Stack trace: ${StackTrace.current}");
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
      
     //print("Sending nutrition label analysis prompt to Gemini...");
      final response = await model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes)
        ])
      ]);
      
      if (response.text == null) {
       //print("ERROR: No response text generated from Gemini API for nutrition label");
        throw GeminiServiceException('No response text generated');
      }
      
      ////print the raw response text for debugging
     //print("===== RAW GEMINI NUTRITION LABEL RESPONSE =====");
     //print(response.text);
     //print("=============================================");
      
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
     //print("ERROR during Gemini nutrition label API call: $e");
     //print("Stack trace: ${StackTrace.current}");
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
      
     //print("Sending exercise analysis prompt to Gemini: $description");
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text == null) {
       //print("ERROR: No response text generated from Gemini API for exercise");
        throw GeminiServiceException('No response text generated');
      }
      
      ////print the raw response text for debugging
     //print("===== RAW GEMINI EXERCISE RESPONSE =====");
     //print(response.text);
     //print("=======================================");
      
      return _parseExerciseResponse(response.text!, description);
    } catch (e) {
     //print("ERROR during Gemini exercise API call: $e");
     //print("Stack trace: ${StackTrace.current}");
      throw GeminiServiceException("Error analyzing exercise: $e");
    }
  }
  
  FoodAnalysisResult _parseFoodAnalysisResponse(String responseText) {
    try {
     //print("Attempting to extract JSON from response text...");
      // Extract JSON from response text
      final jsonString = _extractJson(responseText);
     //print("Extracted JSON string: $jsonString");
      
     //print("Attempting to parse JSON data...");
      final jsonData = jsonDecode(jsonString);
     //print("JSON successfully parsed!");
      
      // Check for error field
      if (jsonData.containsKey('error') && jsonData['error'] is String) {
       //print("Error field found in response: ${jsonData['error']}");
        // This is an error response in the expected format
        throw GeminiServiceException(jsonData['error']);
      }
      
      // Parse food analysis result
     //print("Creating FoodAnalysisResult from JSON data...");
      return FoodAnalysisResult.fromJson(jsonData);
    } catch (e) {
     //print("ERROR parsing food analysis response: $e");
     //print("Stack trace: ${StackTrace.current}");
      throw GeminiServiceException("Failed to parse food analysis response: $e");
    }
  }
  
  ExerciseAnalysisResult _parseExerciseResponse(String responseText, String originalInput) {
    try {
     //print("Attempting to extract JSON from exercise response text...");
      // Extract JSON from response text
      final jsonString = _extractJson(responseText);
     //print("Extracted exercise JSON string: $jsonString");
      
     //print("Attempting to parse exercise JSON data...");
      final jsonData = jsonDecode(jsonString);
     //print("Exercise JSON successfully parsed!");
      
      // Check for error 
      if (jsonData.containsKey('error')) {
       //print("Error field found in exercise response: ${jsonData['error']}");
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
      final summary = 'You performed $exerciseType for ${durationMinutes} minutes at $intensityLevel intensity, burning approximately $caloriesBurned calories.';
      
      // Determine duration string format
      final duration = '$durationMinutes minutes';
      
     //print("Creating ExerciseAnalysisResult from JSON data...");
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
     //print("ERROR parsing exercise analysis response: $e");
     //print("Stack trace: ${StackTrace.current}");
      throw GeminiServiceException("Failed to parse exercise analysis response: $e");
    }
  }
  
  String _extractJson(String text) {
    try {
      // Try parsing the text directly first
     //print("Attempting to parse text directly as JSON...");
      jsonDecode(text);
     //print("Text is valid JSON!");
      return text;
    } catch (_) {
     //print("Direct JSON parsing failed, attempting to extract JSON from text...");
      // If direct parsing fails, try to extract JSON from the text
      final startIndex = text.indexOf('{');
      final endIndex = text.lastIndexOf('}');
      
     //print("Found JSON markers - Start: $startIndex, End: $endIndex");
      
      if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex) {
        final jsonString = text.substring(startIndex, endIndex + 1);
        // Validate that it's parseable
        try {
         //print("Validating extracted JSON string...");
          jsonDecode(jsonString);
         //print("Extracted JSON is valid!");
          return jsonString;
        } catch (e) {
         //print("Extracted text is not valid JSON: $e");
         //print("Invalid JSON string: $jsonString");
          throw GeminiServiceException('Extracted text is not valid JSON: $e');
        }
      }
      
     //print("No valid JSON structure found in response");
      throw GeminiServiceException('No valid JSON found in response');
    }
  }
}

class GeminiServiceException implements Exception {
  final String message;
  
  GeminiServiceException(this.message);
  
  @override
  String toString() => 'GeminiServiceException: $message';
}