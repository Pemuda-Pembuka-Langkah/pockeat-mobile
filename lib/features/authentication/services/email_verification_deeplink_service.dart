import 'dart:async';
import 'package:flutter/material.dart';

/// Service untuk menangani deep link ke aplikasi
abstract class EmailVerificationDeepLinkService {
  /// Initialize the deep link service
  ///
  /// NavigatorKey dibutuhkan untuk melakukan navigasi dari service
  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey});

  /// Mendengarkan deep link saat aplikasi dibuka melalui link (cold start)
  Stream<Uri?> getInitialLink();

  /// Mendengarkan deep link saat aplikasi sudah berjalan (hot start)
  Stream<Uri?> onLinkReceived();

  /// Menangani deep link untuk verifikasi email
  Future<bool> handleEmailVerificationLink(Uri link);

  /// Mengecek apakah deep link adalah link verifikasi email
  bool isEmailVerificationLink(Uri link);

  /// Menghentikan semua listener
  void dispose();
}
