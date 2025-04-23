// Project imports:
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
    super.userId,
  });

  /// Mengkonversi model ke Map untuk disimpan di widget storage
  @override
  Map<String, dynamic> toMap() {
    return {
      FoodTrackingKey.caloriesNeeded.toStorageKey(): caloriesNeeded,
      FoodTrackingKey.currentCaloriesConsumed.toStorageKey():
          currentCaloriesConsumed,
      FoodTrackingKey.userId.toStorageKey(): userId,
      FoodTrackingKey.currentProtein.toStorageKey(): currentProtein,
      FoodTrackingKey.currentCarb.toStorageKey(): currentCarb,
      FoodTrackingKey.currentFat.toStorageKey(): currentFat,
    };
  }

  /// Membuat model dari Map yang disimpan di widget storage
  factory DetailedFoodTracking.fromMap(Map<String, dynamic> map) {
    // Ambil userId dengan tipe yang benar
    final userIdKey = FoodTrackingKey.userId.toStorageKey();
    final String? userId =
        map.containsKey(userIdKey) ? map[userIdKey] as String? : null;

    // Extract key constants
    final caloriesNeededKey = FoodTrackingKey.caloriesNeeded.toStorageKey();
    final calConsumedKey =
        FoodTrackingKey.currentCaloriesConsumed.toStorageKey();
    final proteinKey = FoodTrackingKey.currentProtein.toStorageKey();
    final carbKey = FoodTrackingKey.currentCarb.toStorageKey();
    final fatKey = FoodTrackingKey.currentFat.toStorageKey();

    // Handle berbagai tipe data numerik dan konversi ke tipe yang sesuai
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

    // Convert makronutrien ke double secara aman
    final currentProtein = map.containsKey(proteinKey)
        ? (map[proteinKey] is double
            ? map[proteinKey] as double
            : (map[proteinKey] as num?)?.toDouble() ?? 0.0)
        : 0.0;

    final currentCarb = map.containsKey(carbKey)
        ? (map[carbKey] is double
            ? map[carbKey] as double
            : (map[carbKey] as num?)?.toDouble() ?? 0.0)
        : 0.0;

    final currentFat = map.containsKey(fatKey)
        ? (map[fatKey] is double
            ? map[fatKey] as double
            : (map[fatKey] as num?)?.toDouble() ?? 0.0)
        : 0.0;

    return DetailedFoodTracking(
      caloriesNeeded: caloriesNeeded,
      currentCaloriesConsumed: currentCaloriesConsumed,
      currentProtein: currentProtein,
      currentCarb: currentCarb,
      currentFat: currentFat,
      userId: userId,
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
      userId: null,
    );
  }

  /// Menghasilkan SimpleFoodTracking dari DetailedFoodTracking
  SimpleFoodTracking toSimpleFoodTracking() {
    return SimpleFoodTracking(
      caloriesNeeded: caloriesNeeded,
      currentCaloriesConsumed: currentCaloriesConsumed,
      userId: userId,
    );
  }
}
