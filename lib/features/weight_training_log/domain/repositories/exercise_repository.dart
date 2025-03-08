import '../models/exercise.dart';

/// Repository untuk mengakses data latihan beban
abstract class ExerciseRepository {
  /// Menyimpan latihan beban ke database
  ///
  /// Mengembalikan [String] berupa id dari hasil yang disimpan
  /// Throws [Exception] jika terjadi error saat penyimpanan
  Future<String> saveExercise(Exercise exercise);
  
  /// Mengambil latihan beban berdasarkan ID
  ///
  /// Mengembalikan [Exercise] jika ditemukan, null jika tidak ada
  Future<Exercise?> getExerciseById(String id);
  
  /// Mengambil semua latihan beban
  Future<List<Exercise>> getAllExercises();
  
  /// Mengambil latihan beban berdasarkan bagian tubuh
  Future<List<Exercise>> getExercisesByBodyPart(String bodyPart);
  
  /// Menghapus latihan beban berdasarkan ID
  ///
  /// Mengembalikan [bool] true jika berhasil dihapus
  Future<bool> deleteExercise(String id);
  
  /// Mengambil latihan beban pada tanggal tertentu
  Future<List<Exercise>> filterByDate(DateTime date);
  
  /// Mengambil latihan beban pada bulan dan tahun tertentu
  Future<List<Exercise>> filterByMonth(int month, int year);
  
  /// Mengambil latihan beban dengan jumlah terbatas
  Future<List<Exercise>> getExercisesWithLimit(int limit);
  
  /// Mengambil daftar kategori latihan yang tersedia
  List<String> getExerciseCategories();
  
  /// Mengambil daftar latihan berdasarkan kategori
  Map<String, double> getExercisesByCategoryName(String category);
  
  /// Mengambil nilai MET untuk latihan tertentu
  double getExerciseMETValue(String exerciseName, [String? category]);
}