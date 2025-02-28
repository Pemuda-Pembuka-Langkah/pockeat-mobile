// Exception untuk error saat penyimpanan atau pengambilan data
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

abstract class SmartExerciseLogRepository {
  /// Menyimpan hasil analisis olahraga ke database
  ///
  /// Mengembalikan [String] berupa id dari hasil yang disimpan
  /// Throws [Exception] jika terjadi error saat penyimpanan
  Future<String> saveAnalysisResult(ExerciseAnalysisResult result);

  /// Mengambil hasil analisis berdasarkan ID
  ///
  /// Mengembalikan [ExerciseAnalysisResult] jika ditemukan, null jika tidak ada
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<ExerciseAnalysisResult?> getAnalysisResultFromId(String id);

  /// Mengambil semua hasil analisis
  ///
  /// Mengembalikan [List<AnalysisResult>] berisi semua hasil analisis
  /// Throws [StorageException] jika terjadi error saat pengambilan data
  Future<List<ExerciseAnalysisResult>> getAllAnalysisResults();
}
