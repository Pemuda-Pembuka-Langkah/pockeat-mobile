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
  /// The child widget to display when the user is authenticated
  final Widget child;

  /// Whether this page requires authentication
  final bool requireAuth;

  /// Where to redirect if user is logged in
  final String redirectUrlIfLoggedIn;

  /// Where to redirect if user is not logged in
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
  bool _didInitAuth = false;

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();

    // Cek auth hanya jika diperlukan
    if (widget.requireAuth) {
      // Jangan langsung navigasi di initState, gunakan scheduleFuture
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAuth();
      });
    }
  }

  Future<void> _checkAuth() async {
    if (_didInitAuth) return; // Cegah pengecekan berulang
    _didInitAuth = true;

    try {
      final user = await _loginService.getCurrentUser();

      // Redirect ke login jika tidak terautentikasi dan widget masih mounted
      if (user == null && mounted) {
        // User not logged in -> go to redirectUrlIfNotLoggedIn
        Navigator.of(context).pushNamed(widget.redirectUrlIfNotLoggedIn);
      } else if (user != null && mounted) {
        // User is logged in
        if (widget.requireAuth) {
          // Perform health metrics check only if required
          await _checkHealthMetrics(user.uid);
        } else {
          // If no auth required, but user is logged in → redirect anyway
          Navigator.of(context)
              .pushReplacementNamed(widget.redirectUrlIfLoggedIn);
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
      if ((!completed && !onboardingInProgress) &&
          mounted &&
          !isInsideOnboardingFlow) {
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
    // Selalu render child tanpa kondisi
    return widget.child;
  }
}
