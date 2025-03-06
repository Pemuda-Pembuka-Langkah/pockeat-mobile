import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';

/// Interface untuk repository Exercise Log History
/// 
/// Repository ini bertanggung jawab untuk mengambil dan mengelola history log olahraga
/// dari berbagai sumber (SmartExerciseLog, WeightliftingLog, CardioLog)
abstract class ExerciseLogHistoryRepository {
  /// Mengambil semua history log olahraga
  /// 
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi semua log olahraga
  /// dari berbagai sumber, diurutkan berdasarkan timestamp (terbaru dulu)
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getAllExerciseLogs({int? limit});

  /// Mengambil history log olahraga berdasarkan tanggal
  /// 
  /// Parameter [date] untuk memfilter hasil berdasarkan tanggal spesifik
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi log pada tanggal tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByDate(DateTime date, {int? limit});
  
  /// Mengambil history log olahraga berdasarkan bulan dan tahun
  /// 
  /// Parameter [month] (1-12) dan [year] untuk memfilter hasil
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi log pada bulan dan tahun tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByMonth(int month, int year, {int? limit});
  
  /// Mengambil history log olahraga berdasarkan tahun
  /// 
  /// Parameter [year] untuk memfilter hasil
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi log pada tahun tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByYear(int year, {int? limit});

  /// Mengambil history log olahraga berdasarkan kategori aktivitas
  /// 
  /// Parameter [activityCategory] untuk memfilter hasil berdasarkan kategori aktivitas
  /// (misalnya 'smart_exercise', 'weightlifting', 'cardio')
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi log dengan kategori tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByActivityCategory(String activityCategory, {int? limit});
}
