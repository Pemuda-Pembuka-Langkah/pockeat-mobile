// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Project imports:
import 'google_sign_in_service.dart';

class GoogleSignInServiceImpl implements GoogleSignInService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  // coverage:ignore-start
  GoogleSignInServiceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        // coverage:ignore-line
        _googleSignIn = googleSignIn ?? GoogleSignIn();
  // coverage:ignore-end
  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Check if a user is already signed in
      final bool isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        // Sign out first if a user is already signed in
        await _googleSignIn.signOut();
      }

      // Trigger Google Sign In flow with prompt to select account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled');
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }
}
