import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

/// LoginService menangani operasi autentikasi user,
/// termasuk login, register, verifikasi email, dll.
///
/// Parameter [context] digunakan untuk navigasi otomatis
abstract class LoginService {
  /// Inisialisasi service, memulai stream auth state changes
  Stream<UserModel?> initialize();

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
}
