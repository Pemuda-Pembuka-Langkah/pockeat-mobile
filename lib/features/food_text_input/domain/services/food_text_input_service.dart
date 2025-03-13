import 'dart:io';
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

  // Menganalisis deskripsi makanan dan mengembalikan hasil analisis
  Future<FoodAnalysisResult> analyzeFoodText(String description) async {
    try {
      final result = await _foodTextAnalysisService.analyze(description);
      return result;
    } catch (e) {
      throw Exception('Gagal menganalisis teks makanan: ${e.toString()}');
    }
  }

  // Menyimpan hasil analisis makanan ke dalam database
  Future<String> saveFoodAnalysis(FoodAnalysisResult analysisResult) async {
    try {
      await _foodTextInputRepository.save(analysisResult, _uuid.v4());
      return 'Successfully saved food analysis';
    } catch (e) {
      throw Exception('Failed to save food analysis: ${e.toString()}');
    }
  }

  // Memperbaiki hasil analisis makanan berdasarkan komentar pengguna
  Future<FoodAnalysisResult> correctFoodAnalysis(FoodAnalysisResult previousResult, String userComment) async {
    try {
      final correctedResult = await _foodTextAnalysisService.correctAnalysis(previousResult, userComment);
      return correctedResult;
    } catch (e) {
      throw Exception('Gagal memperbaiki analisis makanan: ${e.toString()}');
    }
  }
}
