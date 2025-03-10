import 'dart:io';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_scan_ai/domain/repositories/food_scan_repository.dart';
import 'package:uuid/uuid.dart';

class FoodScanPhotoService {
  final FoodImageAnalysisService _foodImageAnalysisService = getIt<FoodImageAnalysisService>();
  final Uuid _uuid = Uuid();

  final FoodScanRepository _foodScanRepository = getIt<FoodScanRepository>();

  FoodScanPhotoService();

  /// Menganalisis foto makanan dan mengembalikan hasil analisis
  /// 
  /// [photo] adalah file gambar yang akan dianalisis
  /// Mengembalikan [FoodAnalysisResult] yang berisi informasi makanan
  Future<FoodAnalysisResult> analyzeFoodPhoto(File photo) async {
    try {
      final result = await _foodImageAnalysisService.analyze(photo);
      return result;
    } catch (e) {
      throw Exception('Gagal menganalisis foto makanan: ${e.toString()}');
    }
  }

  /// Menyimpan hasil analisis makanan ke dalam database
  /// 
  /// [analysisResult] adalah hasil analisis makanan yang akan disimpan
  /// Mengembalikan pesan sukses jika berhasil menyimpan data
  Future<String> saveFoodAnalysis(FoodAnalysisResult analysisResult) async {
    await _foodScanRepository.save(analysisResult, _uuid.v4());
    return 'Successfully saved food analysis';
  }
}
