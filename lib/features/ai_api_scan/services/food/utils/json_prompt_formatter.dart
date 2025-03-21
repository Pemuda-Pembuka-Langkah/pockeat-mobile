// lib/features/ai_api_scan/services/food/utils/json_prompt_formatter.dart
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

/// Utility class for formatting data into JSON strings for AI prompts
class JsonPromptFormatter {
  /// Formats a list of ingredients into a JSON array string
  static String formatIngredients(List<Ingredient> ingredients) {
    if (ingredients.isEmpty) {
      return '[]';
    }
    
    final buffer = StringBuffer('[');
    for (int i = 0; i < ingredients.length; i++) {
      buffer.write('{"name":"${_escapeString(ingredients[i].name)}","servings":${ingredients[i].servings}}');
      if (i < ingredients.length - 1) {
        buffer.write(',');
      }
    }
    buffer.write(']');
    return buffer.toString();
  }

  /// Formats a list of warnings into a JSON array string
  static String formatWarnings(List<String> warnings) {
    if (warnings.isEmpty) {
      return '[]';
    }
    
    final buffer = StringBuffer('[');
    for (int i = 0; i < warnings.length; i++) {
      buffer.write('"${_escapeString(warnings[i])}"');
      if (i < warnings.length - 1) {
        // coverage:ignore-start
        buffer.write(',');
        // coverage:ignore-end
      }
    }
    buffer.write(']');
    return buffer.toString();
  }

  /// Formats a FoodAnalysisResult into a JSON object string for prompts
  static String formatFoodAnalysisResult(FoodAnalysisResult result) {
    return '''
{
  "food_name": "${_escapeString(result.foodName)}",
  "ingredients": ${formatIngredients(result.ingredients)},
  "nutrition_info": {
    "calories": ${result.nutritionInfo.calories},
    "protein": ${result.nutritionInfo.protein},
    "carbs": ${result.nutritionInfo.carbs},
    "fat": ${result.nutritionInfo.fat},
    "sodium": ${result.nutritionInfo.sodium},
    "fiber": ${result.nutritionInfo.fiber},
    "sugar": ${result.nutritionInfo.sugar}
  },
  "warnings": ${formatWarnings(result.warnings)}
}''';
  }

  /// Escapes special characters in strings for JSON
  static String _escapeString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}