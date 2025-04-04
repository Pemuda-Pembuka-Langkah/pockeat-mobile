import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

/// Service untuk menangani proses login
abstract class LoginService {
  /// Menginisialisasi service dan mulai listening stream current user
  ///
  /// Parameter [navigatorKey] digunakan untuk navigasi otomatis
  /// ke halaman login jika user tidak terautentikasi
  ///
  /// Return stream dari user yang sedang login
  Stream<UserModel?> initialize(GlobalKey<NavigatorState> navigatorKey);

  /// Login menggunakan email dan password
  ///
  /// Mengembalikan [UserCredential] jika berhasil
  ///
  /// Throws [FirebaseAuthException] jika terjadi kesalahan pada authentikasi
  Future<UserCredential> loginByEmail(
      {required String email, required String password});

  /// Mendapatkan user yang sedang login
  ///
  /// Return null jika tidak ada user yang sedang login
  Future<UserModel?> getCurrentUser();

  /// Get Firebase ID token for API authentication
  ///
  /// Returns JWT token string, or null if no authenticated user
  Future<String?> getIdToken();
}
