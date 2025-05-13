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
  bool _isChecking = true;
  // ignore: unused_field
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    try {
      final user = await _loginService.getCurrentUser();

      if (user == null) {
        // Tidak login
        if (widget.requireAuth) {
          _redirect(widget.redirectUrlIfNotLoggedIn, replace: true);
        } else {
          setState(() {
            _isAuthenticated = false;
            _isChecking = false;
          });
        }
      } else {
        // Login
        if (widget.requireAuth) {
          final healthMetricsCheckService =
              GetIt.instance<HealthMetricsCheckService>();
          final isOnboardingCompleted =
              await healthMetricsCheckService.hasCompletedOnboarding(user.uid);
          if (!mounted) {
            return;
          }
          debugPrint('isOnboardingCompleted: $isOnboardingCompleted');
          if (!isOnboardingCompleted) {
            Navigator.of(context).pushReplacementNamed('/height-weight');
          } else {
            setState(() {
              _isAuthenticated = true;
              _isChecking = false;
            });
          }
        } else {
          _redirect(widget.redirectUrlIfLoggedIn, replace: true);
        }
      }
    } catch (e) {
      debugPrint('Error during auth check: $e');
      if (widget.requireAuth) {
        _redirect(widget.redirectUrlIfNotLoggedIn, replace: true);
      } else {
        setState(() {
          _isAuthenticated = false;
          _isChecking = false;
        });
      }
    }
  }

  void _redirect(String route,
      {bool removeUntil = false, bool replace = false}) {
    if (!mounted) return;
    if (removeUntil) {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    } else if (replace) {
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return widget.child;
  }
}
