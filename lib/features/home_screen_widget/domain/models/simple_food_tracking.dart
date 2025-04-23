// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';

/// Model untuk data tracking makanan yang sederhana
///
/// Hanya berisi informasi tentang kalori yang dibutuhkan dan dikonsumsi
class SimpleFoodTracking {
  /// Total kalori yang dibutuhkan per hari
  final int caloriesNeeded;

  /// Total kalori yang sudah dikonsumsi saat ini
  final int currentCaloriesConsumed;

  /// ID pengguna untuk mengidentifikasi data widget
  final String? userId;

  /// Konstruktor untuk SimpleFoodTracking
  SimpleFoodTracking({
    required this.caloriesNeeded,
    required this.currentCaloriesConsumed,
    this.userId,
  });

  /// Persentase kalori yang sudah dikonsumsi
  double get percentageConsumed =>
      caloriesNeeded > 0 ? (currentCaloriesConsumed / caloriesNeeded) * 100 : 0;

  /// Kalori yang tersisa untuk dikonsumsi
  int get remainingCalories => caloriesNeeded - currentCaloriesConsumed;

  /// Mengkonversi model ke Map untuk disimpan di widget storage
  Map<String, dynamic> toMap() {
    return {
      FoodTrackingKey.caloriesNeeded.toStorageKey(): caloriesNeeded,
      FoodTrackingKey.currentCaloriesConsumed.toStorageKey():
          currentCaloriesConsumed,
      FoodTrackingKey.userId.toStorageKey(): userId,
    };
  }

  /// Membuat model dari Map yang disimpan di widget storage
  factory SimpleFoodTracking.fromMap(Map<String, dynamic> map) {
    // Ambil userId dengan tipe yang benar
    final userIdKey = FoodTrackingKey.userId.toStorageKey();
    final String? userId =
        map.containsKey(userIdKey) ? map[userIdKey] as String? : null;

    // Pastikan kalori dikonversi ke int
    final caloriesNeededKey = FoodTrackingKey.caloriesNeeded.toStorageKey();
    final calConsumedKey =
        FoodTrackingKey.currentCaloriesConsumed.toStorageKey();

    // Handle berbagai tipe data numerik dan konversi ke int
    final caloriesNeeded = map.containsKey(caloriesNeededKey)
        ? (map[caloriesNeededKey] is int
            ? map[caloriesNeededKey] as int
            : (map[caloriesNeededKey] as num?)?.toInt() ?? 0)
        : 0;

    final currentCaloriesConsumed = map.containsKey(calConsumedKey)
        ? (map[calConsumedKey] is int
            ? map[calConsumedKey] as int
            : (map[calConsumedKey] as num?)?.toInt() ?? 0)
        : 0;

    return SimpleFoodTracking(
      caloriesNeeded: caloriesNeeded,
      currentCaloriesConsumed: currentCaloriesConsumed,
      userId: userId,
    );
  }

  /// Membuat model dengan nilai default
  factory SimpleFoodTracking.empty() {
    return SimpleFoodTracking(
      caloriesNeeded: 0,
      currentCaloriesConsumed: 0,
      userId: null,
    );
  }
}
