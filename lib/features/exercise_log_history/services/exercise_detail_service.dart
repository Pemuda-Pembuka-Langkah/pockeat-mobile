import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';

/// Service untuk mengambil detail latihan olahraga berdasarkan tipe
///
/// Service ini bertanggung jawab untuk mengambil detail dari berbagai tipe latihan
/// seperti smart exercise dan cardio (running, cycling, swimming)
abstract class ExerciseDetailService {
  /// Mengambil detail dari aktivitas smart exercise
  ///
  /// [id] adalah ID dari smart exercise yang ingin diambil
  /// Mengembalikan objek smart exercise log jika ditemukan, null jika tidak
  Future<dynamic> getSmartExerciseDetail(String id);

  /// Mengambil detail dari aktivitas cardio dengan tipe generik
  ///
  /// [id] adalah ID dari cardio activity yang ingin diambil
  /// Mengembalikan objek T yang extends CardioActivity
  /// Throws exception jika tipe tidak sesuai
  Future<T?> getCardioActivityDetail<T extends CardioActivity>(String id);

  /// Mendapatkan tipe cardio (running, cycling, swimming) dari ExerciseLogHistoryItem
  ///
  /// Berguna untuk menentukan halaman detail mana yang harus ditampilkan
  /// [exerciseItem] adalah item exercise log history yang ingin dicek tipenya
  /// Return String yang merepresentasikan tipe ('running', 'cycling', 'swimming', 'unknown')
  String getCardioTypeFromHistoryItem(ExerciseLogHistoryItem exerciseItem);
  
  /// Mendapatkan tipe aktivitas yang sebenarnya dari sebuah ID aktivitas
  /// 
  /// Method ini akan memeriksa repository yang sesuai untuk menentukan tipe aktivitas yang sebenarnya
  /// [id] adalah ID dari aktivitas
  /// [basicType] adalah tipe dasar (smart_exercise atau cardio)
  /// Return Future<String> yang merepresentasikan tipe sebenarnya ('running', 'cycling', 'swimming', 'smart_exercise')
  Future<String> getActualActivityType(String id, String basicType);
}
