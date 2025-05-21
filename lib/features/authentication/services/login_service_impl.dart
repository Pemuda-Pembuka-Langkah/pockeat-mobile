// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
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

  /// Checks if user needs email verification - returns true if email is not verified
  @override
  Future<bool> needsEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false; // No user to verify
      }

      // Reload user to get latest verification status
      await user.reload();
      return !user.emailVerified;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
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

      // Check if email is verified
      if (credential.user != null && !credential.user!.emailVerified) {
        // Throw a custom error for unverified email
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message:
              'Please verify your email before logging in. Check your inbox for a verification link.',
        );
      }

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
        case 'email-not-verified':
          message =
              'Please verify your email before logging in. Check your inbox for a verification link.';
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

      // Reload the Firebase user to get the latest data
      await firebaseUser.reload();

      // Get user data from repository
      final userData = await _userRepository.getUserById(firebaseUser.uid);
      if (userData == null) {
        return null;
      }

      // Get fresh email verification status
      final isVerified = firebaseUser.emailVerified;

      // If the email is verified but not updated in Firestore, update it
      if (isVerified && !userData.emailVerified) {
        await _userRepository.updateEmailVerificationStatus(
            firebaseUser.uid, true);
      }

      // Override emailVerified with the value from Firebase Auth
      // This ensures we always have the most up-to-date verification status
      return userData.copyWith(emailVerified: isVerified);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Checks if the current user's email is verified
  /// Returns true if verified, false if not or if there's no current user  @override
  @override
  Future<bool> isEmailVerified() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return false;
      }

      // Reload user to get fresh data
      await firebaseUser.reload();
      final isVerified = firebaseUser.emailVerified;

      // If email is verified, update the user model in Firestore
      if (isVerified) {
        await _userRepository.updateEmailVerificationStatus(
            firebaseUser.uid, true);
      }

      return isVerified;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }

  /// Sends a verification email to the current user
  /// Returns true if email was sent successfully
  @override
  Future<bool> sendEmailVerification() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return false;
      }

      await firebaseUser.sendEmailVerification();
      return true;
    } catch (e) {
      return false;
    }
  }

  // coverage:ignore-start
  @override
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
    // coverage:ignore-end
  }

  /// Membersihkan resource ketika service tidak digunakan lagi
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
