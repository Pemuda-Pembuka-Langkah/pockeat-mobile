import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A wrapper widget that handles authentication state
/// and redirects users to the appropriate screens
class AuthWrapper extends StatefulWidget {
  /// The child widget to display when the user is authenticated
  final Widget child;

  /// Whether this page requires authentication
  final bool requireAuth;

  const AuthWrapper({
    Key? key,
    required this.child,
    this.requireAuth = true,
  }) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final LoginService _loginService;
  bool _didInitAuth = false;
  bool _hasCheckedHealthMetrics = false;

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();

    // Cek auth hanya jika diperlukan
    if (widget.requireAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeUserFlow();
      });
    }
  }

  Future<void> _initializeUserFlow() async {
    if (_didInitAuth) return;
    _didInitAuth = true;

    final user = await _checkAuth();
    if (user == null) return;

    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Only check health metrics from the home/root screen to avoid double redirects
    if (!_hasCheckedHealthMetrics &&
        currentRoute != null &&
        currentRoute == '/') {
      _hasCheckedHealthMetrics = true;
      await _checkHealthMetrics(user.uid);
    }
  }

  Future<UserModel?> _checkAuth() async {
    try {
      final user = await _loginService.getCurrentUser();
      if (user == null && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return user;
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return null;
    }
  }

  Future<void> _checkHealthMetrics(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('health_metrics')
          .doc(uid)
          .get();

      final needsOnboarding = !doc.exists;
      final currentRoute = ModalRoute.of(context)?.settings.name;

      if (needsOnboarding &&
          mounted &&
          currentRoute != '/onboarding/goal') {
        Navigator.of(context).pushReplacementNamed('/onboarding/goal');
      }
    } catch (e) {
      debugPrint("Error checking health metrics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}