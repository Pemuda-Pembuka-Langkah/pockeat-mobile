/// Service untuk menangani deep link ke aplikasi
abstract class DeepLinkService {
  /// Inisialisasi service dan konfigurasi listener
  Future<void> initialize();

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
