import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';

/// Implementasi [LoginService] menggunakan Firebase Authentication
class LoginServiceImpl implements LoginService {
  final FirebaseAuth _auth;

  /// Constructor
  LoginServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

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

      return credential;
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be handled by the caller
      throw e;
    } catch (e) {
      // Catch other exceptions and throw them as FirebaseAuthException
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Terjadi kesalahan saat login: ${e.toString()}',
      );
    }
  }
}
