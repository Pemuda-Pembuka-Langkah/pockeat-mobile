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
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseAnalysisResult>] berisi semua hasil analisis
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseAnalysisResult>> getAllAnalysisResults({int? limit});
  
  /// Mengambil hasil analisis berdasarkan tanggal
  /// 
  /// Parameter [date] untuk memfilter hasil berdasarkan tanggal spesifik
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseAnalysisResult>] berisi hasil analisis pada tanggal tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByDate(DateTime date, {int? limit});
  
  /// Mengambil hasil analisis berdasarkan bulan dan tahun
  /// 
  /// Parameter [month] (1-12) dan [year] untuk memfilter hasil
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseAnalysisResult>] berisi hasil analisis pada bulan dan tahun tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByMonth(int month, int year, {int? limit});
  
  /// Mengambil hasil analisis berdasarkan tahun
  /// 
  /// Parameter [year] untuk memfilter hasil
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseAnalysisResult>] berisi hasil analisis pada tahun tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByYear(int year, {int? limit});
}
