// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
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
        // Logged in
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
      {bool removeUntil = false, bool replace = false}) {
    if (!mounted) return;

    // Schedule navigation for after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (removeUntil) {
        Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
      } else if (replace) {
        Navigator.of(context).pushReplacementNamed(route);
      } else {
        Navigator.of(context).pushNamed(route);
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
