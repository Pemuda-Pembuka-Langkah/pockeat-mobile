import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service_impl.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/email_verification_deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/domain/model/deep_link_result.dart';

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
  final StreamController<DeepLinkResult> _resultStreamController =
      StreamController<DeepLinkResult>.broadcast();
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
  Stream<DeepLinkResult> get onDeepLinkResult => _resultStreamController.stream;

  @override
  Future<void> initialize() async {
    await _emailVerificationService.initialize();
    await _changePasswordService.initialize();

    try {
      final initialLink = await getInitialAppLink();
      if (initialLink != null) {
        await handleDeepLink(initialLink);
      }
    } catch (e) {
      throw DeepLinkException(
        'Failed to initialize initial link handler',
        originalError: e,
      );
    }

    try {
      _appLinksSub = getUriLinkStream().listen(
        (Uri uri) {
          handleDeepLink(uri);
        },
        onError: (error) {
          throw DeepLinkException(
            'Error in app link stream',
            originalError: error,
          );
        },
      );
    } catch (e) {
      throw DeepLinkException(
        'Failed to setup deep link listener',
        originalError: e,
      );
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
  
  // Method untuk mengecek apakah link dari widget quick log
  bool _isQuickLogLink(Uri link) {
    // Cek apakah link memiliki scheme pockeat
    if (link.scheme != 'pockeat') return false;
    
    // Cek adanya parameter widgetName dan type = log
    final hasWidgetName = link.queryParameters.containsKey('widgetName');
    final hasType = link.queryParameters.containsKey('type');
    final type = link.queryParameters['type'];
    
    return hasWidgetName && hasType && type == 'log';
  }
  
  // Method untuk mengecek apakah link dari widget login
  bool _isLoginLink(Uri link) {
    // Cek apakah link memiliki scheme pockeat
    if (link.scheme != 'pockeat') return false;
    
    // Cek adanya parameter widgetName dan type = login
    final hasWidgetName = link.queryParameters.containsKey('widgetName');
    final hasType = link.queryParameters.containsKey('type');
    final type = link.queryParameters['type'];
    
    return hasWidgetName && hasType && type == 'login';
  }
  
  // Method untuk mengecek apakah link ke dashboard/home
  bool _isDashboardLink(Uri link) {
    // Cek apakah link memiliki scheme pockeat
    if (link.scheme != 'pockeat') return false;
    
    // Cek adanya parameter widgetName dan type = dashboard atau home
    final hasWidgetName = link.queryParameters.containsKey('widgetName');
    final hasType = link.queryParameters.containsKey('type');
    final type = link.queryParameters['type'];
    
    return hasWidgetName && hasType && (type == 'dashboard' || type == 'home');
  }

 // coverage:ignore-start
  @override
  Future<bool> handleDeepLink(Uri link,
      [BuildContext? navigationContext]) async {
    try {
      // Gunakan helper method untuk mendapatkan DeepLinkResult
      final result = await _getDeepLinkResult(link);
      
      // Broadcast hasil ke stream
      _resultStreamController.add(result);
      
      // Return success status dari result
      return result.success;
    } catch (e) {
      final result = DeepLinkResult.unknown(
        originalUri: link,
        error: 'Error saat memproses deep link: $e',
      );

      _resultStreamController.add(result);
      throw DeepLinkException('Error handling deep link', originalError: e);
    }
    // coverage:ignore-end
  }



  // Helper method untuk mendapatkan DeepLinkResult dari Uri
  Future<DeepLinkResult> _getDeepLinkResult(Uri uri) async {
    if (_isEmailVerificationLink(uri)) {
      try {
        final bool success =
            await _emailVerificationService.handleEmailVerificationLink(uri);

        return DeepLinkResult.emailVerification(
          success: success,
          data: {
            'email': FirebaseAuth.instance.currentUser?.email ?? '',
          },
          originalUri: uri,
        );
      } catch (e) {
        return DeepLinkResult.emailVerification(
          success: false,
          error: e.toString(),
          originalUri: uri,
        );
      }
    } else if (_isChangePasswordLink(uri)) {
      try {
        final bool success =
            await _changePasswordService.handleChangePasswordLink(uri);
        final String? oobCode = uri.queryParameters['oobCode'];
        return DeepLinkResult.changePassword(
          success: success,
          data: {
            'oobCode': oobCode,
          },
          originalUri: uri,
        );
      } catch (e) {
        return DeepLinkResult.changePassword(
          success: false,
          error: e.toString(),
          originalUri: uri,
        );
      }
    } else if (_isQuickLogLink(uri)) {
      try {
        final widgetName = uri.queryParameters['widgetName'] ?? '';
        final type = uri.queryParameters['type'] ?? '';
        
        return DeepLinkResult.quickLog(
          success: true,
          data: {
            'widgetName': widgetName,
            'type': type,
          },
          originalUri: uri,
        );
      } catch (e) {
        return DeepLinkResult.quickLog(
          success: false,
          error: e.toString(),
          originalUri: uri,
        );
      }
    } else if (_isLoginLink(uri)) {
      try {
        final widgetName = uri.queryParameters['widgetName'] ?? '';
        
        return DeepLinkResult.login(
          success: true,
          data: {
            'widgetName': widgetName,
          },
          originalUri: uri,
        );
      } catch (e) {
        return DeepLinkResult.login(
          success: false,
          error: e.toString(),
          originalUri: uri,
        );
      }
    } else if (_isDashboardLink(uri)) {
      try {
        final widgetName = uri.queryParameters['widgetName'] ?? '';
        
        return DeepLinkResult.dashboard(
          success: true,
          data: {
            'widgetName': widgetName,
          },
          originalUri: uri,
        );
      } catch (e) {
        return DeepLinkResult.dashboard(
          success: false,
          error: e.toString(),
          originalUri: uri,
        );
      }
    } else {
      return DeepLinkResult.unknown(
        originalUri: uri,
        error: 'Tidak ada handler yang sesuai untuk link ini',
      );
    }
  }

  @override
  Future<DeepLinkResult?> getColdStartResult() async {
    try {
      final initialLink = await getInitialAppLink();
      if (initialLink == null) {
        return null;
      }
      
      return await _getDeepLinkResult(initialLink);
    } catch (e) {
      throw DeepLinkException(
        'Error getting cold start result',
        originalError: e,
      );
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
      _resultStreamController.close();
    } catch (e) {
      throw DeepLinkException('Error disposing deep link service',
          originalError: e);
    }
  }
}
