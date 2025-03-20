// ignore_for_file: avoid_print

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinkServiceImpl implements DeepLinkService {
  final FirebaseAuth _auth;
  final FirebaseDynamicLinks _dynamicLinks;

  StreamSubscription? _deepLinkSub;
  final StreamController<Uri?> _deepLinkStreamController =
      StreamController<Uri?>.broadcast();

  DeepLinkServiceImpl({
    FirebaseAuth? auth,
    FirebaseDynamicLinks? dynamicLinks,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  @override
  Future<void> initialize() async {
    // 1. Handle initial link (app opened from a link)
    try {
      final initialLink = getInitialLink();
      initialLink.listen((Uri? link) {
        if (link != null) {
          _handleIncomingLink(link);
        }
      });
    } catch (_) {
      
    }

    // 2. Handle links while app is running
    _deepLinkSub = onLinkReceived().listen((Uri? link) {
      if (link != null) {
        _handleIncomingLink(link);
      }
    }, onError: (err) {
      print('Error listening to deep links: $err');
    });

    // 3. Handle Firebase Dynamic Links
    _dynamicLinks.onLink.listen((PendingDynamicLinkData dynamicLinkData) {
      final Uri deepLink = dynamicLinkData.link;
      _handleIncomingLink(deepLink);
    }).onError((error) {
      print('Error handling firebase dynamic link: $error');
    });
  }

  void _handleIncomingLink(Uri link) {
    print('Received deep link: $link');

    // Push the link to the stream
    _deepLinkStreamController.add(link);

    // Handle email verification link automatically
    if (isEmailVerificationLink(link)) {
      handleEmailVerificationLink(link);
    }
  }

  @override
  Stream<Uri?> getInitialLink() async* {
    try {
      final initialLink = await getInitialUri();
      if (initialLink != null) {
        yield initialLink;
      }
    } catch (e) {
      print('Error retrieving initial uri: $e');
    }
  }

  @override
  Stream<Uri?> onLinkReceived() {
    uriLinkStream.listen((Uri? link) {
      if (link != null) {
        _deepLinkStreamController.add(link);
      }
    }, onError: (err) {
      print('Error in URI link stream: $err');
    });

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
        return false;
      }

      // Check if it's a valid action code
      try {
        await _auth.checkActionCode(oobCode);

        // Apply the action code (verify email)
        await _auth.applyActionCode(oobCode);

        // Reload the user to update emailVerified status
        await _auth.currentUser?.reload();

        return _auth.currentUser?.emailVerified ?? false;
      } catch (e) {
        print('Error applying action code: $e');
        return false;
      }
    } catch (e) {
      print('Error handling email verification link: $e');
      return false;
    }
  }

  @override
  bool isEmailVerificationLink(Uri link) {
    // Check for Firebase Auth email verification link pattern
    // Common patterns:
    // - Contains "mode=verifyEmail" parameter
    // - Contains "apiKey" parameter
    // - Contains "oobCode" parameter

    final params = link.queryParameters;
    return link.host.contains('firebaseapp.com') &&
        (params.containsKey('mode') && params['mode'] == 'verifyEmail') &&
        params.containsKey('oobCode');
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    _deepLinkStreamController.close();
  }
}
