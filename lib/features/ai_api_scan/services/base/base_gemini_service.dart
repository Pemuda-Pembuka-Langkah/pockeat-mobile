// lib/features/ai_api_scan/services/base/base_gemini_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/base/generative_model_wrapper.dart';
// coverage:ignore-start
abstract class BaseGeminiService {
  final String apiKey;
  final GenerativeModelWrapper modelWrapper;

  BaseGeminiService({
    required this.apiKey,
    GenerativeModelWrapper? customModelWrapper,
  }) : modelWrapper = customModelWrapper ??
            RealGenerativeModelWrapper(GenerativeModel(
              model: 'gemini-1.5-pro',
              apiKey: apiKey,
            ));

  static String getApiKeyFromEnv() {
    final apiKey = dotenv.env['GOOGLE_GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'GOOGLE_GEMINI_API_KEY not found in environment variables');
    }
    return apiKey;
  }
  // coverage:ignore-end
  String extractJson(String text) {
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

  String _cleanJsonText(String text) {
    // Remove JavaScript-style comments (both // and /* */)
    String cleaned = text.replaceAll(RegExp(r'//.*?(\n|$)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

    // Remove trailing commas in arrays and objects
    cleaned = cleaned.replaceAll(RegExp(r',\s*}'), '}');
    cleaned = cleaned.replaceAll(RegExp(r',\s*\]'), ']');

    // Replace single quotes with double quotes for JSON compliance
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