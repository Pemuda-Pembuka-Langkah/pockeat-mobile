// Dart imports:
import 'dart:io';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

/// Service untuk mengelola profil pengguna
abstract class ProfileService {
  /// Mendapatkan data user saat ini
  Future<UserModel?> getCurrentUser();

  /// Memperbarui profil pengguna, kecuali gender dan birthDate
  /// yang tidak dapat diubah melalui halaman edit profil
  ///
  /// Parameter:
  /// - [displayName]: Nama baru pengguna
  /// - [photoURL]: URL foto profil baru pengguna
  ///
  /// Mengembalikan [true] jika berhasil, [false] jika gagal
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// Mengirim email verifikasi ke email pengguna
  ///
  /// Mengembalikan [true] jika berhasil, [false] jika gagal
  Future<bool> sendEmailVerification();

  /// Mengupload gambar profil ke Firebase Storage
  ///
  /// Parameter:
  /// - [imageFile]: File gambar yang akan diupload
  ///
  /// Mengembalikan URL gambar jika berhasil, null jika gagal
  Future<String?> uploadProfileImage(File imageFile);
}
