import 'package:firebase_auth/firebase_auth.dart';

/// Service untuk menangani proses login
abstract class LoginService {
  /// Login menggunakan email dan password
  /// 
  /// Mengembalikan [UserCredential] jika berhasil
  /// 
  /// Throws [FirebaseAuthException] jika terjadi kesalahan pada authentikasi
  Future<UserCredential> loginByEmail({
    required String email, 
    required String password
  });
} 