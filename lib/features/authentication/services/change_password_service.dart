import 'package:firebase_auth/firebase_auth.dart';

/// Service untuk menangani proses perubahan password
abstract class ChangePasswordService {
  /// Mengubah password user yang sedang login
  ///
  /// Memerlukan [newPassword] sebagai password baru dan
  /// [newPasswordConfirmation] untuk konfirmasi password baru
  ///
  /// Parameter opsional [currentPassword] digunakan untuk re-autentikasi
  /// jika Firebase memerlukan login ulang
  ///
  /// Parameter opsional [email] digunakan bersama [currentPassword] untuk re-autentikasi
  ///
  /// Throws [ArgumentError] jika [newPassword] tidak sama dengan [newPasswordConfirmation]
  ///
  /// Mengembalikan [User] jika berhasil
  ///
  /// Throws [FirebaseAuthException] jika terjadi kesalahan pada authentikasi
  Future<User> changePassword({
    required String newPassword,
    required String newPasswordConfirmation,
    String? currentPassword,
    String? email,
  });

  /// Mengirim email reset password ke alamat [email]
  ///
  /// Throws [FirebaseAuthException] jika terjadi kesalahan pada proses pengiriman email
  Future<void> sendPasswordResetEmail({required String email});

  /// Konfirmasi reset password menggunakan oobCode dari email
  ///
  /// Memerlukan [code] dari email dan [newPassword] sebagai password baru
  ///
  /// Throws [FirebaseAuthException] jika terjadi kesalahan pada proses konfirmasi
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  });
}
