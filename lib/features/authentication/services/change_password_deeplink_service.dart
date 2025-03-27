import 'dart:async';
import 'package:flutter/material.dart';

/// Service untuk menangani deep link reset/change password
abstract class ChangePasswordDeepLinkService {
  /// Initialize the deep link service
  ///
  /// NavigatorKey dibutuhkan untuk melakukan navigasi dari service
  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey});

  /// Mendengarkan deep link saat aplikasi dibuka melalui link (cold start)
  Stream<Uri?> getInitialLink();

  /// Mendengarkan deep link saat aplikasi sudah berjalan (hot start)
  Stream<Uri?> onLinkReceived();

  /// Memeriksa apakah uri adalah link untuk reset/change password
  bool isChangePasswordLink(Uri link);

  /// Menangani deep link untuk reset/change password
  Future<bool> handleChangePasswordLink(Uri link);

  /// Menghentikan semua listener
  void dispose();
}
