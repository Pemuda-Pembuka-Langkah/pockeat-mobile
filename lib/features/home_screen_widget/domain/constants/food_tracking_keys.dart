/// Kunci yang digunakan untuk menyimpan dan mengambil data widget food tracking
enum FoodTrackingKey {
  /// Total kalori yang dibutuhkan per hari
  caloriesNeeded,
  
  /// Total kalori yang sudah dikonsumsi
  currentCaloriesConsumed,
  
  /// Total protein yang sudah dikonsumsi (gram)
  currentProtein,
  
  /// Total karbohidrat yang sudah dikonsumsi (gram)
  currentCarb,
  
  /// Total lemak yang sudah dikonsumsi (gram)
  currentFat,
  
  /// ID pengguna yang digunakan untuk identifikasi
  userId;
  
  /// Mengembalikan string value dari enum
  String get value => toString().split('.').last;
}

/// Ekstensi untuk memudahkan konversi FoodTrackingKey
extension FoodTrackingKeyExtension on FoodTrackingKey {
  /// Konversi ke string key yang digunakan di storage
  String toStorageKey() => value;
}
