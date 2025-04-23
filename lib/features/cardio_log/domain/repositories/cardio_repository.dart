import '../models/cardio_activity.dart';

/// Repository untuk mengakses data aktivitas kardio
abstract class CardioRepository {
  /// Menyimpan aktivitas kardio ke database
  ///
  /// Mengembalikan [String] berupa id dari hasil yang disimpan
  /// Throws [Exception] jika terjadi error saat penyimpanan
  Future<String> saveCardioActivity(CardioActivity activity);

  /// Mengambil aktivitas kardio berdasarkan ID
  ///
  /// Mengembalikan [CardioActivity] jika ditemukan, null jika tidak ada
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<CardioActivity?> getCardioActivityById(String id);

  /// Mengambil semua aktivitas kardio
  ///
  /// Mengembalikan [List<CardioActivity>] berisi semua aktivitas kardio
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<CardioActivity>> getAllCardioActivities();

  /// Mengambil semua aktivitas kardio berdasarkan tipe
  ///
  /// Mengembalikan [List<CardioActivity>] berisi aktivitas kardio dengan tipe tertentu
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<CardioActivity>> getCardioActivitiesByType(CardioType type);

  /// Menghapus aktivitas kardio berdasarkan ID
  ///
  /// Mengembalikan [bool] true jika berhasil dihapus
  /// Throws [Exception] jika terjadi error saat penghapusan
  Future<bool> deleteCardioActivity(String id);

  /// Mengambil aktivitas kardio pada tanggal tertentu
  ///
  /// Mengembalikan [List<CardioActivity>] berisi aktivitas kardio pada tanggal tertentu
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<CardioActivity>> filterByDate(DateTime date);

  /// Mengambil aktivitas kardio pada bulan dan tahun tertentu
  ///
  /// Mengembalikan [List<CardioActivity>] berisi aktivitas kardio pada bulan dan tahun tertentu
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<CardioActivity>> filterByMonth(int month, int year);

  /// Mengambil aktivitas kardio pada tahun tertentu
  ///
  /// Mengembalikan [List<CardioActivity>] berisi aktivitas kardio pada tahun tertentu
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<CardioActivity>> filterByYear(int year);

  /// Mengambil aktivitas kardio dengan jumlah terbatas
  ///
  /// Mengembalikan [List<CardioActivity>] berisi aktivitas kardio dengan jumlah terbatas
  /// Parameter [limit] menentukan jumlah maksimum data yang diambil
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<CardioActivity>> getActivitiesWithLimit(int limit);

  /// Get activities for a specific user
  Future<List<CardioActivity>> getActivitiesByUser(String userId);
}
