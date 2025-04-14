/// Service untuk menangani proses logout dari aplikasi
abstract class LogoutService {
  /// Melakukan logout dari aplikasi
  ///
  /// Akan membersihkan sesi login pengguna
  /// dan melepaskan akses terhadap resource yang bersifat private
  ///
  /// Mengembalikan [true] jika berhasil logout, [false] jika gagal
  Future<bool> logout();
}
