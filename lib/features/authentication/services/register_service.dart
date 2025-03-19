import 'package:firebase_auth/firebase_auth.dart';

/// Hasil dari operasi pendaftaran
enum RegisterResult {
  success,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  operationNotAllowed,
  unknown,
}

/// Service untuk pendaftaran pengguna
abstract class RegisterService {
  /// Mendaftarkan pengguna baru dengan email dan password
  Future<RegisterResult> register({
    required String email,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
    String? displayName,
    DateTime? birthDate,
    String? gender,
  });

  /// Mengirim email verifikasi
  Future<bool> sendEmailVerification();

  /// Mengirim ulang email verifikasi
  Future<bool> resendEmailVerification();

  /// Memeriksa status verifikasi email saat ini
  Future<bool> isEmailVerified();

  /// Stream yang memberikan update real-time tentang status verifikasi email
  Stream<bool> watchEmailVerificationStatus();

  /// Memperbarui profil pengguna
  Future<bool> updateUserProfile({
    String? displayName,
    DateTime? birthDate,
    String? gender,
  });
}
