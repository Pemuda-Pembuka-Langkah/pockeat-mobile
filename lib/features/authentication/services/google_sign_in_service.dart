import 'package:firebase_auth/firebase_auth.dart';

abstract class GoogleSignInService {
  Future<UserCredential> signInWithGoogle();
}
