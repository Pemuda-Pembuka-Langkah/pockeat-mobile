/// Jenis event yang dapat dipicu oleh food widget
enum FoodWidgetEventType {
  /// Widget diklik oleh pengguna
  clicked,
  
  /// Pengguna meminta pencatatan cepat makanan
  quicklog,
  
  /// Permintaan refresh data widget
  refresh,
  
  /// Event lainnya yang tidak terkategorikan
  other;
}
