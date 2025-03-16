// lib/features/ai_api_scan/services/food/food_text_analysis_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/base/base_gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/food_analysis_parser.dart';
import 'package:pockeat/features/ai_api_scan/services/food/utils/json_prompt_formatter.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FoodTextAnalysisService extends BaseGeminiService {
  final FirebaseFirestore _firestore;
  // Create a low-temperature model wrapper for accurate analysis
  final GenerativeModelWrapper _accurateModelWrapper;

  FoodTextAnalysisService({
    required super.apiKey,
    FirebaseFirestore? firestore,
    super.customModelWrapper,
    GenerativeModelWrapper? accurateModelWrapper,
     // coverage:ignore-start
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _accurateModelWrapper = accurateModelWrapper ?? RealGenerativeModelWrapper(
         GenerativeModel(
           model: 'gemini-1.5-pro',
           apiKey: apiKey,
           generationConfig: GenerationConfig(
             temperature: 0.2, // Much lower temperature for precise analysis
             topK: 40,
             topP: 0.95,
             maxOutputTokens: 8192,
             responseMimeType: 'text/plain',
           ),
         )
       );

  factory FoodTextAnalysisService.fromEnv() {
    final apiKey = BaseGeminiService.getApiKeyFromEnv();

    return FoodTextAnalysisService(
      apiKey: apiKey,
    );
  }
  // coverage:ignore-end

  // Initial food identification with higher temperature
  Future<Map<String, dynamic>> _identifyFood(String description) async {
    try {
      final prompt = '''
      You are a food recognition expert. Carefully analyze this food description and identify the food or meal.
      
      DESCRIPTION: "$description"
      
      Please provide your best identification of the specific name of this food.
      
      Return your response as a strict JSON object with this exact format:
      {
        "food_name": "string",
        "description": "string"
      }
      ''';

      // Use default model with higher temperature for creative identification
      final response = await modelWrapper.generateContent([Content.text(prompt)]);
      // coverage:ignore-start
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }
       // coverage:ignore-end
      final jsonString = extractJson(response.text!);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (e is GeminiServiceException) {
        rethrow;
      }
       // coverage:ignore-start
      throw GeminiServiceException("Error identifying food: $e");
       // coverage:ignore-end
    }
  }

  // Find similar foods by name using Firestore
  Future<List<Map<String, dynamic>>> _findSimilarFoods(String foodName) async {
    try {
      // Split the food name into words for better matching
      final List<String> searchTerms = foodName
          .toLowerCase()
          .split(' ')
          .where((term) => term.length > 2) // Filter out short words
          .toList();

      // If no valid search terms, return empty list
       // coverage:ignore-start
      if (searchTerms.isEmpty) {
        return [];
      }
       // coverage:ignore-end

      // Get a reference to the food collection
      final foodCollection = _firestore.collection('fooddataset');
      
      // Initial query with the first term
      final initialTerm = searchTerms[0];
      
      var query = foodCollection
          .orderBy('title')
          .startAt([initialTerm])
          .endAt(['$initialTerm\uf8ff'])
          .limit(20); // Get more than we need for filtering
      
      // Execute query
      final snapshot = await query.get();
      
      // Filter and score results based on title similarity
      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        final title = (data['title'] as String).toLowerCase();
        
        // Calculate a simple relevance score based on how many terms match
        int matchCount = searchTerms.where((term) => title.contains(term)).length;
        double similarity = matchCount / searchTerms.length;
        
        return {
          'id': doc.id,
          'title': data['title'],
          'ingredients': data['cleaned_ingredients'],
          'image_url': data['image_url'],
          'score': similarity,
        };
      }).toList();
      
      // Sort by relevance
      results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
      
      // Return top 5 results
      return results.take(5).toList();
    } catch (e) {
      throw GeminiServiceException("Error finding similar foods: $e");
    }
  }

  // Helper method to download image from URL
  Future<Uint8List?> _downloadImageBytes(String imageUrl) async {
    try {
      // Skip if the URL is not valid
      if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
        return null;
      }
      
      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return null;
      }
      
       // coverage:ignore-start
      return response.bodyBytes;
    } catch (e) {
      throw('Failed to download image: $e');
    }
     // coverage:ignore-end
  }

  // Check if the search results have low confidence
  bool _isLowConfidence(List<Map<String, dynamic>> similarFoods) {
    // Case 1: No results found
    if (similarFoods.isEmpty) {
      return true;
    }
    
    // Case 2: Top result has low similarity score (below 60%)
    if (similarFoods.isNotEmpty && similarFoods[0]['score'] < 0.60) {
      return true;
    }
    
    return false;
  }
  
  // Mark a result as low confidence
  FoodAnalysisResult _markLowConfidence(FoodAnalysisResult result) {
    // Add a note about low confidence to the warnings
    List<String> updatedWarnings = List<String>.from(result.warnings);
    if (!updatedWarnings.contains(FoodAnalysisResult.lowConfidenceWarning)) {
      updatedWarnings.add(FoodAnalysisResult.lowConfidenceWarning);
    }
    
    // Create a copy with the low confidence flag set
    return result.copyWith(
      isLowConfidence: true,
      warnings: updatedWarnings,
    );
  }

  // Analysis with references but no user image
  Future<FoodAnalysisResult> _analyzeWithReferences(
      String description, List<Map<String, dynamic>> similarFoods) async {
    try {
      // Start with the basic prompt
      String textPrompt = '''
      You are a food recognition and nutrition analysis expert. I am giving you a text description of food.
      
      USER'S FOOD DESCRIPTION:
      "$description"
      
      REFERENCE DATA:
      Here are similar foods from our database that may help with your analysis:
      ''';

      // We'll create a list to hold all content parts
      List<Part> contentParts = [];
      
      // Add the text prompt first
      contentParts.add(TextPart(textPrompt));

      // Add the reference foods information and try to download their images
      int refIndex = 1;
      String? selectedImageUrl; // To store the top reference image URL
      
      for (final food in similarFoods) {
        // Add text description for this reference food
        contentParts.add(TextPart('''
        
        REFERENCE FOOD $refIndex:
        Name: ${food['title']}
        Ingredients: ${food['ingredients']}
        Similarity Score: ${(food['score'] * 100).toStringAsFixed(1)}%
        '''));
        
        if (food['image_url'] != null && food['image_url'].toString().isNotEmpty) {           
              if (refIndex == 1) {
                selectedImageUrl = food['image_url'];
              }
        }
        
        refIndex++;
      }
      
      // Add the task instructions
      contentParts.add(TextPart('''
      
      TASK:
      1. Look at the user's food description carefully
      2. Compare it with the reference foods and their images (if provided)
      3. Analyze what the described food likely is (composition, portion sizes, etc.)
      4. Use the reference data to help estimate nutritional values
      
      Provide:
      - The specific name of the food based on the description
      - A detailed list of ingredients with estimated servings composition in grams
      - Detailed macronutrition information of calories, protein, carbs, fat, sodium, fiber, and sugar
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
        "warnings": ["string"]
      }
      '''));

      // Use low temperature model for accurate analysis with all content parts
      final response = await _accurateModelWrapper.generateContent([
        Content.multi(contentParts)
      ]);

      // coverage:ignore-start
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }
       // coverage:ignore-end

      final jsonString = extractJson(response.text!);
      FoodAnalysisResult result = FoodAnalysisParser.parse(jsonString);
      
      // Set the image URL from the top similar food
      if (selectedImageUrl != null) {
        result = result.copyWith(foodImageUrl: selectedImageUrl);
      }
      
      return result;
    } catch (e) {
      // coverage:ignore-start
      if (e is GeminiServiceException) {
        rethrow;
      }
      throw GeminiServiceException("Error in accurate analysis: $e");
    }
    // coverage:ignore-end
  }
  
  // Direct analysis without reference data
  Future<FoodAnalysisResult> _directAnalysis(String description) async {
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

      // Use low temperature model for accurate analysis
      final response = await _accurateModelWrapper.generateContent([Content.text(prompt)]);
      
      // coverage:ignore-start
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }
       // coverage:ignore-end

      final jsonString = extractJson(response.text!);
      return FoodAnalysisParser.parse(jsonString);
    } catch (e) {
      // coverage:ignore-start
      if (e is GeminiServiceException) {
        rethrow;
      }
      throw GeminiServiceException("Failed to analyze food description: $e");
    }
    // coverage:ignore-end
  }

  Future<FoodAnalysisResult> analyze(String description) async {
    try {
      // Step 1: Initial food identification
      final identification = await _identifyFood(description);
      final foodName = identification['food_name'] as String;
      
      // Step 2: Find similar foods by name
      final similarFoods = await _findSimilarFoods(foodName);
      
      // Check for low confidence results
      bool lowConfidence = _isLowConfidence(similarFoods);
      
      // Step 3: Final analysis
      FoodAnalysisResult result;
      if (lowConfidence) {
        // Fallback to direct analysis if low confidence
        result = await _directAnalysis(description);
        // Mark the result as potentially less accurate
        result = _markLowConfidence(result);
      } else {
        // Use reference-augmented analysis with images
        result = await _analyzeWithReferences(description, similarFoods);
      }
      
      return result;
    } catch (e) {
      if (e is GeminiServiceException) {
        rethrow;
      }
      // coverage:ignore-start
      throw GeminiServiceException("Error analyzing food: $e");
      // coverage:ignore-end
    }
  }


  Future<FoodAnalysisResult> correctAnalysis(
      FoodAnalysisResult previousResult, String userComment) async {
    try {
      // Prepare the basic text prompt
      String textPrompt = '''
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
      ''';

      List<Part> contentParts = [];
      contentParts.add(TextPart(textPrompt));

      // Check if we have an image URL from the reference food, and if so, try to include it
      if (previousResult.foodImageUrl != null && previousResult.foodImageUrl!.isNotEmpty && 
          previousResult.foodImageUrl!.startsWith('http')) {
        try {
          final imageBytes = await _downloadImageBytes(previousResult.foodImageUrl!);
          // coverage:ignore-start
          if (imageBytes != null) {
            contentParts.add(DataPart('image/jpeg', imageBytes));
            contentParts.add(TextPart('''
            
            ABOVE IS A REFERENCE IMAGE
            Look at this image as a reference while making corrections.
            '''));
          }
          // coverage:ignore-end
        } catch (e) {
          // If we can't get the image, just continue without it
          // print('Failed to load reference image for correction: $e');
        }
      }

      // Add the response format instructions
      contentParts.add(TextPart('''
      
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
      '''));

      // Use low temperature model for corrections with all content parts
      final response = await _accurateModelWrapper.generateContent([
        Content.multi(contentParts)
      ]);
      // coverage:ignore-start
      if (response.text == null) {
        throw GeminiServiceException('No response text generated');
      }
       // coverage:ignore-end

      final jsonString = extractJson(response.text!);
      
      // Parse the corrected result
      FoodAnalysisResult correctedResult = FoodAnalysisParser.parse(jsonString);
      
      // Preserve the original confidence flag when making corrections
      if (previousResult.isLowConfidence) {
        correctedResult = correctedResult.copyWith(isLowConfidence: true);
        
        // Check if the low confidence warning is present and add it if not
        bool hasLowConfidenceWarning = correctedResult.warnings.any(
          (warning) => warning == FoodAnalysisResult.lowConfidenceWarning
        );
        
        if (!hasLowConfidenceWarning) {
          List<String> updatedWarnings = List<String>.from(correctedResult.warnings);
          updatedWarnings.add(FoodAnalysisResult.lowConfidenceWarning);
          correctedResult = correctedResult.copyWith(warnings: updatedWarnings);
        }
      }
      
      // Preserve the original image URL when making corrections
      if (previousResult.foodImageUrl != null) {
        correctedResult = correctedResult.copyWith(foodImageUrl: previousResult.foodImageUrl);
      }
      
      return correctedResult;
    } catch (e) {
      if (e is GeminiServiceException) {
        rethrow;
      }
      throw GeminiServiceException("Error correcting food analysis: $e");
    }
  }
}