import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';

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
    final apiKey = dotenv.env['GOOGLE_GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'GOOGLE_GEMINI_API_KEY not found in environment variables');
    }

    return GeminiServiceImpl(apiKey: apiKey);
  }

  @override
  Future<FoodAnalysisResult> analyzeFoodByText(String description) async {
    try {
      final prompt = '''
      Analyze this food description: "$description"
      
      Please analyze the ingredients and nutritional content based on this description.
      If not described, assume a standard serving size and ingredients for 1 person only.
      
      Provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with servings composition (in grams) 
      - Detailed macronutrition information ONLY of calories, protein, carbs, fat, sodium, fiber, and sugar. No need to display other macro information.
      - Add warnings if the food contains high sodium (>500mg) or high sugar (>20g)
      
      Return your response as a strict JSON object with this exact format with NO COMMENTS:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "servings": number
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
        },
        "warnings": ["string", "string"] 
      }
      
      IMPORTANT: Do not include any comments, annotations or notes in the JSON. Do not use '#' or '//' characters. Only return valid JSON.
      For the warnings array:
      - Include "High sodium content" (exact text) if sodium exceeds 500mg
      - Include "High sugar content" (exact text) if sugar exceeds 20g
      If there are no warnings, you can include an empty array [] for warnings.
      
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
        },
        "warnings": []
      }
      ''';

      final response =
          await _modelWrapper.generateContent([Content.text(prompt)]);
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
      - Add warnings if the food contains high sodium (>500mg) or high sugar (>20g)
      
      Return your response as a strict JSON object with this exact format with NO COMMENTS:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "servings": number
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
        },
        "warnings": ["string", "string"]
      }
      
      IMPORTANT: Do not include any comments, annotations or notes in the JSON. Do not use '#' or '//' characters. Only return valid JSON.
      For the warnings array:
      - Include "High sodium content" (exact text) if sodium exceeds 500mg
      - Include "High sugar content" (exact text) if sugar exceeds 20g
      If there are no warnings, you can include an empty array [] for warnings.
      
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
        },
        "warnings": []
      }
      ''';

      final response = await _modelWrapper.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)])
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
  Future<FoodAnalysisResult> analyzeNutritionLabel(
      File imageFile, double servings) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final prompt = '''
      Analyze this nutrition label image. The user will consume $servings servings.
      
      Please provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with servings composition in grams
      - Detailed macronutrition information ONLY of calories, protein, carbs, fat, sodium, fiber, and sugar. No need to display other macro information.
      - Add warnings if the food contains high sodium (>500mg) or high sugar (>20g)
      
      Return your response as a strict JSON object with this exact format:
      {
        "food_name": "string",
        "ingredients": [
          {
            "name": "string",
            "servings": number
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
        },
        "warnings": ["string", "string"]
      }
      
      IMPORTANT: Do not include any comments, annotations or notes in the JSON. Do not use '#' or '//' characters. Only return valid JSON.
      For the warnings array:
      - Include "High sodium content" (exact text) if sodium exceeds 500mg
      - Include "High sugar content" (exact text) if sugar exceeds 20g
      If there are no warnings, you can include an empty array [] for warnings.
      
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
        },
        "warnings": []
      }
      ''';

      final response = await _modelWrapper.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)])
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
  Future<ExerciseAnalysisResult> analyzeExercise(String description,
      {double? userWeightKg}) async {
    try {
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

      final response =
          await _modelWrapper.generateContent([Content.text(prompt)]);
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
      final jsonString = _extractJson(responseText);
      final jsonData = jsonDecode(jsonString);

      // Check for error field
      if (jsonData.containsKey('error') && jsonData['error'] is String) {
        // Error message in string format

        throw GeminiServiceException(jsonData['error']);
      } else if (jsonData.containsKey('error') && jsonData['error'] is Map) {
        throw GeminiServiceException(
            jsonData['error']['message'] ?? 'Unknown error');
      }

      final result = FoodAnalysisResult.fromJson(jsonData);

      // Log any warnings
      if (result.warnings.isNotEmpty) {}

      return result;
    } catch (e) {
      throw GeminiServiceException(
          "Failed to parse food analysis response: $e");
    }
  }

  ExerciseAnalysisResult _parseExerciseResponse(
      String responseText, String originalInput) {
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
      return result;
    } catch (e) {
      throw GeminiServiceException(
          "Failed to parse exercise analysis response: $e");
    }
  }

  String _extractJson(String text) {
    try {
      // First try to clean up the text by removing comments and fixing common JSON issues
      String cleanedText = _cleanJsonText(text);

      // Try parsing the cleaned text
      try {
        jsonDecode(cleanedText);

        return cleanedText;
      } catch (_) {
        final startIndex = text.indexOf('{');
        final endIndex = text.lastIndexOf('}');

        if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex) {
          String jsonString = text.substring(startIndex, endIndex + 1);
          // Clean the extracted JSON
          jsonString = _cleanJsonText(jsonString);

          // Validate that it's parseable
          try {
            jsonDecode(jsonString);

            return jsonString;
          } catch (e) {
            throw GeminiServiceException(
                'Extracted text is not valid JSON: $e');
          }
        }

        throw GeminiServiceException('No valid JSON found in response');
      }
    } catch (e) {
      throw GeminiServiceException('Error extracting JSON: $e');
    }
  }

  // Helper method to clean up JSON text by removing comments and fixing common issues
  String _cleanJsonText(String text) {
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

    return cleaned;
  }
}
