// ignore_for_file: avoid_print

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
  late final GlobalKey<NavigatorState> _navigatorKey;
  final UserRepository _userRepository;

  StreamSubscription? _appLinksSub;
  final StreamController<Uri?> _deepLinkStreamController =
      StreamController<Uri?>.broadcast();

  // Properti untuk testing
  @visibleForTesting
  GlobalKey<NavigatorState>? navigatorKeyForTesting;

  @visibleForTesting
  NavigatorState? currentStateForTesting;

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
  NavigatorState? get currentState {
    // Untuk testing
    if (currentStateForTesting != null) {
      return currentStateForTesting;
    }
    // Untuk penggunaan normal
    return _navigatorKey.currentState;
  }

  @override
  Future<void> initialize(
      {required GlobalKey<NavigatorState> navigatorKey}) async {
    _navigatorKey = navigatorKeyForTesting ?? navigatorKey;

    // 1. Handle initial link (app opened from a link)
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

    // 2. Handle links while app is running
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

  void _handleIncomingLink(Uri link) {
    try {
      // Handle email verification links
      if (isEmailVerificationLink(link)) {
        handleEmailVerificationLink(link).then((bool success) {
          if (success) {
            final email = _auth.currentUser?.email ?? '';
            currentState?.pushReplacementNamed(
              '/account-activated',
              arguments: {'email': email},
            );

            // Show success message
            ScaffoldMessenger.of(currentState!.context).showSnackBar(
              SnackBar(
                content: Text('Email successfully verified!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // Navigasi ke halaman failed verification
            currentState?.pushReplacementNamed(
              '/email-verification-failed',
              arguments: {
                'error': 'Email verification failed. Please try again.'
              },
            );
          }
        }).catchError((error) {
          // Navigasi ke halaman failed verification dengan error message
          currentState?.pushReplacementNamed(
            '/email-verification-failed',
            arguments: {'error': 'Error: $error'},
          );
        });
      }

      // Broadcast link to stream for other listeners
      _deepLinkStreamController.add(link);
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

      // Extract oobCode or other params from link
      final oobCode = link.queryParameters['oobCode'];
      if (oobCode == null) {
        throw EmailVerificationDeepLinkException(
            'Missing oobCode in verification link');
      }

      // Check if it's a valid action code
      try {
        await _auth.checkActionCode(oobCode);

        // Apply the action code (verify email)
        await _auth.applyActionCode(oobCode);

        // Reload the user to update emailVerified status
        await _auth.currentUser?.reload();

        final isVerified = _auth.currentUser?.emailVerified ?? false;

        // Update user data in Firestore if email was verified successfully
        if (isVerified && _auth.currentUser != null) {
          try {
            // Update emailVerified status in Firestore
            await _userRepository.updateEmailVerificationStatus(
                _auth.currentUser!.uid, true);
          } catch (e) {
            // Continue even if Firestore update fails, because Firebase Auth verification was successful
          }
        }

        return isVerified;
      } on FirebaseAuthException catch (e) {
        throw EmailVerificationDeepLinkException(
          'Firebase auth error when verifying email',
          code: e.code,
          originalError: e,
        );
      } catch (e) {
        throw EmailVerificationDeepLinkException('Error applying action code',
            originalError: e);
      }
    } catch (e) {
      if (e is EmailVerificationDeepLinkException) {
        // Untuk backward compatibility dengan code yang ada,
        // kita tidak melempar exception tapi mengembalikan false
        return false;
      }
      throw EmailVerificationDeepLinkException(
        'Error handling email verification link',
        originalError: e,
      );
    }
  }

  @override
  bool isEmailVerificationLink(Uri link) {
    // Hanya check untuk custom scheme pattern (pockeat://)
    try {
      final params = link.queryParameters;
      return link.scheme == 'pockeat' &&
          (params.containsKey('mode') && params['mode'] == 'verifyEmail') &&
          params.containsKey('oobCode');
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
