import 'package:firebase_auth/firebase_auth.dart';

/// Manages authentication tokens in a centralized way
class TokenManager {
  final FirebaseAuth _auth;

  TokenManager({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Get the Firebase ID token, refreshing if necessary
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken(forceRefresh);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
