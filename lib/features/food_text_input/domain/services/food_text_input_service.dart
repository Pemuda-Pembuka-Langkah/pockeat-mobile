import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:uuid/uuid.dart';

class FoodTextInputService {
  final FoodTextAnalysisService _foodTextAnalysisService = getIt<FoodTextAnalysisService>();
  final FoodTextInputRepository _foodTextInputRepository = getIt<FoodTextInputRepository>();
  final Uuid _uuid = Uuid();

  FoodTextInputService();

  /// Analyzes food description and returns the analysis result
  Future<FoodAnalysisResult> analyzeFoodText(String description) async {
    try {
      final result = await _foodTextAnalysisService.analyze(description);
      return result;
    } catch (e) {
      throw Exception('Failed to analyze food text: ${e.toString()}');
    }
  }

  /// Saves the food analysis result to the database
  Future<String> saveFoodAnalysis(FoodAnalysisResult analysisResult) async {
    try {
      await _foodTextInputRepository.save(analysisResult, analysisResult.id ?? _uuid.v4());
      return 'Successfully saved food analysis';
    } catch (e) {
      throw Exception('Failed to save food analysis: ${e.toString()}');
    }
  }

  /// Corrects a food analysis result based on user feedback
  Future<FoodAnalysisResult> correctFoodAnalysis(FoodAnalysisResult previousResult, String userComment) async {
    try {
      final correctedResult = await _foodTextAnalysisService.correctAnalysis(previousResult, userComment);
      return correctedResult;
    } catch (e) {
      throw Exception('Failed to correct food analysis: ${e.toString()}');
    }
  }

  /// Retrieves all food analysis results
  Future<List<FoodAnalysisResult>> getAllFoodAnalysis() async {
    return await _foodTextInputRepository.getAll();
  }
}