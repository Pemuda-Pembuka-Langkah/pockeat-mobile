import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pockeat/features/authentication/services/logout_service.dart';

/// Implementasi [LogoutService] menggunakan Firebase Authentication
class LogoutServiceImpl implements LogoutService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Constructor
  // coverage:ignore-start
  LogoutServiceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();
  // coverage:ignore-end

  @override
  Future<bool> logout() async {
    try {
      // Cek apakah login dengan Google, jika ya, logout dari Google juga
      final currentUser = _auth.currentUser;
      final isGoogleLogin = currentUser?.providerData
              .any((element) => element.providerId == 'google.com') ??
          false;

      // Logout dari Firebase Auth
      await _auth.signOut();

      // Logout dari Google Sign In jika perlu
      if (isGoogleLogin) {
        await _googleSignIn.signOut();
      }

      return true;
    } catch (e) {
      // Log error
      return false;
    }
  }
}
