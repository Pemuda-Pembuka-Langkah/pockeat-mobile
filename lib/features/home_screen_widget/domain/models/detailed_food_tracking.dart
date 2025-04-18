import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';

/// Model untuk data tracking makanan yang detail
/// 
/// Berisi informasi SimpleFoodTracking ditambah dengan makronutrien
class DetailedFoodTracking extends SimpleFoodTracking {
  /// Total protein yang sudah dikonsumsi (gram)
  final double currentProtein;
  
  /// Total karbohidrat yang sudah dikonsumsi (gram)
  final double currentCarb;
  
  /// Total lemak yang sudah dikonsumsi (gram)
  final double currentFat;
  
  /// Konstruktor untuk DetailedFoodTracking
  DetailedFoodTracking({
    required super.caloriesNeeded,
    required super.currentCaloriesConsumed,
    required this.currentProtein,
    required this.currentCarb,
    required this.currentFat,
  });
  
  /// Mengkonversi model ke Map untuk disimpan di widget storage
  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      FoodTrackingKey.currentProtein.toStorageKey(): currentProtein,
      FoodTrackingKey.currentCarb.toStorageKey(): currentCarb,
      FoodTrackingKey.currentFat.toStorageKey(): currentFat,
    };
  }
  
  /// Membuat model dari Map yang disimpan di widget storage
  factory DetailedFoodTracking.fromMap(Map<String, dynamic> map) {
    return DetailedFoodTracking(
      caloriesNeeded: map[FoodTrackingKey.caloriesNeeded.toStorageKey()] ?? 0,
      currentCaloriesConsumed: map[FoodTrackingKey.currentCaloriesConsumed.toStorageKey()] ?? 0,
      currentProtein: (map[FoodTrackingKey.currentProtein.toStorageKey()] ?? 0).toDouble(),
      currentCarb: (map[FoodTrackingKey.currentCarb.toStorageKey()] ?? 0).toDouble(),
      currentFat: (map[FoodTrackingKey.currentFat.toStorageKey()] ?? 0).toDouble(),
    );
  }
  
  /// Membuat model dengan nilai default
  factory DetailedFoodTracking.empty() {
    return DetailedFoodTracking(
      caloriesNeeded: 0,
      currentCaloriesConsumed: 0,
      currentProtein: 0,
      currentCarb: 0,
      currentFat: 0,
    );
  }
  
  /// Menghasilkan SimpleFoodTracking dari DetailedFoodTracking
  SimpleFoodTracking toSimpleFoodTracking() {
    return SimpleFoodTracking(
      caloriesNeeded: caloriesNeeded,
      currentCaloriesConsumed: currentCaloriesConsumed,
    );
  }
}