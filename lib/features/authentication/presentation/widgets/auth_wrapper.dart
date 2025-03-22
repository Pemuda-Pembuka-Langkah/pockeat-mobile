import 'dart:async';
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
  final _navigatorKey = GlobalKey<NavigatorState>();
  Stream<UserModel?>? _authStream;
  bool _isInitialized = false;
  StreamSubscription<UserModel?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();
    _initAuth();
  }

  void _initAuth() {
    // Only initialize auth if we require authentication
    if (widget.requireAuth) {
      print('🔒 AuthWrapper: Initializing auth for protected route');
      _authStream = _loginService.initialize(_navigatorKey);

      // Store the subscription so we can cancel it when disposed
      _authSubscription = _authStream?.listen((user) {
        print(
            '🔒 AuthWrapper: Auth state updated - User ${user != null ? 'authenticated' : 'not authenticated'}');
      });

      _isInitialized = true;
    } else {
      print('🔒 AuthWrapper: Auth not required for this route');
    }
  }

  @override
  void dispose() {
    // Clean up resources when widget is disposed
    if (_isInitialized) {
      print('🔒 AuthWrapper: Disposing auth stream subscription');
      _authSubscription?.cancel();

      // If using a service with dispose method
      // We don't call _loginService.dispose() here to avoid affecting other pages
      // that might be using the same service instance
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If this page doesn't require authentication, just show the child
    if (!widget.requireAuth) {
      return widget.child;
    }

    // If auth is required, we need to check the authentication state
    return FutureBuilder<UserModel?>(
      future: _loginService.getCurrentUser(),
      builder: (context, snapshot) {
        // If we have data from direct check, user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          print(
              '🔒 AuthWrapper: User already authenticated via direct check: ${snapshot.data?.email}');
          return widget.child;
        }

        // If we're still loading the future but don't have an error, show the child
        // This improves user experience - we'll redirect later if auth fails
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasError) {
          print(
              '🔒 AuthWrapper: Auth check in progress, showing content optimistically');
          return widget.child;
        }

        // If direct check failed, use stream as fallback
        return StreamBuilder<UserModel?>(
          stream: _authStream,
          builder: (context, streamSnapshot) {
            // If the user is authenticated via stream, show the child
            if (streamSnapshot.hasData && streamSnapshot.data != null) {
              print(
                  '🔒 AuthWrapper: User authenticated via stream, showing content: ${streamSnapshot.data?.email}');
              return widget.child;
            }

            // If we're waiting for stream data but don't have an error, show child optimistically
            if (streamSnapshot.connectionState == ConnectionState.waiting &&
                !streamSnapshot.hasError) {
              print(
                  '🔒 AuthWrapper: Stream check in progress, showing content optimistically');
              return widget.child;
            }

            // Only if both auth methods have failed, redirect to login
            print(
                '🔒 AuthWrapper: User definitely not authenticated, redirecting to login');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });

            // Show child instead of loading while redirecting for better UX
            return widget.child;
          },
        );
      },
    );
  }
}
