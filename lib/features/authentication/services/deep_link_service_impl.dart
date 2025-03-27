import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service_impl.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/email_verification_deep_link_service_impl.dart';

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

/// Implementasi DeepLinkService menggunakan pola Facade
/// yang menggabungkan EmailVerificationDeepLinkService dan ChangePasswordDeepLinkService
class DeepLinkServiceImpl implements DeepLinkService {
  final EmailVerificationDeepLinkService _emailVerificationService;
  final ChangePasswordDeepLinkService _changePasswordService;
  final StreamController<Uri?> _deepLinkStreamController =
      StreamController<Uri?>.broadcast();
  final AppLinks _appLinks = AppLinks();

  StreamSubscription? _appLinksSub;
  StreamSubscription? _emailVerificationLinkSub;
  StreamSubscription? _changePasswordLinkSub;

  DeepLinkServiceImpl({
    EmailVerificationDeepLinkService? emailVerificationService,
    ChangePasswordDeepLinkService? changePasswordService,
    FirebaseAuth? auth,
  })  : _emailVerificationService = emailVerificationService ??
            EmailVerificationDeepLinkServiceImpl(auth: auth),
        _changePasswordService = changePasswordService ??
            ChangePasswordDeepLinkServiceImpl(auth: auth);

  // Getter dan metode untuk mempermudah unit testing
  @visibleForTesting
  Future<Uri?> getInitialAppLink() => _appLinks.getInitialAppLink();

  @visibleForTesting
  Stream<Uri> getUriLinkStream() => _appLinks.uriLinkStream;

  @override
  Future<void> initialize(
      {required GlobalKey<NavigatorState> navigatorKey}) async {
    try {
      // 1. Handle initial link (app opened from a link)
      final initialLink = await getInitialAppLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }

      // 2. Handle links while app is running
      _appLinksSub = getUriLinkStream().listen(
        _handleIncomingLink,
        onError: (error) {
          throw DeepLinkException('Error in app link stream',
              originalError: error);
        },
      );

      // Initialize services tapi tidak pasang listener karena service utama sudah mendengarkan
      await _emailVerificationService.initialize(navigatorKey: navigatorKey);
      await _changePasswordService.initialize(navigatorKey: navigatorKey);
    } catch (e) {
      throw DeepLinkException('Failed to initialize deep link services',
          originalError: e);
    }
  }

  void _handleIncomingLink(Uri link) async {
    try {
      // Memproses link dengan memanggil handler yang sesuai
      await handleDeepLink(link);

      // Broadcast link to stream for other listeners
      _deepLinkStreamController.add(link);
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

  // Private method untuk mengecek jenis link
  bool _isEmailVerificationLink(Uri link) {
    return _emailVerificationService.isEmailVerificationLink(link);
  }

  // Private method untuk mengecek jenis link
  bool _isChangePasswordLink(Uri link) {
    return _changePasswordService.isChangePasswordLink(link);
  }

  @override
  Future<bool> handleDeepLink(Uri link) async {
    try {
      // Tentukan jenis link dan teruskan ke handler yang sesuai
      if (_isEmailVerificationLink(link)) {
        return await _emailVerificationService
            .handleEmailVerificationLink(link);
      } else if (_isChangePasswordLink(link)) {
        return await _changePasswordService.handleChangePasswordLink(link);
      } else {
        // Jika tidak ada handler yang sesuai
        return false;
      }
    } catch (e) {
      throw DeepLinkException('Error handling deep link', originalError: e);
    }
  }

  @override
  void dispose() {
    try {
      _appLinksSub?.cancel();
      _emailVerificationService.dispose();
      _changePasswordService.dispose();
      _emailVerificationLinkSub?.cancel();
      _changePasswordLinkSub?.cancel();
      _deepLinkStreamController.close();
    } catch (e) {
      throw DeepLinkException('Error disposing deep link service',
          originalError: e);
    }
  }
}
