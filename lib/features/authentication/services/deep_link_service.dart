import 'dart:async';
import 'package:flutter/material.dart';

/// Service untuk menangani semua jenis deep link ke aplikasi
/// Ini adalah facade untuk service-service spesifik seperti:
/// - EmailVerificationDeepLinkService
/// - ChangePasswordDeepLinkService
abstract class DeepLinkService {
  /// Initialize the deep link service
  ///
  /// NavigatorKey dibutuhkan untuk melakukan navigasi dari service
  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey});

  /// Mendengarkan deep link saat aplikasi dibuka melalui link (cold start)
  Stream<Uri?> getInitialLink();

  /// Mendengarkan deep link saat aplikasi sudah berjalan (hot start)
  Stream<Uri?> onLinkReceived();

  /// Menangani semua jenis deep link
  ///
  /// Method ini akan mendelegasikan ke service yang sesuai berdasarkan jenis linknya
  Future<bool> handleDeepLink(Uri link);

  /// Menghentikan semua listener
  void dispose();
}
