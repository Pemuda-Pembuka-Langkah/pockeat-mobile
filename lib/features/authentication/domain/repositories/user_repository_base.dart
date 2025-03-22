import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

/// Repository dasar untuk manajemen Firebase Auth dan Firestore
abstract class UserRepositoryBase {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  late final CollectionReference<Map<String, dynamic>> usersCollection;

  // Stream controller untuk reactive updates
  final StreamController<UserModel?> userChangesController =
      StreamController<UserModel?>.broadcast();

  UserRepositoryBase({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance {
    usersCollection = this.firestore.collection('users');
  }

  /// Validasi akses user ke ID tertentu
  void validateUserAccess(String userId) {
    final currentUser = auth.currentUser;
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
  }

  /// Notifikasi perubahan data user
  void notifyUserChanged(UserModel user) {
    if (!userChangesController.isClosed) {
      userChangesController.add(user);
    }
  }

  /// Menutup resources
  void dispose() {
    userChangesController.close();
  }
}

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
