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

  StreamSubscription? _appLinksSub;
  final StreamController<Uri?> _deepLinkStreamController =
      StreamController<Uri?>.broadcast();

  ChangePasswordDeepLinkServiceImpl({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  @visibleForTesting
  Future<Uri?> getInitialAppLink() => _appLinks.getInitialAppLink();

  @visibleForTesting
  Stream<Uri> getUriLinkStream() => _appLinks.uriLinkStream;

  @override
  Future<void> initialize() async {
    try {
      final initialLink = await getInitialAppLink();
      if (initialLink != null) {
        await _handleIncomingLink(initialLink);
      }
    } catch (e) {
      throw ChangePasswordDeepLinkException(
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

  Future<void> _handleIncomingLink(Uri? uri) async {
    if (uri == null) return;

    try {
      _deepLinkStreamController.add(uri);

      if (isChangePasswordLink(uri)) {
        final success = await handleChangePasswordLink(uri);
      }
    } catch (e) {
      // Error handling tetap ada tapi tanpa print
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
      // Periksa scheme terlebih dahulu
      if (link.scheme != 'pockeat') {
        return false;
      }

      final mode = link.queryParameters['mode'];
      final oobCode = link.queryParameters['oobCode'];
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

      final oobCode = link.queryParameters['oobCode'];
      if (oobCode == null) {
        return false;
      }

      try {
        await _auth.checkActionCode(oobCode);
        return true;
      } on FirebaseAuthException catch (e) {
        throw ChangePasswordDeepLinkException(
          'Firebase auth error when verifying change password link :${e.message}',
          code: e.code,
          originalError: e,
        );
      } catch (e) {
        throw ChangePasswordDeepLinkException('Error checking action code',
            originalError: e);
      }
    } catch (e) {
      if (e is ChangePasswordDeepLinkException) {
        rethrow;
      }
      throw ChangePasswordDeepLinkException(
        'Error handling change password link',
        originalError: e,
      );
    }
  }

  @override
  // coverage:ignore-start
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
  // coverage:ignore-end
}
