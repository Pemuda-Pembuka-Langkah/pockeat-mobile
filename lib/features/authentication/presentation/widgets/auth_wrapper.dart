import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';

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
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Jika terjadi error, asumsikan user tidak terautentikasi
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Selalu render child tanpa kondisi
    return widget.child;
  }
}
