import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_base.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_auth_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_firestore_repository.dart';

/// Repository untuk mengelola reactive stream data user
class UserStreamRepository extends UserRepositoryBase {
  final UserFirestoreRepository _firestoreRepo;
  final UserAuthRepository _authRepo;

  // Cached stream untuk current user
  late final Stream<UserModel?> _currentUserStream;

  /// Stream untuk notifikasi perubahan data user
  Stream<UserModel?> get userChanges => userChangesController.stream;

  /// Stream untuk current user
  Stream<UserModel?> get currentUserStream => _currentUserStream;

  UserStreamRepository({
    UserFirestoreRepository? firestoreRepo,
    UserAuthRepository? authRepo,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _firestoreRepo = firestoreRepo ??
            UserFirestoreRepository(auth: auth, firestore: firestore),
        _authRepo =
            authRepo ?? UserAuthRepository(auth: auth, firestore: firestore),
        super(
            auth: auth ?? FirebaseAuth.instance,
            firestore: firestore ?? FirebaseFirestore.instance) {
    // Inisialisasi current user stream dengan transformasi efisien
    _currentUserStream = _initCurrentUserStream();
  }

  /// Inisialisasi current user stream
  Stream<UserModel?> _initCurrentUserStream() {
    return _authRepo.authStateChanges.asyncMap((user) {
      return _authStateToUserModel(user);
    }).distinct();
  }

  /// Konversi user auth menjadi UserModel lengkap
  Future<UserModel?> _authStateToUserModel(User? firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }

    try {
      // Coba ambil data dari Firestore
      final userModel = await _firestoreRepo.getUserById(firebaseUser.uid);

      // Jika user belum ada di Firestore, buat baru
      if (userModel == null) {
        final newUser = _authRepo.createUserModelFromAuth(firebaseUser);
        await _firestoreRepo.saveUser(newUser);
        return newUser;
      }

      return userModel;
    } catch (e) {
      // Fallback ke data dasar jika ada error
      return _authRepo.createUserModelFromAuth(firebaseUser);
    }
  }

  /// Mendapatkan stream perubahan data user
  Stream<UserModel?> getUserStream(String userId) {
    try {
      // Validasi akses
      validateUserAccess(userId);

      // Dapatkan stream dari Firestore
      return _firestoreRepo.userChangesStream(userId);
    } catch (e) {
      // Konversi error menjadi stream error
      return Stream.error(e);
    }
  }
}
