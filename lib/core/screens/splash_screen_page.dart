// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/authentication/services/login_service.dart';

/// Splash screen page shown when the app is launched
///
/// This page displays the app name and a loading animation
/// while checking the authentication status of the user.
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  // Colors - matching login page
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  // Animation controller for the loading animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Loading dots state
  bool _isFirstDotActive = true;
  bool _isSecondDotActive = false;
  bool _isThirdDotActive = false;
  Timer? _dotsTimer;

  // Store authentication result
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for loading effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.repeat(reverse: true);

    // Initialize dots animation
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        if (_isFirstDotActive) {
          _isFirstDotActive = false;
          _isSecondDotActive = true;
          _isThirdDotActive = false;
        } else if (_isSecondDotActive) {
          _isFirstDotActive = false;
          _isSecondDotActive = false;
          _isThirdDotActive = true;
        } else {
          _isFirstDotActive = true;
          _isSecondDotActive = false;
          _isThirdDotActive = false;
        }
      });
    });

    // Check auth immediately but delay navigation
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dotsTimer?.cancel();
    super.dispose();
  }

  /// Check authentication status immediately
  Future<void> _checkAuthStatus() async {
    final loginService = GetIt.instance<LoginService>();

    try {
      final user = await loginService.getCurrentUser();
      _isAuthenticated = user != null;

      // Delay navigation for 4 seconds to show splash screen
      Future.delayed(const Duration(seconds: 5), () {
        _navigateBasedOnAuth();
      });
    } catch (e) {
      _isAuthenticated = false;

      // Delay navigation for 4 seconds to show splash screen
      Future.delayed(const Duration(seconds: 5), () {
        _navigateBasedOnAuth();
      });
    }
  }

  /// Navigate based on stored authentication result
  void _navigateBasedOnAuth() {
    if (!mounted) return;

    if (_isAuthenticated == true) {
      // User is authenticated, navigate to home
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      // User is not authenticated, navigate to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App name with animation
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animation.value * 0.1),
                    child: Text(
                      'Pockeat',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: primaryPink,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your health companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              // Interactive loading animation with dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(_isFirstDotActive),
                  const SizedBox(width: 8),
                  _buildDot(_isSecondDotActive),
                  const SizedBox(width: 8),
                  _buildDot(_isThirdDotActive),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a single dot for the loading animation
  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryGreen : primaryPink.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
