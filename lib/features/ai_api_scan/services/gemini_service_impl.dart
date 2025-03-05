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

  GeminiServiceImpl(
      {required this.apiKey, GenerativeModelWrapper? modelWrapper})
      : _modelWrapper = modelWrapper ??
            RealGenerativeModelWrapper(GenerativeModel(
              model: 'gemini-1.5-pro',
              apiKey: apiKey,
            ));

  factory GeminiServiceImpl.fromEnv() {
    print("DEBUG: GeminiServiceImpl - Loading API key from .env");
    final apiKey = dotenv.env['GOOGLE_GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print(
          "ERROR: GeminiServiceImpl - GOOGLE_GEMINI_API_KEY not found in environment variables");
      throw Exception(
          'GOOGLE_GEMINI_API_KEY not found in environment variables');
    }
    print("DEBUG: GeminiServiceImpl - API key loaded successfully");
    return GeminiServiceImpl(apiKey: apiKey);
  }

  @override
  Future<FoodAnalysisResult> analyzeFoodByText(String description) async {
    try {
      print("DEBUG: GeminiServiceImpl - Analyzing food by text: $description");
      final prompt = '''
      Analyze this food description: "$description"
      
      Please analyze the ingredients and nutritional content based on this description.
      If not described, assume a standard serving size and ingredients from the description of the food with serving of 1 person only.
      
      Provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with servings composition (in grams) 
      - Detailed macronutrition information ONLY of calories, protein, carbs, fat, sodium, fiber, and sugar. No need to display other macro information.
      
      Return your response as a strict JSON object with this exact format with NO COMMENTS:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "servings": number,
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
      
      IMPORTANT: Do not include any comments, annotations or notes in the JSON. Do not use '#' or '//' characters. Only return valid JSON.
      
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

      print("DEBUG: GeminiServiceImpl - Sending text prompt to Gemini API");
      final response =
          await _modelWrapper.generateContent([Content.text(prompt)]);
      if (response.text == null) {
        print(
            "ERROR: GeminiServiceImpl - No response text generated from Gemini API");
        throw GeminiServiceException('No response text generated');
      }

      print(
          "DEBUG: GeminiServiceImpl - Received response from Gemini API, parsing result");
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
      print("ERROR: GeminiServiceImpl - Error analyzing food by text: $e");
      throw GeminiServiceException("Error analyzing food: $e");
    }
  }

  @override
  Future<FoodAnalysisResult> analyzeFoodByImage(File imageFile) async {
    try {
      print(
          "DEBUG: GeminiServiceImpl - Analyzing food by image: ${imageFile.path}");
      print("DEBUG: GeminiServiceImpl - Reading image file as bytes");
      final imageBytes = await imageFile.readAsBytes();
      print(
          "DEBUG: GeminiServiceImpl - Image file read successfully, size: ${imageBytes.length} bytes");

      final prompt = '''
      You are a food recognition and nutrition analysis expert. Carefully analyze this image and identify any food or meal present.
      
      Please look for:
      - Prepared meals
      - Individual food items
      - Snacks
      - Beverages
      - Fruits and vegetables
      - Packaged food products
      
      Even if the image quality is not perfect or the food is partially visible, please do your best to identify it and provide an analysis.
      
      For the identified food, provide a comprehensive analysis including:
      - The specific name of the food
      - A detailed list of likely ingredients with estimated servings composition in grams
      - Detailed macronutrition information ONLY of calories, protein, carbs, fat, sodium, fiber, and sugar. No need to display other macro information.
      
      Return your response as a strict JSON object with this exact format with NO COMMENTS:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "servings": number,
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
      
      IMPORTANT: Do not include any comments, annotations or notes in the JSON. Do not use '#' or '//' characters. Only return valid JSON.
      
      If absolutely no food can be detected in the image, only then use this format:
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

      print("DEBUG: GeminiServiceImpl - Sending image prompt to Gemini API");
      final response = await _modelWrapper.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)])
      ]);

      if (response.text == null) {
        print(
            "ERROR: GeminiServiceImpl - No response text generated from Gemini API for image analysis");
        throw GeminiServiceException('No response text generated');
      }

      print(
          "DEBUG: GeminiServiceImpl - Received response from Gemini API for image, parsing result");
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
      print("ERROR: GeminiServiceImpl - Error analyzing food image: $e");
      throw GeminiServiceException("Error analyzing food image: $e");
    }
  }

  @override
  Future<FoodAnalysisResult> analyzeNutritionLabel(
      File imageFile, double servings) async {
    try {
      print(
          "DEBUG: GeminiServiceImpl - Analyzing nutrition label: ${imageFile.path}, servings: $servings");
      print(
          "DEBUG: GeminiServiceImpl - Reading nutrition label image file as bytes");
      final imageBytes = await imageFile.readAsBytes();
      print(
          "DEBUG: GeminiServiceImpl - Nutrition label image read successfully, size: ${imageBytes.length} bytes");

      final prompt = '''
      Analyze this nutrition label image. The user will consume $servings servings.
      
      Please provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with servings composition in grams
      - Detailed macronutrition information ONLY of calories, protein, carbs, fat, sodium, fiber, and sugar. No need to display other macro information.
      
      Return your response as a strict JSON object with this exact format:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "servings": number,
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

      print(
          "DEBUG: GeminiServiceImpl - Sending nutrition label prompt to Gemini API");
      final response = await _modelWrapper.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)])
      ]);

      if (response.text == null) {
        print(
            "ERROR: GeminiServiceImpl - No response text generated from Gemini API for nutrition label");
        throw GeminiServiceException('No response text generated');
      }

      print(
          "DEBUG: GeminiServiceImpl - Received response from Gemini API for nutrition label, parsing result");
      return _parseFoodAnalysisResponse(response.text!);
    } catch (e) {
      print("ERROR: GeminiServiceImpl - Error analyzing nutrition label: $e");
      throw GeminiServiceException("Error analyzing nutrition label: $e");
    }
  }

  @override
  Future<ExerciseAnalysisResult> analyzeExercise(String description,
      {double? userWeightKg}) async {
    try {
      print(
          "DEBUG: GeminiServiceImpl - Analyzing exercise: $description, user weight: $userWeightKg kg");
      final weightInfo =
          userWeightKg != null ? "The user weighs $userWeightKg kg." : "";

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

      print("DEBUG: GeminiServiceImpl - Sending exercise prompt to Gemini API");
      final response =
          await _modelWrapper.generateContent([Content.text(prompt)]);
      if (response.text == null) {
        print(
            "ERROR: GeminiServiceImpl - No response text generated from Gemini API for exercise");
        throw GeminiServiceException('No response text generated');
      }

      print(
          "DEBUG: GeminiServiceImpl - Received response from Gemini API for exercise, parsing result");
      return _parseExerciseResponse(response.text!, description);
    } catch (e) {
      print("ERROR: GeminiServiceImpl - Error analyzing exercise: $e");
      throw GeminiServiceException("Error analyzing exercise: $e");
    }
  }

  FoodAnalysisResult _parseFoodAnalysisResponse(String responseText) {
    try {
      print("DEBUG: GeminiServiceImpl - Parsing food analysis response");
      print(
          "DEBUG: GeminiServiceImpl - Response text (first 100 chars): ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...");
      // Extract JSON from response text
      final jsonString = _extractJson(responseText);
      print(
          "DEBUG: GeminiServiceImpl - Extracted JSON (first 100 chars): ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...");
      final jsonData = jsonDecode(jsonString);
      print("DEBUG: GeminiServiceImpl - JSON decoded successfully");

      // Check for error field
      if (jsonData.containsKey('error') && jsonData['error'] is String) {
        // Error message in string format
        print(
            "ERROR: GeminiServiceImpl - Error found in API response: ${jsonData['error']}");
        throw GeminiServiceException(jsonData['error']);
      } else if (jsonData.containsKey('error') && jsonData['error'] is Map) {
        // Error in object format
        print(
            "ERROR: GeminiServiceImpl - Error object found in API response: ${jsonData['error']}");
        throw GeminiServiceException(
            jsonData['error']['message'] ?? 'Unknown error');
      }

      // Parse food analysis result
      print("DEBUG: GeminiServiceImpl - Creating FoodAnalysisResult from JSON");
      final result = FoodAnalysisResult.fromJson(jsonData);
      print(
          "DEBUG: GeminiServiceImpl - FoodAnalysisResult created successfully: ${result.foodName}");
      return result;
    } catch (e) {
      print(
          "ERROR: GeminiServiceImpl - Failed to parse food analysis response: $e");
      throw GeminiServiceException(
          "Failed to parse food analysis response: $e");
    }
  }

  ExerciseAnalysisResult _parseExerciseResponse(
      String responseText, String originalInput) {
    try {
      print("DEBUG: GeminiServiceImpl - Parsing exercise analysis response");
      print(
          "DEBUG: GeminiServiceImpl - Response text (first 100 chars): ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...");
      // Extract JSON from response text
      final jsonString = _extractJson(responseText);
      print(
          "DEBUG: GeminiServiceImpl - Extracted JSON (first 100 chars): ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...");
      final jsonData = jsonDecode(jsonString);
      print("DEBUG: GeminiServiceImpl - JSON decoded successfully");

      // Check for error
      if (jsonData.containsKey('error')) {
        print(
            "WARNING: GeminiServiceImpl - Error found in exercise API response: ${jsonData['error']}");
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
      print(
          "DEBUG: GeminiServiceImpl - Creating ExerciseAnalysisResult from JSON");
      final exerciseType = jsonData['exercise_type'] ?? 'Unknown';
      final caloriesBurned = jsonData['calories_burned'] ?? 0;
      final durationMinutes = jsonData['duration_minutes'] ?? 0;
      final intensityLevel = jsonData['intensity_level'] ?? 'Unknown';
      final metValue = (jsonData['met_value'] ?? 0.0).toDouble();

      // Create a summary
      final summary =
          'You performed $exerciseType for $durationMinutes minutes at $intensityLevel intensity, burning approximately $caloriesBurned calories.';

      // Determine duration string format
      final duration = '$durationMinutes minutes';

      // Create the exercise analysis result in the app's model format
      final result = ExerciseAnalysisResult(
        exerciseType: exerciseType,
        duration: duration,
        intensity: intensityLevel,
        estimatedCalories:
            caloriesBurned is int ? caloriesBurned : caloriesBurned.toInt(),
        metValue: metValue,
        summary: summary,
        timestamp: DateTime.now(),
        originalInput: originalInput,
      );
      print(
          "DEBUG: GeminiServiceImpl - ExerciseAnalysisResult created successfully: ${result.exerciseType}");
      return result;
    } catch (e) {
      print(
          "ERROR: GeminiServiceImpl - Failed to parse exercise analysis response: $e");
      throw GeminiServiceException(
          "Failed to parse exercise analysis response: $e");
    }
  }

  String _extractJson(String text) {
    try {
      print("DEBUG: GeminiServiceImpl - Attempting to extract JSON from text");

      // First try to clean up the text by removing comments and fixing common JSON issues
      String cleanedText = _cleanJsonText(text);

      // Try parsing the cleaned text
      try {
        jsonDecode(cleanedText);
        print(
            "DEBUG: GeminiServiceImpl - Cleaned text is valid JSON, using this");
        return cleanedText;
      } catch (_) {
        print(
            "DEBUG: GeminiServiceImpl - Cleaned text is still not valid JSON, trying to extract JSON");
        // If direct parsing fails, try to extract JSON from the text
        final startIndex = text.indexOf('{');
        final endIndex = text.lastIndexOf('}');

        print(
            "DEBUG: GeminiServiceImpl - JSON boundaries: start=${startIndex}, end=${endIndex}");

        if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex) {
          String jsonString = text.substring(startIndex, endIndex + 1);
          // Clean the extracted JSON
          jsonString = _cleanJsonText(jsonString);

          // Validate that it's parseable
          try {
            jsonDecode(jsonString);
            print(
                "DEBUG: GeminiServiceImpl - Successfully extracted valid JSON");
            return jsonString;
          } catch (e) {
            print(
                "ERROR: GeminiServiceImpl - Extracted text is not valid JSON: $e");
            print(
                "DEBUG: GeminiServiceImpl - Extracted JSON content: $jsonString");
            throw GeminiServiceException(
                'Extracted text is not valid JSON: $e');
          }
        }

        print("ERROR: GeminiServiceImpl - No valid JSON found in response");
        throw GeminiServiceException('No valid JSON found in response');
      }
    } catch (e) {
      print("ERROR: GeminiServiceImpl - Error extracting JSON: $e");
      throw GeminiServiceException('Error extracting JSON: $e');
    }
  }

  // Helper method to clean up JSON text by removing comments and fixing common issues
  String _cleanJsonText(String text) {
    print("DEBUG: GeminiServiceImpl - Cleaning JSON text");

    // Remove JavaScript-style comments (both // and /* */)
    String cleaned = text.replaceAll(RegExp(r'//.*?(\n|$)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

    // Remove trailing commas in arrays and objects
    cleaned = cleaned.replaceAll(RegExp(r',\s*}'), '}');
    cleaned = cleaned.replaceAll(RegExp(r',\s*\]'), ']');

    // Replace single quotes with double quotes for JSON compliance
    // This is more complex as we need to be careful not to replace quotes within quotes
    List<String> parts = [];
    bool inQuotes = false;
    bool inSingleQuotes = false;

    for (int i = 0; i < cleaned.length; i++) {
      String char = cleaned[i];

      if (char == '"' && (i == 0 || cleaned[i - 1] != '\\')) {
        inQuotes = !inQuotes;
      } else if (char == "'" &&
          (i == 0 || cleaned[i - 1] != '\\') &&
          !inQuotes) {
        inSingleQuotes = !inSingleQuotes;
        char = '"'; // Replace single quote with double quote
      }

      parts.add(char);
    }

    cleaned = parts.join();

    print(
        "DEBUG: GeminiServiceImpl - Cleaned JSON text (first 100 chars): ${cleaned.substring(0, cleaned.length > 100 ? 100 : cleaned.length)}...");
    return cleaned;
  }
}
