import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:pockeat/features/authentication/services/profile_service.dart';

/// Implementasi [ProfileService] menggunakan Firebase Authentication dan UserRepository
class ProfileServiceImpl implements ProfileService {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  /// Constructor
  ProfileServiceImpl({
    FirebaseAuth? auth,
    UserRepository? userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepositoryImpl();

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
}
