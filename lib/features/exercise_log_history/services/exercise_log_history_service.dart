import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';

/// Interface untuk repository Exercise Log History
///
/// Repository ini bertanggung jawab untuk mengambil dan mengelola history log olahraga
/// dari berbagai sumber (SmartExerciseLog, WeightliftingLog, CardioLog)
abstract class ExerciseLogHistoryService {
  /// Mengambil semua history log olahraga untuk user tertentu
  ///
  /// Parameter [userId] ID pengguna yang datanya ingin diambil
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi semua log olahraga
  /// dari berbagai sumber, diurutkan berdasarkan timestamp (terbaru dulu)
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getAllExerciseLogs(String userId, {int? limit});

  /// Mengambil history log olahraga berdasarkan tanggal
  ///
  /// Parameter [userId] ID pengguna yang datanya ingin diambil
  /// Parameter [date] untuk memfilter hasil
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi log pada tanggal tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByDate(String userId, DateTime date);

  /// Mengambil history log olahraga berdasarkan bulan dan tahun
  ///
  /// Parameter [userId] ID pengguna yang datanya ingin diambil
  /// Parameter [month] dan [year] untuk memfilter hasil
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi log pada bulan dan tahun tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByMonth(
      String userId, int month, int year);

  /// Mengambil history log olahraga berdasarkan tahun
  ///
  /// Parameter [userId] ID pengguna yang datanya ingin diambil
  /// Parameter [year] untuk memfilter hasil
  /// Mengembalikan [List<ExerciseLogHistoryItem>] berisi log pada tahun tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<ExerciseLogHistoryItem>> getExerciseLogsByYear(String userId, int year);
}