// Exception untuk error saat penyimpanan atau pengambilan data
import 'package:pockeat/features/smart_exercise_log/domain/models/analysis_result.dart';

class StorageException implements Exception {
  final String message;
  
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}

abstract class SmartExerciseLogRepository {
  /// Menyimpan hasil analisis olahraga ke database
  /// 
  /// Mengembalikan [String] berupa id dari hasil yang disimpan
  /// Throws [StorageException] jika terjadi error saat penyimpanan
  Future<String> saveAnalysisResult(AnalysisResult result);
  
  /// Mengambil hasil analisis berdasarkan ID
  /// 
  /// Mengembalikan [AnalysisResult] jika ditemukan, null jika tidak ada
  /// Throws [StorageException] jika terjadi error saat pengambilan data
  Future<AnalysisResult?> getAnalysisResultFromId(String id);
  
  /// Mengambil semua hasil analisis
  /// 
  /// Mengembalikan [List<AnalysisResult>] berisi semua hasil analisis
  /// Throws [StorageException] jika terjadi error saat pengambilan data
  Future<List<AnalysisResult>> getAllAnalysisResults();
}