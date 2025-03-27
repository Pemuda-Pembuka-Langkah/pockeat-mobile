// ignore_for_file: avoid_print

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:app_links/app_links.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

/// Exception khusus untuk ChangePasswordDeepLinkService
class ChangePasswordDeepLinkException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ChangePasswordDeepLinkException(this.message,
      {this.code, this.originalError});

  @override
  String toString() =>
      'ChangePasswordDeepLinkException: $message${code != null ? ' (code: $code)' : ''}';
}

class ChangePasswordDeepLinkServiceImpl
    implements ChangePasswordDeepLinkService {
  final FirebaseAuth _auth;
  final AppLinks _appLinks = AppLinks();
  late final GlobalKey<NavigatorState> _navigatorKey;

  StreamSubscription? _appLinksSub;
  final StreamController<Uri?> _deepLinkStreamController =
      StreamController<Uri?>.broadcast();

  // Properti untuk testing
  @visibleForTesting
  GlobalKey<NavigatorState>? navigatorKeyForTesting;

  @visibleForTesting
  NavigatorState? currentStateForTesting;

  ChangePasswordDeepLinkServiceImpl({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

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
      throw ChangePasswordDeepLinkException(
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
          throw ChangePasswordDeepLinkException(
            'Error in app link stream',
            originalError: error,
          );
        },
      );
    } catch (e) {
      throw ChangePasswordDeepLinkException(
        'Failed to setup deep link listener',
        originalError: e,
      );
    }
  }

  void _handleIncomingLink(Uri link) {
    try {
      // Handle change password links
      if (isChangePasswordLink(link)) {
        handleChangePasswordLink(link).then((bool success) {
          if (success) {
            // Redirect ke halaman change password
            currentState?.pushReplacementNamed('/change-password');
          }
        }).catchError((error) {
          // Navigasi ke halaman error dengan error message
          currentState?.pushReplacementNamed(
            '/change-password-error',
            arguments: {'error': 'Error: $error'},
          );
        });
      }

      // Broadcast link to stream for other listeners
      _deepLinkStreamController.add(link);
    } catch (e) {
      throw ChangePasswordDeepLinkException('Error handling incoming link',
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
      throw ChangePasswordDeepLinkException('Error retrieving initial URI',
          originalError: e);
    }
  }

  @override
  Stream<Uri?> onLinkReceived() {
    return _deepLinkStreamController.stream;
  }

  @override
  bool isChangePasswordLink(Uri link) {
    try {
      final mode = link.queryParameters['mode'];
      final oobCode = link.queryParameters['oobCode'];

      // Cek apakah link memiliki parameter mode = resetPassword dan oobCode
      return mode == 'resetPassword' && oobCode != null;
    } catch (e) {
      throw ChangePasswordDeepLinkException(
        'Error validating change password link',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> handleChangePasswordLink(Uri link) async {
    try {
      if (!isChangePasswordLink(link)) {
        return false;
      }

      // Extract oobCode
      final oobCode = link.queryParameters['oobCode'];
      if (oobCode == null) {
        throw ChangePasswordDeepLinkException(
            'Missing oobCode in change password link');
      }

      // Verify action code
      try {
        await _auth.checkActionCode(oobCode);
        // Lalu simpan oobCode untuk digunakan pada halaman change password
        // Diasumsikan kita punya halaman change password yang akan menggunakan oobCode ini

        // Kita bisa mengirim oobCode sebagai argumen ke route change password
        // tapi ini akan membuat oobCode terekspos di stack navigasi
        // Alternatifnya, gunakan shared preferences, atau state management

        return true;
      } on FirebaseAuthException catch (e) {
        throw ChangePasswordDeepLinkException(
          'Firebase auth error when verifying change password link',
          code: e.code,
          originalError: e,
        );
      } catch (e) {
        throw ChangePasswordDeepLinkException('Error checking action code',
            originalError: e);
      }
    } catch (e) {
      if (e is ChangePasswordDeepLinkException) {
        // Untuk backward compatibility dengan code yang ada,
        // kita tidak melempar exception tapi mengembalikan false
        return false;
      }
      throw ChangePasswordDeepLinkException(
        'Error handling change password link',
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
      throw ChangePasswordDeepLinkException(
        'Error disposing deep link service',
        originalError: e,
      );
    }
  }
}
