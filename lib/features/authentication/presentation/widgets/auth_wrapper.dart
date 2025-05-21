// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';

/// A wrapper widget that handles authentication state
/// and redirects users to the appropriate screens
class AuthWrapper extends StatefulWidget {
  final Widget child;
  final bool requireAuth;
  final String redirectUrlIfLoggedIn;
  final String redirectUrlIfNotLoggedIn;

  const AuthWrapper({
    super.key,
    required this.child,
    this.requireAuth = true,
    this.redirectUrlIfLoggedIn = '/',
    this.redirectUrlIfNotLoggedIn = '/welcome',
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final LoginService _loginService;

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();
    // Schedule the auth check for after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  /// Checks if the user's email is verified and handles redirection if not
  Future<bool> _checkEmailVerification(UserModel user) async {
    final isEmailVerified = await _loginService.isEmailVerified();

    if (!isEmailVerified) {
      debugPrint('Email not verified, redirecting to verification screen');
      // Get the user's email for the verification page
      final email = user.email;

      // Sign out the user as they shouldn't be able to bypass verification
      // This prevents auto-login until email is verified
      await FirebaseAuth.instance.signOut();

      if (!mounted) return false;

      // Redirect to email verification page with the user's email
      _redirect('/email-verification',
          arguments: {'email': email}, replace: true);
      return false;
    }

    return true;
  }

  Future<void> _checkAuth() async {
    debugPrint('Checking auth state...');
    if (!mounted) return;

    try {
      final user = await _loginService.getCurrentUser();
      debugPrint('Active User: $user');
      if (!mounted) return;

      if (user == null) {
        // Not logged in
        if (widget.requireAuth) {
          _redirect(widget.redirectUrlIfNotLoggedIn, replace: true);
        } else {
          setState(() {});
        }
      } else {
        // Use our helper method to check email verification
        if (!await _checkEmailVerification(user)) {
          return; // Email verification check will handle redirection
        }

        // Logged in and email verified
        if (widget.requireAuth) {
          final healthMetricsCheckService =
              GetIt.instance<HealthMetricsCheckService>();
          final isOnboardingCompleted =
              await healthMetricsCheckService.hasCompletedOnboarding(user.uid);
          debugPrint('isOnboardingCompleted: $isOnboardingCompleted');

          if (!mounted) return;

          if (!isOnboardingCompleted) {
            // Redirect to the Not Completed Onboarding page instead of directly to height-weight
            _redirect('/not-completed-onboarding', replace: true);
          } else {
            setState(() {});
          }
        } else {
          _redirect(widget.redirectUrlIfLoggedIn, replace: true);
        }
      }
    } catch (e) {
      debugPrint('Error during auth check: $e');
      if (!mounted) return;

      if (widget.requireAuth) {
        _redirect(widget.redirectUrlIfNotLoggedIn, replace: true);
      } else {
        setState(() {});
      }
    }
  }

  void _redirect(String route,
      {bool removeUntil = false,
      bool replace = false,
      Map<String, dynamic>? arguments}) {
    if (!mounted) return;

    // Schedule navigation for after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (removeUntil) {
        Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false,
            arguments: arguments);
      } else if (replace) {
        Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
      } else {
        Navigator.of(context).pushNamed(route, arguments: arguments);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Instead of showing loading indicator, show the child immediately
    // The auth check will handle redirection if needed
    return widget.child;
  }
}
