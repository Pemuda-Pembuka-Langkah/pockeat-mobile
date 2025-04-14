import 'package:pockeat/features/authentication/domain/model/user_model.dart';

/// Service untuk mengelola pelaporan bug melalui Instabug
/// 
/// Catatan: Inisialisasi Instabug dilakukan langsung di main.dart
abstract class BugReportService {
  /// Mengatur data pengguna untuk konteks bug reports
  /// 
  /// Parameter:
  /// - [user]: Model pengguna yang sedang aktif
  /// 
  /// Returns: `true` jika data pengguna berhasil diatur, `false` jika gagal
  Future<bool> setUserData(UserModel user);
  
  /// Menghapus data pengguna dari sistem pelaporan
  /// 
  /// Harus dipanggil saat logout untuk menjaga privasi pengguna
  /// 
  /// Returns: `true` jika data pengguna berhasil dihapus, `false` jika gagal
  Future<bool> clearUserData();
}
