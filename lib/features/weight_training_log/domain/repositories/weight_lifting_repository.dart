import '../models/weight_lifting.dart';

/// Repository untuk mengakses data latihan beban
abstract class WeightLiftingRepository {
  /// Menyimpan latihan beban ke database
  ///
  /// Mengembalikan [String] berupa id dari hasil yang disimpan
  /// Throws [Exception] jika terjadi error saat penyimpanan
  Future<String> saveExercise(WeightLifting exercise);
  
  /// Mengambil latihan beban berdasarkan ID
  ///
  /// Mengembalikan [WeightLifting] jika ditemukan, null jika tidak ada
  Future<WeightLifting?> getExerciseById(String id);
  
  /// Mengambil semua latihan beban
  Future<List<WeightLifting>> getAllExercises();
  
  /// Mengambil latihan beban berdasarkan bagian tubuh
  Future<List<WeightLifting>> getExercisesByBodyPart(String bodyPart);
  
  /// Menghapus latihan beban berdasarkan ID
  ///
  /// Mengembalikan [bool] true jika berhasil dihapus
  Future<bool> deleteExercise(String id);
  
  /// Mengambil latihan beban pada tanggal tertentu
  Future<List<WeightLifting>> filterByDate(DateTime date);
  
  /// Mengambil latihan beban pada bulan dan tahun tertentu
  Future<List<WeightLifting>> filterByMonth(int month, int year);

  /// Mengambil latihan beban pada tahun tertentu
  Future<List<WeightLifting>> filterByYear(int year);
  
  /// Mengambil latihan beban dengan jumlah terbatas
  Future<List<WeightLifting>> getExercisesWithLimit(int limit);
  
  /// Mengambil daftar kategori latihan yang tersedia
  List<String> getExerciseCategories();
  
  /// Mengambil daftar latihan berdasarkan kategori
  Map<String, double> getExercisesByCategoryName(String category);
  
  /// Mengambil nilai MET untuk latihan tertentu
  double getExerciseMETValue(String exerciseName, [String? category]);
  
  /// Mengambil latihan beban untuk pengguna tertentu
  ///
  /// Mengembalikan [List<WeightLifting>] berisi latihan beban untuk pengguna dengan ID tertentu
  /// Throws [Exception] jika terjadi error saat pengambilan data
  Future<List<WeightLifting>> getExercisesByUser(String userId);
}