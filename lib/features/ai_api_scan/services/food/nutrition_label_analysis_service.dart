// lib/features/ai_api_scan/services/food/nutrition_label_analysis_service.dart
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/base_gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/food_analysis_parser.dart';

class NutritionLabelAnalysisService extends BaseGeminiService {
  NutritionLabelAnalysisService({
    required super.apiKey,
    super.customModelWrapper,
  });
// coverage:ignore-start
  factory NutritionLabelAnalysisService.fromEnv() {
    return NutritionLabelAnalysisService(
        apiKey: BaseGeminiService.getApiKeyFromEnv());
  }
  // coverage:ignore-end

  Future<FoodAnalysisResult> analyze(File imageFile, double servings) async {
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

      final response = await modelWrapper.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)])
      ]);

      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }

      final jsonString = extractJson(response.text!);
      return FoodAnalysisParser.parse(jsonString);
    } catch (e) {
      if (e is GeminiServiceException) {
        rethrow;
      }
      throw GeminiServiceException("Error analyzing nutrition label: $e");
    }
  }

  Future<FoodAnalysisResult> correctAnalysis(FoodAnalysisResult previousResult,
      String userComment, double servings) async {
    try {
      final prompt = '''
      Original nutrition label analysis (for $servings servings):
      - Food name: ${previousResult.foodName}
      - Ingredients: ${previousResult.ingredients.map((i) => "${i.name}: ${i.servings}g").join(", ")}
      - Calories: ${previousResult.nutritionInfo.calories}
      - Protein: ${previousResult.nutritionInfo.protein}g
      - Carbs: ${previousResult.nutritionInfo.carbs}g
      - Fat: ${previousResult.nutritionInfo.fat}g
      - Sodium: ${previousResult.nutritionInfo.sodium}mg
      - Fiber: ${previousResult.nutritionInfo.fiber}g
      - Sugar: ${previousResult.nutritionInfo.sugar}g
      - Warnings: ${previousResult.warnings.join(", ")}
      
      User correction comment: "$userComment"
      
      
      Please correct and analyze the ingredients and nutritional content on the correction comment.
      If it is about an ingredient or the food and not described, assume a standard serving size and ingredients for 1 person only.
      
      Provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with servings composition (in grams) 
      - Detailed macronutrition information ONLY of calories, protein, carbs, fat, sodium, fiber, and sugar. No need to display other macro information.
      - Add warnings if the food contains high sodium (>500mg) or high sugar (>20g)
      
      Only modify values that need to be changed according to the user's feedback, but remember that the user CAN give more than one feedback.
      Please correct the analysis based on the user's comment accordingly.
      
      The corrected analysis should be for $servings servings.
      
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
        "warnings": ["string"]
      }
      
      IMPORTANT: Do not include any comments, annotations or notes in the JSON. Do not use '#' or '//' characters. Only return valid JSON.
      For the warnings array:
      - Include "High sodium content" (exact text) if sodium exceeds 500mg
      - Include "High sugar content" (exact text) if sugar exceeds 20g
      If there are no warnings, you can include an empty array [] for warnings.
      ''';

      final response =
          await modelWrapper.generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }

      final jsonString = extractJson(response.text!);
      return FoodAnalysisParser.parse(jsonString);
    } catch (e) {
      if (e is GeminiServiceException) {
        rethrow;
      }
      throw GeminiServiceException(
          "Error correcting nutrition label analysis: $e");
    }
  }
}
