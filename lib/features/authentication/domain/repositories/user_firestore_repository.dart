import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_base.dart';

/// Repository untuk operasi Firestore dengan data user
class UserFirestoreRepository extends UserRepositoryBase {
  UserFirestoreRepository({
    super.auth,
    super.firestore,
  });

  /// Mendapatkan data user dari Firestore berdasarkan ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final docSnapshot = await usersCollection.doc(userId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return UserModel.fromFirestore(docSnapshot);
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

  /// Menyimpan data user ke Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await usersCollection.doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );

      // Notifikasi perubahan untuk reactive UI
      notifyUserChanged(user);
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

  /// Memperbarui data user di Firestore
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await usersCollection.doc(userId).update(data);
    } on FirebaseException catch (e) {
      throw UserRepositoryException(
        'Failed to update user data',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException(
        'Unexpected error while updating user data',
        originalError: e,
      );
    }
  }

  /// Stream perubahan data user dari Firestore
  Stream<UserModel?> userChangesStream(String userId) {
    return usersCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? UserModel.fromFirestore(snapshot) : null)
        .distinct() // Filter duplicate events
        .handleError((error, stackTrace) {
      if (error is FirebaseException) {
        throw UserRepositoryException(
          'Firebase error in stream',
          code: error.code,
          originalError: error,
        );
      }
      throw UserRepositoryException(
        'Unexpected error in stream',
        originalError: error,
      );
    });
  }
}
