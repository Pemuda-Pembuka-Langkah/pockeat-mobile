// Dart imports:
import 'dart:io';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:pockeat/features/authentication/services/profile_service.dart';

// ignore: depend_on_referenced_packages

/// Implementasi [ProfileService] menggunakan Firebase Authentication dan UserRepository
class ProfileServiceImpl implements ProfileService {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;
  final FirebaseStorage _storage;

  /// Constructor
  ProfileServiceImpl({
    FirebaseAuth? auth,
    UserRepository? userRepository,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        // coverage:ignore-start
        _userRepository = userRepository ?? UserRepositoryImpl(),
        _storage = storage ?? FirebaseStorage.instance;
  // coverage:ignore-end

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _userRepository.getCurrentUser();
    } catch (e) {
      // Log error
      return null;
    }
  }

  @override
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      return await _userRepository.updateUserProfile(
        userId: user.uid,
        displayName: displayName,
        photoURL: photoURL,
      );
    } catch (e) {
      // Log error
      return false;
    }
  }

  @override
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      await user.sendEmailVerification();
      return true;
    } catch (e) {
      // Log error
      return false;
    }
  }

  // coverage:ignore-start
  @override
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      // Format nama file: profiles/{uid}/profile_{timestamp}.{extension}
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final storageRef = _storage.ref().child('profiles/${user.uid}/$fileName');

      // Upload file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType:
              'image/${path.extension(imageFile.path).replaceAll('.', '')}',
          customMetadata: {'userId': user.uid},
        ),
      );

      // Tunggu hingga upload selesai
      final snapshot = await uploadTask;

      // Dapatkan download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile dengan URL baru
      final success = await updateUserProfile(photoURL: downloadUrl);

      if (success) {
        return downloadUrl;
      } else {
        // Jika gagal update profile, hapus file yang sudah diupload
        await storageRef.delete();
        return null;
      }
    } catch (e) {
      // Log error
      return null;
    }
  }
  // coverage:ignore-end
}
