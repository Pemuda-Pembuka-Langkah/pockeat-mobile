import 'dart:async';

/// Interface untuk menangani deep link verifikasi email
abstract class EmailVerificationDeepLinkService {
  /// Inisialisasi service
  Future<void> initialize();

  /// Stream untuk mendapatkan initial link
  Stream<Uri?> getInitialLink();

  /// Stream untuk mendapatkan link yang diterima
  Stream<Uri?> onLinkReceived();

  /// Mengecek apakah link adalah link verifikasi email
  bool isEmailVerificationLink(Uri link);

  /// Handle link verifikasi email
  Future<bool> handleEmailVerificationLink(Uri link);

  /// Dispose resources
  void dispose();
}
