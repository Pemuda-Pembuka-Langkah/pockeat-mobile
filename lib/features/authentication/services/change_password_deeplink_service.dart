import 'dart:async';
import 'package:flutter/material.dart';

/// Interface untuk menangani deep link reset password
abstract class ChangePasswordDeepLinkService {
  /// Inisialisasi service
  Future<void> initialize();

  /// Stream untuk mendapatkan initial link
  Stream<Uri?> getInitialLink();

  /// Stream untuk mendapatkan link yang diterima
  Stream<Uri?> onLinkReceived();

  /// Mengecek apakah link adalah link reset password
  bool isChangePasswordLink(Uri link);

  /// Handle link reset password
  Future<bool> handleChangePasswordLink(Uri link);

  /// Dispose resources
  void dispose();
}
