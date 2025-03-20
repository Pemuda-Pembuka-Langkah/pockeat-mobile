// ignore_for_file: avoid_print

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:app_links/app_links.dart';
import 'package:meta/meta.dart';

/// Exception khusus untuk DeepLinkService
class DeepLinkException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  DeepLinkException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'DeepLinkException: $message${code != null ? ' (code: $code)' : ''}';
}

class DeepLinkServiceImpl implements DeepLinkService {
  final FirebaseAuth _auth;
  final FirebaseDynamicLinks _dynamicLinks;
  final AppLinks _appLinks = AppLinks();

  StreamSubscription? _deepLinkSub;
  StreamSubscription? _appLinksSub;
  final StreamController<Uri?> _deepLinkStreamController =
      StreamController<Uri?>.broadcast();

  DeepLinkServiceImpl({
    FirebaseAuth? auth,
    FirebaseDynamicLinks? dynamicLinks,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  // Getter dan metode untuk mempermudah unit testing
  @visibleForTesting
  Future<Uri?> getInitialAppLink() => _appLinks.getInitialAppLink();

  @visibleForTesting
  Stream<Uri> getUriLinkStream() => _appLinks.uriLinkStream;

  @override
  Future<void> initialize() async {
    // 1. Handle initial link (app opened from a link)
    try {
      final initialLink = await getInitialAppLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      throw DeepLinkException('Failed to initialize initial link handler',
          originalError: e);
    }

    // 2. Handle links while app is running
    try {
      _appLinksSub = getUriLinkStream().listen((Uri uri) {
        _handleIncomingLink(uri);
      }, onError: (error) {
        throw DeepLinkException('Error in app link stream',
            originalError: error);
      });

      _deepLinkSub = onLinkReceived().listen((Uri? link) {
        if (link != null) {
          _handleIncomingLink(link);
        }
      }, onError: (error) {
        throw DeepLinkException('Error in deep link stream',
            originalError: error);
      });
    } catch (e) {
      throw DeepLinkException('Failed to setup deep link listener',
          originalError: e);
    }

    // 3. Handle Firebase Dynamic Links
    try {
      _dynamicLinks.onLink.listen((PendingDynamicLinkData dynamicLinkData) {
        final Uri deepLink = dynamicLinkData.link;
        _handleIncomingLink(deepLink);
      }).onError((error) {
        throw DeepLinkException('Error handling Firebase dynamic link',
            originalError: error);
      });
    } catch (e) {
      throw DeepLinkException('Failed to setup Firebase dynamic link listener',
          originalError: e);
    }
  }

  void _handleIncomingLink(Uri link) {
    try {
      _deepLinkStreamController.add(link);

      // Handle email verification link automatically
      if (isEmailVerificationLink(link)) {
        handleEmailVerificationLink(link).then((bool success) {
          if (success) {
            // Navigasi ke halaman akun telah diaktifkan ditangani oleh RegisterPage
            // Notifikasi stream untuk menginformasikan bahwa email telah diverifikasi
            _deepLinkStreamController
                .add(Uri.parse('pockeat://email-verified'));
          }
        }).catchError((error) {
          // Error handling saat memproses verifikasi
        });
      }
    } catch (e) {
      throw DeepLinkException('Error handling incoming link', originalError: e);
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
      throw DeepLinkException('Error retrieving initial URI', originalError: e);
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
        throw DeepLinkException('Missing oobCode in verification link');
      }

      // Check if it's a valid action code
      try {
        await _auth.checkActionCode(oobCode);

        // Apply the action code (verify email)
        await _auth.applyActionCode(oobCode);

        // Reload the user to update emailVerified status
        await _auth.currentUser?.reload();

        return _auth.currentUser?.emailVerified ?? false;
      } on FirebaseAuthException catch (e) {
        throw DeepLinkException('Firebase auth error when verifying email',
            code: e.code, originalError: e);
      } catch (e) {
        throw DeepLinkException('Error applying action code', originalError: e);
      }
    } catch (e) {
      if (e is DeepLinkException) {
        // Untuk backward compatibility dengan code yang ada,
        // kita tidak melempar exception tapi mengembalikan false
        // saat ini, tapi logging bisa ditambahkan di sini
        return false;
      }
      throw DeepLinkException('Error handling email verification link',
          originalError: e);
    }
  }

  @override
  bool isEmailVerificationLink(Uri link) {
    // Check for Firebase Auth email verification link pattern
    try {
      final params = link.queryParameters;
      return link.host.contains('firebaseapp.com') &&
          (params.containsKey('mode') && params['mode'] == 'verifyEmail') &&
          params.containsKey('oobCode');
    } catch (e) {
      throw DeepLinkException('Error validating email verification link',
          originalError: e);
    }
  }

  @override
  void dispose() {
    try {
      _deepLinkSub?.cancel();
      _appLinksSub?.cancel();
      _deepLinkStreamController.close();
    } catch (e) {
      throw DeepLinkException('Error disposing deep link service',
          originalError: e);
    }
  }
}
