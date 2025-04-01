import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FoodTextInputService {
  final FoodTextAnalysisService _foodTextAnalysisService;
  final FoodTextInputRepository _foodTextInputRepository;
  final FirebaseAuth _auth;
  final Uuid _uuid = Uuid();

  FoodTextInputService(
    this._foodTextAnalysisService, 
    this._foodTextInputRepository, 
    {FirebaseAuth? auth}
  ) : _auth = auth ?? FirebaseAuth.instance;

  /// Analyzes food description and returns the analysis result
  Future<FoodAnalysisResult> analyzeFoodText(String description) async {
    try {
      return await _foodTextAnalysisService.analyze(description);
    } catch (e) {
      throw Exception('Food text analysis failed: ${e.toString()}');
    }
  }

  /// Saves the food analysis result to the database
  Future<String> saveFoodAnalysis(FoodAnalysisResult analysisResult, {bool isCorrected = false}) async {
    try {
      final String analysisId = analysisResult.id ?? _uuid.v4();
      
      // Get current user's ID
      final userId = _auth.currentUser?.uid ?? '';
      
      // Create a new analysis result with userId
      final resultWithUserId = analysisResult.copyWith(userId: userId);
      
      await _foodTextInputRepository.save(resultWithUserId, analysisId);
      return 'Food analysis saved successfully';
    } catch (e) {
      throw Exception('Saving food analysis failed: ${e.toString()}');
    }
  }

  /// Corrects a food analysis result based on user feedback
  Future<FoodAnalysisResult> correctFoodAnalysis(FoodAnalysisResult previousResult, String userComment) async {
    try {
      return await _foodTextAnalysisService.correctAnalysis(previousResult, userComment);
    } catch (e) {
      throw Exception('Food analysis correction failed: ${e.toString()}');
    }
  }

  /// Retrieves all food analysis results
  Future<List<FoodAnalysisResult>> getAllFoodAnalysis() async {
    try {
      return await _foodTextInputRepository.getAll();
    } catch (e) {
      throw Exception('Fetching food analysis results failed: ${e.toString()}');
    }
  }
}
