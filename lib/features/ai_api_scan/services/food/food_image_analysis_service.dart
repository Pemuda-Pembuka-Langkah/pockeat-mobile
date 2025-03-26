// lib/features/ai_api_scan/services/food/food_image_analysis_service.dart
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/base_gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/food_analysis_parser.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/json_prompt_formatter.dart';

class FoodImageAnalysisService extends BaseGeminiService {
  FoodImageAnalysisService({
    required super.apiKey,
    super.customModelWrapper,
  });

  // coverage:ignore-start
  factory FoodImageAnalysisService.fromEnv() {
    return FoodImageAnalysisService(
        apiKey: BaseGeminiService.getApiKeyFromEnv());
  }
  // coverage:ignore-end

  Future<FoodAnalysisResult> analyze(File imageFile) async {
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
      - Amount of food items
      
      Even if the image quality is not perfect or the food is partially visible, please do your best to identify it and provide an analysis.
      
      For the identified food, provide a comprehensive analysis including:
      - The specific name of the food
      - A detailed list of likely ingredients with estimated servings composition in grams, estimate based on size and portion to the best of your ability.
      - Detailed macronutrition information ONLY of calories, protein, carbs, fat, sodium, fiber, and sugar. No need to display other macro information.
      - Add warnings if the food contains high sodium (>500mg) or high sugar (>20g)
      
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
      throw GeminiServiceException("Error analyzing food from image: $e");
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

      final correctedResult = FoodAnalysisParser.parse(jsonString);

      return correctedResult;
    } catch (e) {
      if (e is GeminiServiceException) {
        rethrow;
      }
      throw GeminiServiceException("Error correcting food analysis: $e");
    }
  }
}
