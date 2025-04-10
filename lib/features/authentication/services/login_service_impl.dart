import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';

/// Implementasi [LoginService] menggunakan Firebase Authentication
class LoginServiceImpl implements LoginService {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;
  StreamSubscription<UserModel?>? _subscription;

  /// Constructor
  LoginServiceImpl({
    FirebaseAuth? auth,
    required UserRepository userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository;

  @override
  Stream<UserModel?> initialize() {
    // Membatalkan subscription sebelumnya jika ada
    _subscription?.cancel();

    // Ambil stream langsung dari repository
    return _userRepository.currentUserStream();
  }

  @override
  Future<UserCredential> loginByEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      // Ubah pesan error menjadi lebih spesifik dalam bahasa Inggris
      String message;
      switch (e.code) {
        case 'user-not-found':
          message =
              'Email not registered. Please check your email or register first.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please check your password.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password. Please check your credentials.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Please contact admin.';
          break;
        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;
        case 'invalid-email':
          message = 'Invalid email format. Please check your email.';
          break;
        case 'operation-not-allowed':
          message =
              'Login with email and password is not allowed. Please use another login method.';
          break;
        case 'network-request-failed':
          message =
              'Network problem occurred. Please check your internet connection.';
          break;
        default:
          message = 'Login failed: ${e.message ?? e.code}';
      }

      throw FirebaseAuthException(
        code: e.code,
        message: message,
      );
    } catch (e) {
      // Catch other exceptions and throw them as FirebaseAuthException
      const message =
          'An unexpected error occurred during login. Please try again later.';
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: message,
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      // Convert Firebase User to UserModel
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        emailVerified: firebaseUser.emailVerified,
        createdAt:
            DateTime.now(), // We don't know the actual creation time here
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getIdToken() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      // Get Firebase ID token (JWT)
      return await firebaseUser.getIdToken(true); // Force refresh token
    } catch (e) {
      return null;
    }
  }

  /// Membersihkan resource ketika service tidak digunakan lagi
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
