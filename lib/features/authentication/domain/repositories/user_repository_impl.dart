import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_base.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_auth_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_firestore_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_stream_repository.dart';

/// Exception khusus untuk repository user
class UserRepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  UserRepositoryException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'UserRepositoryException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Implementasi UserRepository dengan aplikasi Repository Pattern
class UserRepositoryImpl implements UserRepository {
  // Dependencies
  final UserAuthRepository _authRepo;
  final UserFirestoreRepository _firestoreRepo;
  final UserStreamRepository _streamRepo;

  // Factory constructor untuk penggunaan default
  factory UserRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    // Parameter tambahan untuk testing
    UserAuthRepository? authRepo,
    UserFirestoreRepository? firestoreRepo,
    UserStreamRepository? streamRepo,
  }) {
    // Jika repository sudah diinjeksi, gunakan langsung
    if (authRepo != null && firestoreRepo != null && streamRepo != null) {
      return UserRepositoryImpl._(
        authRepo: authRepo,
        firestoreRepo: firestoreRepo,
        streamRepo: streamRepo,
      );
    }

    // Jika tidak, buat repository baru
    final _authRepo = UserAuthRepository(auth: auth, firestore: firestore);
    final _firestoreRepo =
        UserFirestoreRepository(auth: auth, firestore: firestore);
    final _streamRepo = UserStreamRepository(
      firestoreRepo: _firestoreRepo,
      authRepo: _authRepo,
      auth: auth,
      firestore: firestore,
    );

    return UserRepositoryImpl._(
      authRepo: _authRepo,
      firestoreRepo: _firestoreRepo,
      streamRepo: _streamRepo,
    );
  }

  // Constructor untuk injection langsung dan testing
  UserRepositoryImpl._({
    required UserAuthRepository authRepo,
    required UserFirestoreRepository firestoreRepo,
    required UserStreamRepository streamRepo,
  })  : _authRepo = authRepo,
        _firestoreRepo = firestoreRepo,
        _streamRepo = streamRepo;

  /// Stream perubahan data user untuk reactive UI
  Stream<UserModel?> get userChanges => _streamRepo.userChanges;

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _authRepo.currentUser;
    if (currentUser == null) {
      return null;
    }

    return await _firestoreRepo.getUserById(currentUser.uid);
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      // Validasi akses
      _authRepo.validateUserAccess(userId);

      // Ambil data dari Firestore
      return await _firestoreRepo.getUserById(userId);
    } on UserRepositoryException {
      rethrow;
    } catch (e) {
      throw UserRepositoryException(
        'Error getting user data',
        originalError: e,
      );
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      // Simpan user ke Firestore
      await _firestoreRepo.saveUser(user);
    } on UserRepositoryException {
      rethrow;
    } catch (e) {
      throw UserRepositoryException(
        'Error saving user data',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoURL,
    String? gender,
    DateTime? birthDate,
  }) async {
    try {
      // Validasi akses
      _authRepo.validateUserAccess(userId);

      // Update Firebase Auth profile jika perlu
      if (displayName != null || photoURL != null) {
        await _authRepo.updateUserProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
      }

      // Persiapkan data update untuk Firestore
      final updateData = <String, dynamic>{};

      if (displayName != null) {
        updateData['displayName'] = displayName;
      }

      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
      }

      if (gender != null) {
        updateData['gender'] = gender;
      }

      if (birthDate != null) {
        updateData['birthDate'] = Timestamp.fromDate(birthDate);
      }

      // Update data di Firestore jika ada perubahan
      if (updateData.isNotEmpty) {
        await _firestoreRepo.updateUser(userId, updateData);

        // Ambil data terbaru untuk notifikasi
        final updatedUser = await _firestoreRepo.getUserById(userId);
        if (updatedUser != null) {
          _streamRepo.notifyUserChanged(updatedUser);
        }
      }

      return true;
    } on UserRepositoryException {
      rethrow;
    } catch (e) {
      throw UserRepositoryException(
        'Error updating user profile',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      return await _authRepo.isEmailAlreadyRegistered(email);
    } on UserRepositoryException {
      rethrow;
    } catch (e) {
      throw UserRepositoryException(
        'Error checking email registration',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateEmailVerificationStatus(
      String userId, bool isVerified) async {
    try {
      // Validasi akses
      _authRepo.validateUserAccess(userId);

      // Update status verifikasi
      await _firestoreRepo.updateUser(userId, {'emailVerified': isVerified});

      // Ambil data terbaru untuk notifikasi
      final updatedUser = await _firestoreRepo.getUserById(userId);
      if (updatedUser != null) {
        _streamRepo.notifyUserChanged(updatedUser);
      }
    } on UserRepositoryException {
      rethrow;
    } catch (e) {
      throw UserRepositoryException(
        'Error updating email verification status',
        originalError: e,
      );
    }
  }

  @override
  Stream<UserModel?> userStream(String userId) {
    try {
      return _streamRepo.getUserStream(userId);
    } on UserRepositoryException catch (e) {
      return Stream.error(e);
    } catch (e) {
      return Stream.error(UserRepositoryException(
        'Error creating user stream',
        originalError: e,
      ));
    }
  }

  @override
  Stream<UserModel?> currentUserStream() {
    return _streamRepo.currentUserStream;
  }

  /// Cleanup resources saat repository tidak digunakan lagi
  void dispose() {
    _authRepo.dispose();
    _firestoreRepo.dispose();
    _streamRepo.dispose();
  }
}
