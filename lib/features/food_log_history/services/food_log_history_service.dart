// Project imports:
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';

//coverage: ignore-file

/// Interface untuk service Food Log History
///
/// Service ini bertanggung jawab untuk mengambil dan mengelola history log makanan
/// dari berbagai sumber (FoodAnalysisResult dan sumber lainnya di masa depan)
abstract class FoodLogHistoryService {
  /// Mengambil semua history log makanan
  ///
  /// Parameter [limit] untuk membatasi jumlah hasil yang dikembalikan, null berarti tidak ada batasan
  /// Mengembalikan [List<FoodLogHistoryItem>] berisi semua log makanan
  /// dari berbagai sumber, diurutkan berdasarkan timestamp (terbaru dulu)
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<FoodLogHistoryItem>> getAllFoodLogs(String userId, {int? limit});

  /// Mengambil history log makanan berdasarkan tanggal
  ///
  /// Parameter [date] untuk memfilter hasil
  /// Mengembalikan [List<FoodLogHistoryItem>] berisi log pada tanggal tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<FoodLogHistoryItem>> getFoodLogsByDate(
      String userId, DateTime date);

  /// Mengambil history log makanan berdasarkan bulan dan tahun
  ///
  /// Parameter [month] dan [year] untuk memfilter hasil
  /// Mengembalikan [List<FoodLogHistoryItem>] berisi log pada bulan dan tahun tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<FoodLogHistoryItem>> getFoodLogsByMonth(
      String userId, int month, int year);

  /// Mengambil history log makanan berdasarkan tahun
  ///
  /// Parameter [year] untuk memfilter hasil
  /// Mengembalikan [List<FoodLogHistoryItem>] berisi log pada tahun tersebut
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<FoodLogHistoryItem>> getFoodLogsByYear(String userId, int year);

  /// Mencari history log makanan berdasarkan query
  ///
  /// Parameter [query] untuk mencari log makanan yang sesuai
  /// Mengembalikan [List<FoodLogHistoryItem>] berisi log yang sesuai dengan query
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<FoodLogHistoryItem>> searchFoodLogs(String userId, String query);

  /// Menghitung jumlah hari berturut-turut pengguna mencatat makanan
  ///
  /// Parameter [userId] untuk mengidentifikasi pengguna
  /// Mengembalikan [int] jumlah hari streak pengguna
  /// Mengembalikan 0 jika terjadi error atau tidak ada streak
  /// Batas maksimum streak yang terdeteksi adalah 100 hari
  Future<int> getFoodStreakDays(String userId);
}
