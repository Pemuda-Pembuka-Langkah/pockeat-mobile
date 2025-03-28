import 'package:firebase_auth/firebase_auth.dart';

/// Service untuk menangani proses perubahan password
abstract class ChangePasswordService {
  /// Mengubah password user yang sedang login
  ///
  /// Memerlukan [newPassword] sebagai password baru dan
  /// [newPasswordConfirmation] untuk konfirmasi password baru
  ///
  /// Throws [ArgumentError] jika [newPassword] tidak sama dengan [newPasswordConfirmation]
  ///
  /// Mengembalikan [User] jika berhasil
  ///
  /// Throws [FirebaseAuthException] jika terjadi kesalahan pada authentikasi
  Future<User> changePassword({
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<void> sendPasswordResetEmail({required String email});
}
