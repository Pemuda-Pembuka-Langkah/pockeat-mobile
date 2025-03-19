import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

/// Repository untuk manajemen data pengguna
abstract class UserRepository {
  /// Mendapatkan user saat ini (yang sedang login)
  Future<UserModel?> getCurrentUser();

  /// Mendapatkan data user berdasarkan ID
  Future<UserModel?> getUserById(String userId);

  /// Menyimpan/memperbarui data user
  Future<void> saveUser(UserModel user);

  /// Memperbarui data profil user
  Future<bool> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoURL,
    String? gender,
    DateTime? birthDate,
  });

  /// Memeriksa apakah user dengan email tertentu sudah ada
  Future<bool> isEmailAlreadyRegistered(String email);

  /// Memperbarui status verifikasi email user
  Future<void> updateEmailVerificationStatus(String userId, bool isVerified);

  /// Me-listen perubahan data user (untuk UI reaktif)
  Stream<UserModel?> userStream(String userId);

  /// Me-listen perubahan user yang sedang login
  Stream<UserModel?> currentUserStream();
}

