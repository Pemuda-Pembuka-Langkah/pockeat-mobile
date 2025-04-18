// lib/features/home_screen_widget/controllers/food_tracking_client_controller.dart

import 'package:flutter/material.dart';
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
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey);
  
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
}
