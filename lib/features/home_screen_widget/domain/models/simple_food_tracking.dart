import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';

/// Model untuk data tracking makanan yang sederhana
/// 
/// Hanya berisi informasi tentang kalori yang dibutuhkan dan dikonsumsi
class SimpleFoodTracking {
  /// Total kalori yang dibutuhkan per hari
  final int caloriesNeeded;
  
  /// Total kalori yang sudah dikonsumsi saat ini
  final int currentCaloriesConsumed;
  
  /// Konstruktor untuk SimpleFoodTracking
  SimpleFoodTracking({
    required this.caloriesNeeded,
    required this.currentCaloriesConsumed,
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
      FoodTrackingKey.currentCaloriesConsumed.toStorageKey(): currentCaloriesConsumed,
    };
  }
  
  /// Membuat model dari Map yang disimpan di widget storage
  factory SimpleFoodTracking.fromMap(Map<String, dynamic> map) {
    return SimpleFoodTracking(
      caloriesNeeded: map[FoodTrackingKey.caloriesNeeded.toStorageKey()] ?? 0,
      currentCaloriesConsumed: map[FoodTrackingKey.currentCaloriesConsumed.toStorageKey()] ?? 0,
    );
  }
  
  /// Membuat model dengan nilai default
  factory SimpleFoodTracking.empty() {
    return SimpleFoodTracking(
      caloriesNeeded: 0,
      currentCaloriesConsumed: 0,
    );
  }
}