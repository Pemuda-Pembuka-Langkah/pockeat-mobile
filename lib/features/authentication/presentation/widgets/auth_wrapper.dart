// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final onboardingInProgress = prefs.getBool('onboardingInProgress') ?? false;

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
          final healthMetricsCheckService = GetIt.instance<HealthMetricsCheckService>();
          final completed = await healthMetricsCheckService.hasCompletedOnboarding(user.uid);

          final currentRoute = ModalRoute.of(context)?.settings.name;
          final isInsideOnboardingFlow = currentRoute?.startsWith('/onboarding') ?? false;

          if ((!completed && !onboardingInProgress) && !isInsideOnboardingFlow) {
            _redirect('/height-weight', removeUntil: true);
          } else {
            setState(() {
              _isAuthenticated = true;
              _isChecking = false;
            });
          }
        } else {
          // If no auth required, but user is logged in → redirect anyway
          Navigator.of(context).pushReplacementNamed(widget.redirectUrlIfLoggedIn);
        }
      }
    } catch (e) {
      // Jika terjadi error, asumsikan user tidak terautentikasi
      if (mounted) {
        Navigator.of(context).pushNamed(widget.redirectUrlIfNotLoggedIn);
      }
    }
  }

  Future<void> _checkHealthMetrics(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingInProgress =
          prefs.getBool('onboardingInProgress') ?? false;

      final healthMetricsCheckService =
          GetIt.instance<HealthMetricsCheckService>();
      final completed =
          await healthMetricsCheckService.hasCompletedOnboarding(uid);

      // ignore: use_build_context_synchronously
      final currentRoute = ModalRoute.of(context)?.settings.name;
      final isInsideOnboardingFlow =
          currentRoute?.startsWith('/onboarding') ?? false;

    // 🛑 Jangan redirect kalau user udah dalam onboarding atau lagi ngisi
    if ((!completed && !onboardingInProgress) && mounted && !isInsideOnboardingFlow) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/onboarding/goal',
        (route) => false,
      );

    }
  } catch (e) {
    debugPrint("Error checking health metrics: $e");
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