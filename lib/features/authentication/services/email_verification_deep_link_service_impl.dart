import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
// Hapus import Firebase Dynamic Links
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';
import 'package:app_links/app_links.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';

/// Exception khusus untuk DeepLinkService
class EmailVerificationDeepLinkException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  EmailVerificationDeepLinkException(this.message,
      {this.code, this.originalError});

  @override
  String toString() =>
      'DeepLinkException: $message${code != null ? ' (code: $code)' : ''}';
}

class EmailVerificationDeepLinkServiceImpl
    implements EmailVerificationDeepLinkService {
  final FirebaseAuth _auth;
  final AppLinks _appLinks = AppLinks();
  late final BuildContext _context;
  final UserRepository _userRepository;

  StreamSubscription? _appLinksSub;
  final StreamController<Uri?> _deepLinkStreamController =
      StreamController<Uri?>.broadcast();

  // Properti untuk testing
  @visibleForTesting
  BuildContext? contextForTesting;

  EmailVerificationDeepLinkServiceImpl({
    FirebaseAuth? auth,
    UserRepository? userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepositoryImpl(auth: auth);

  // Getter dan metode untuk mempermudah unit testing
  @visibleForTesting
  Future<Uri?> getInitialAppLink() => _appLinks.getInitialAppLink();

  @visibleForTesting
  Stream<Uri> getUriLinkStream() => _appLinks.uriLinkStream;

  @visibleForTesting
  BuildContext? get context {
    if (contextForTesting != null) {
      return contextForTesting;
    }
    return _context;
  }

  @override
  Future<void> initialize() async {
    try {
      final initialLink = await getInitialAppLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      throw EmailVerificationDeepLinkException(
        'Failed to initialize initial link handler',
        originalError: e,
      );
    }

    try {
      _appLinksSub = getUriLinkStream().listen(
        (Uri uri) {
          _handleIncomingLink(uri);
        },
        onError: (error) {
          throw EmailVerificationDeepLinkException(
            'Error in app link stream',
            originalError: error,
          );
        },
      );
    } catch (e) {
      throw EmailVerificationDeepLinkException(
        'Failed to setup deep link listener',
        originalError: e,
      );
    }
  }

  void _handleIncomingLink(Uri link) async {
    try {
      if (isEmailVerificationLink(link)) {
        _deepLinkStreamController.add(link);
      } else {
        _deepLinkStreamController.add(link);
      }
    } catch (e) {
      throw EmailVerificationDeepLinkException('Error handling incoming link',
          originalError: e);
    }
  }

  @override
  Stream<Uri?> getInitialLink() async* {
    try {
      final initialLink = await getInitialAppLink();
      if (initialLink != null) {
        yield initialLink;
      }
    } catch (e) {
      throw EmailVerificationDeepLinkException('Error retrieving initial URI',
          originalError: e);
    }
  }

  @override
  Stream<Uri?> onLinkReceived() {
    return _deepLinkStreamController.stream;
  }

  @override
  Future<bool> handleEmailVerificationLink(Uri link) async {
    try {
      if (!isEmailVerificationLink(link)) {
        return false;
      }

      final oobCode = link.queryParameters['oobCode'];
      if (oobCode == null) {
        return false;
      }

      try {
        final actionCodeInfo = await _auth.checkActionCode(oobCode);
        await _auth.applyActionCode(oobCode);

        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          await currentUser.reload();
        }

        final isVerified = _auth.currentUser?.emailVerified ?? false;

        if (isVerified && _auth.currentUser != null) {
          try {
            await _userRepository.updateEmailVerificationStatus(
                _auth.currentUser!.uid, true);
          } catch (e) {
            // Continue even if Firestore update fails
          }
        }

        return isVerified;
      } on FirebaseAuthException catch (e) {
        throw EmailVerificationDeepLinkException(
          'Firebase auth error when verifying email: ${e.message}',
          code: e.code,
          originalError: e,
        );
      } catch (e) {
        throw EmailVerificationDeepLinkException('Error applying action code',
            originalError: e);
      }
    } catch (e) {
      if (e is EmailVerificationDeepLinkException) {
        rethrow;
      }
      throw EmailVerificationDeepLinkException(
        'Error handling email verification link',
        originalError: e,
      );
    }
  }

  @override
  bool isEmailVerificationLink(Uri link) {
    try {
      final params = link.queryParameters;
      final mode = params['mode'];
      final oobCode = params['oobCode'];
      return (mode == 'verifyEmail' && oobCode != null);
    } catch (e) {
      throw EmailVerificationDeepLinkException(
        'Error validating email verification link',
        originalError: e,
      );
    }
  }

  @override
  void dispose() {
    try {
      _appLinksSub?.cancel();
      _deepLinkStreamController.close();
    } catch (e) {
      throw EmailVerificationDeepLinkException(
        'Error disposing deep link service',
        originalError: e,
      );
    }
  }
}
