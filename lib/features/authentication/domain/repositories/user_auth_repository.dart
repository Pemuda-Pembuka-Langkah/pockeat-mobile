import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_base.dart';

/// Repository untuk operasi Firebase Auth
class UserAuthRepository extends UserRepositoryBase {
  UserAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : super(auth: auth, firestore: firestore);

  /// Mendapatkan user saat ini
  User? get currentUser => auth.currentUser;

  /// Stream perubahan status auth
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Update profil user di Firebase Auth
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;

      if (user == null) {
        throw UserRepositoryException(
          'No authenticated user found',
          code: 'unauthenticated',
        );
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
    } on FirebaseAuthException catch (e) {
      throw UserRepositoryException(
        'Failed to update auth profile',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException(
        'Unexpected error while updating auth profile',
        originalError: e,
      );
    }
  }

  /// Memeriksa apakah email sudah terdaftar
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      // Validasi format email secara lokal terlebih dahulu
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(email)) {
        throw UserRepositoryException(
          'Invalid email format',
          code: 'invalid-email',
        );
      }

      // Cek melalui Firebase Auth
      final methods = await auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } on UserRepositoryException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw UserRepositoryException(
        'Error checking email registration status',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException(
        'Unexpected error checking email registration',
        originalError: e,
      );
    }
  }

  /// Membuat UserModel dari data Firebase User
  UserModel createUserModelFromAuth(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
    );
  }
}
