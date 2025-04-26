// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';

class RegisterServiceImpl implements RegisterService {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  RegisterServiceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    UserRepository? userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        // coverage:ignore-start
        _userRepository = userRepository ??
            UserRepositoryImpl(auth: auth, firestore: firestore);
  // coverage:ignore-end

  /// Validasi email
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  /// Validasi password
  bool _isValidPassword(String password) {
    // Password minimal 8 karakter, mengandung huruf besar, huruf kecil, dan angka atau simbol
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    final hasMinLength = password.length >= 8;

    return hasUppercase &&
        hasLowercase &&
        (hasDigit || hasSpecialChar) &&
        hasMinLength;
  }

  @override
  Future<RegisterResult> register({
    required String email,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
    String? displayName,
    DateTime? birthDate,
    String? gender,
  }) async {
    try {
      // Validasi input
      if (!termsAccepted) {
        return RegisterResult.operationNotAllowed;
      }

      if (password != confirmPassword) {
        return RegisterResult.weakPassword;
      }

      if (!_isValidEmail(email)) {
        return RegisterResult.invalidEmail;
      }

      if (!_isValidPassword(password)) {
        return RegisterResult.weakPassword;
      }

      // Cek apakah email sudah terdaftar
      bool isRegistered = await _userRepository.isEmailAlreadyRegistered(email);
      if (isRegistered) {
        return RegisterResult.emailAlreadyInUse;
      }

      // Mendaftarkan user baru
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Memperbarui displayName jika tersedia
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      // Menyimpan data user menggunakan repository
      if (credential.user != null) {
        final user = UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          photoURL: null,
          emailVerified: false,
          gender: gender,
          birthDate: birthDate,
          createdAt: DateTime.now(),
        );

        await _userRepository.saveUser(user);

        // Mengirim email verifikasi secara otomatis setelah pendaftaran berhasil
        await sendEmailVerification();
      }

      return RegisterResult.success;
    } on FirebaseAuthException catch (e) {
      return switch (e.code) {
        'email-already-in-use' => RegisterResult.emailAlreadyInUse,
        'invalid-email' => RegisterResult.invalidEmail,
        'weak-password' => RegisterResult.weakPassword,
        'operation-not-allowed' => RegisterResult.operationNotAllowed,
        _ => RegisterResult.unknown,
      };
    } catch (e) {
      return RegisterResult.unknown;
    }
  }

  @override
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Mengirim email verifikasi dari Firebase
      await user.sendEmailVerification();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  // coverage:ignore-start
  Future<bool> resendEmailVerification() async {
    // Implementasinya sama dengan sendEmailVerification,
    // tetapi dibuat terpisah untuk kejelasan fungsionalitas
    return sendEmailVerification();
  }
  // coverage:ignore-end

  @override
  Future<bool> isEmailVerified() async {
    try {
      // Memuat ulang data user untuk mendapatkan status verifikasi terkini
      await _auth.currentUser?.reload();

      // Mengambil status emailVerified dari Firebase Auth
      final isVerified = _auth.currentUser?.emailVerified ?? false;

      // Jika email sudah diverifikasi, update juga status di repository
      if (isVerified && _auth.currentUser != null) {
        await _userRepository.updateEmailVerificationStatus(
          _auth.currentUser!.uid,
          true,
        );
      }

      return isVerified;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> watchEmailVerificationStatus() {
    // Menggunakan currentUserStream dari repository untuk mendapatkan update real-time
    return _userRepository.currentUserStream().map((user) {
      return user?.emailVerified ?? false;
    });
  }

  @override
  Future<bool> updateUserProfile({
    String? displayName,
    DateTime? birthDate,
    String? gender,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      // Menggunakan repository untuk update profil
      return await _userRepository.updateUserProfile(
        userId: user.uid,
        displayName: displayName,
        birthDate: birthDate,
        gender: gender,
      );
    } catch (_) {
      return false;
    }
  }
}
