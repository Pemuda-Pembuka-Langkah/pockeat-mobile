// lib/features/home_screen_widget/controllers/food_tracking_client_controller.dart

import 'package:pockeat/features/authentication/domain/model/user_model.dart';

/// Interface controller client untuk food tracking yang berinteraksi dengan UI
/// dan mendelegasikan operasi ke controller spesifik.
///
/// Berbeda dengan FoodTrackingWidgetController yang fokus pada interaksi dengan widget,
/// interface ini didesain untuk client yang mengelola keseluruhan fitur widget tracking.
abstract class FoodTrackingClientController {
  /// Inisialisasi controller
  ///
  /// Menyiapkan controller dan semua resources yang dibutuhkan
  /// @throws WidgetInitializationException jika gagal inisialisasi
  Future<void> initialize();

  /// Proses perubahan status user (login/logout)
  ///
  /// Dipanggil ketika user login atau logout untuk update widget
  /// @throws WidgetUpdateException jika gagal update
  Future<void> processUserStatusChange(UserModel? user);

  /// Update periodik untuk semua widget
  ///
  /// Dipanggil secara periodik untuk memperbarui widget
  /// @throws WidgetUpdateException jika gagal update
  Future<void> processPeriodicUpdate();

  /// Membersihkan data dan resources saat aplikasi reset
  ///
  /// @throws WidgetCleanupException jika gagal membersihkan data
  Future<void> cleanup();

  /// Hentikan semua proses periodik
  ///
  /// Dipanggil saat aplikasi ditutup
  Future<void> stopPeriodicUpdates();

  /// Mulai mendengarkan perubahan status user (login/logout)
  ///
  /// Berlangganan ke stream perubahan auth state dari LoginService
  /// dan otomatis memanggil processUserStatusChange saat terjadi perubahan
  /// @throws WidgetInitializationException jika gagal setup listener
  Future<void> startListeningToUserChanges();

  /// Paksa update widget secara manual
  ///
  /// Berguna untuk komponen eksternal yang perlu memperbarui widget
  /// setelah perubahan data, misalnya setelah menambahkan food log
  /// @throws WidgetUpdateException jika gagal update
  Future<void> forceUpdate();
}
