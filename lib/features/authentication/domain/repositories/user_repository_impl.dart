import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

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

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Collection reference untuk users
  late final CollectionReference<Map<String, dynamic>> _usersCollection;

  UserRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _usersCollection = _firestore.collection('users');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    // Ambil data dari Firestore untuk mendapatkan data lengkap
    return getUserById(currentUser.uid);
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      // Validasi apakah user yang login mencoba akses data miliknya
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserRepositoryException(
          'No authenticated user found',
          code: 'unauthenticated',
        );
      }

      if (currentUser.uid != userId) {
        throw UserRepositoryException(
          'Access to another user\'s data is not allowed',
          code: 'permission-denied',
        );
      }

      final docSnapshot = await _usersCollection.doc(userId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return UserModel.fromFirestore(docSnapshot);
    } on UserRepositoryException {
      // Re-throw UserRepositoryException agar error yang spesifik dapat ditangkap
      rethrow;
    } on FirebaseException catch (e) {
      throw UserRepositoryException(
        'Firebase error while getting user data',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException(
        'Unexpected error while getting user data',
        originalError: e,
      );
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      // Security Rules akan mengecek apakah user berhak menulis ke dokumen ini
      await _usersCollection.doc(user.uid).set(
            user.toMap(),
            SetOptions(
                merge: true), // Update partial, tidak override seluruh dokumen
          );
    } on FirebaseException catch (e) {
      throw UserRepositoryException(
        'Failed to save user data',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException(
        'Unexpected error while saving user data',
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
      // Validasi akses ke data
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw UserRepositoryException(
          'Cannot update profile of another user',
          code: 'permission-denied',
        );
      }

      final updateData = <String, dynamic>{};

      if (displayName != null) {
        updateData['displayName'] = displayName;

        // Update juga di Firebase Auth
        await _auth.currentUser?.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        updateData['photoURL'] = photoURL;

        // Update juga di Firebase Auth
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }

      if (gender != null) {
        updateData['gender'] = gender;
      }

      if (birthDate != null) {
        updateData['birthDate'] = Timestamp.fromDate(birthDate);
      }

      if (updateData.isNotEmpty) {
        // Security Rules akan mengecek apakah user berhak update dokumen ini
        await _usersCollection.doc(userId).update(updateData);
      }

      return true;
    } on UserRepositoryException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw UserRepositoryException(
          'You do not have permission to update this profile',
          code: e.code,
          originalError: e,
        );
      }
      throw UserRepositoryException(
        'Failed to update user profile',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException(
        'Unexpected error while updating profile',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      // Cara 1: Cek melalui Firebase Auth (lebih aman, tidak perlu atur security rules khusus)
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      // Ini bisa jadi normal jika email invalid format
      if (e.code == 'invalid-email') {
        throw UserRepositoryException(
          'Invalid email format',
          code: e.code,
          originalError: e,
        );
      }
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

  @override
  Future<void> updateEmailVerificationStatus(
      String userId, bool isVerified) async {
    try {
      // Validasi akses ke data
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw UserRepositoryException(
          'Cannot update verification status of another user',
          code: 'permission-denied',
        );
      }

      // Security Rules akan mengecek apakah user berhak update dokumen ini
      await _usersCollection.doc(userId).update({
        'emailVerified': isVerified,
      });
    } on UserRepositoryException {
      rethrow;
    } on FirebaseException catch (e) {
      throw UserRepositoryException(
        'Failed to update email verification status',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException(
        'Unexpected error updating email verification status',
        originalError: e,
      );
    }
  }

  @override
  Stream<UserModel?> userStream(String userId) {
    try {
      // Validasi akses ke data
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw UserRepositoryException(
          'Cannot stream data of another user',
          code: 'permission-denied',
        );
      }

      // Security Rules akan mengecek apakah user berhak mengakses dokumen ini secara real-time
      return _usersCollection.doc(userId).snapshots().map((snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        return UserModel.fromFirestore(snapshot);
      }).handleError((error) {
        if (error is FirebaseException) {
          throw UserRepositoryException(
            'Error streaming user data',
            code: error.code,
            originalError: error,
          );
        }
        throw UserRepositoryException(
          'Unexpected error in user stream',
          originalError: error,
        );
      });
    } catch (e) {
      // Untuk error yang terjadi sebelum stream dibuat
      // Konversi ke error stream
      return Stream.error(
        e is UserRepositoryException
            ? e
            : UserRepositoryException(
                'Failed to create user stream',
                originalError: e,
              ),
      );
    }
  }

  @override
  Stream<UserModel?> currentUserStream() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        // Ambil data dari Firestore
        final userDoc = await _usersCollection.doc(firebaseUser.uid).get();

        if (!userDoc.exists) {
          // User ada di Auth tapi belum ada di Firestore
          // Mungkin perlu buat dokumen baru
          final newUser = UserModel.fromFirebaseUser(firebaseUser);
          await saveUser(newUser);
          return newUser;
        }

        return UserModel.fromFirestore(userDoc);
      } on FirebaseException catch (e) {
        throw UserRepositoryException(
          'Error retrieving current user data',
          code: e.code,
          originalError: e,
        );
      } catch (e) {
        // Jika gagal dapat data Firestore, gunakan data minimal dari Auth
        if (e is! UserRepositoryException) {
          // Log error tapi jangan throw karena ini stream
          // Kita masih mau return user dari auth
        }
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    }).handleError((error) {
      // Handle error dari asyncMap
      if (error is FirebaseAuthException) {
        throw UserRepositoryException(
          'Auth state error',
          code: error.code,
          originalError: error,
        );
      }
      if (error is! UserRepositoryException) {
        throw UserRepositoryException(
          'Unexpected error in current user stream',
          originalError: error,
        );
      }
      throw error; // Jika sudah UserRepositoryException, rethrow saja
    });
  }
}
