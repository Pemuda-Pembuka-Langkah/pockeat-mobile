// lib/features/ai_api_scan/services/food/food_text_analysis_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/base_gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/food_analysis_parser.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/json_prompt_formatter.dart';

class FoodTextAnalysisService extends BaseGeminiService {
  FoodTextAnalysisService({
    required super.apiKey,
    super.customModelWrapper,
  });

  // coverage:ignore-start
  factory FoodTextAnalysisService.fromEnv() {
    return FoodTextAnalysisService(
        apiKey: BaseGeminiService.getApiKeyFromEnv());
  }
  // coverage:ignore-end

  Future<FoodAnalysisResult> analyze(String description) async {
    try {
      final prompt = '''
      Analyze this food description: "$description"
      
      Please analyze the ingredients and nutritional content based on this description.
      If not described, assume a standard serving size and ingredients for 1 person only.
      
      Provide a comprehensive analysis including:
      - The name of the food
      - A complete list of ingredients with servings composition (in grams) from portion estimation or standard serving size.
      - Detailed macronutrition information ONLY of calories, protein, carbs, fat, sodium, fiber, and sugar. No need to display other macro information.
      - Add warnings if the food contains high sodium (>500mg) or high sugar (>20g).
      

      BE VERY THOROUGH. YOU WILL BE FIRED. THE CUSTOMER CAN GET POISONED. BE VERY THOROUGH.

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
          await modelWrapper.generateContent([Content.text(prompt)]);
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }

      final jsonString = extractJson(response.text!);
      return FoodAnalysisParser.parse(jsonString);
    } catch (e) {
      throw GeminiServiceException(
          "Failed to analyze food description '$description': $e");
    }
  }

  Future<FoodAnalysisResult> correctAnalysis(
      FoodAnalysisResult previousResult, String userComment) async {
    try {
      final prompt = '''
      You are a food nutrition expert tasked with correcting a food analysis based on user feedback.

      ORIGINAL ANALYSIS:
      ${JsonPromptFormatter.formatFoodAnalysisResult(previousResult)}
      
      USER CORRECTION: "$userComment"
      
      INSTRUCTIONS:
      1. Carefully analyze the user's correction and determine what specific aspects need to be modified.
      2. Consider these possible correction types:
         - Food identity correction (e.g., "this is chicken, not beef")
         - Ingredient additions/removals/adjustments (e.g., "there's no butter" or "add 15g of cheese")
         - Portion size adjustments (e.g., "this is a half portion")
         - Nutritional value corrections (e.g., "calories should be around 350")
         - Special dietary information (e.g., "this is a vegan version")
      3. Only modify elements that need correction based on the user's feedback.
      4. Keep all other values from the original analysis intact.
      5. Maintain reasonable nutritional consistency (e.g., if calories increase, check if macros need adjustment).
      6. For standard serving size, use common restaurant or cookbook portions for a single adult.
      
      RESPONSE FORMAT:
      Return a valid JSON object with exactly this structure:
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
      
      WARNING CRITERIA:
      - Add "High sodium content" if sodium exceeds 500mg
      - Add "High sugar content" if sugar exceeds 20g
      - Use empty array [] if no warnings apply
      
      IMPORTANT: Return only the JSON object with no additional text, comments, or explanations.
      ''';

      final response =
          await modelWrapper.generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }

      final jsonString = extractJson(response.text!);
      return FoodAnalysisParser.parse(jsonString);
    } catch (e) {
      throw GeminiServiceException("Failed to correct food analysis: $e");
    }
  }
}
