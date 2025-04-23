import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:lottie/lottie.dart'; // Add this package

/// Splash screen page shown when the app is launched
///
/// This page displays the app logo, panda animation, and loading animation
/// while checking the authentication status of the user.
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  // Colors - matching design
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9); // Light background
  final Color logoBlue = const Color(0xFF8FE0D7); // Light blue for "POCK"
  final Color logoOrange = const Color(0xFFFF6633); // Orange for "EAT"
  final Color circleColor = const Color(0xFFFF6B6B); // Red circle background

  // Store authentication result
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();

    // Check auth immediately but delay navigation
    _checkAuthStatus();
  }

  /// Check authentication status immediately
  Future<void> _checkAuthStatus() async {
    final loginService = GetIt.instance<LoginService>();

    try {
      final user = await loginService.getCurrentUser();
      _isAuthenticated = user != null;

      // Delay navigation for 5 seconds to show splash screen
      Future.delayed(const Duration(seconds: 5), () {
        _navigateBasedOnAuth();
      });
    } catch (e) {
      _isAuthenticated = false;

      // Delay navigation for 5 seconds to show splash screen
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
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.6; // Adjust size as needed
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pockeat Logo
              Image.asset(
                'assets/icons/LogoPanjang_PockEat_draft_transparent.png', 
                width: size.width * 0.6,
                // Or use a custom logo widget if needed
                // _buildCustomLogo(),
              ),
              
              const SizedBox(height: 60), // 30px spacing as per design
              
              // Red circle and panda
              Stack(
                alignment: Alignment.center,
                children: [
                  // Red circle background
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  // Panda animation
                  SizedBox(
                    width: circleSize * 1, // Slightly smaller than the circle
                    height: circleSize * 1,
                    child: Lottie.asset(
                      'assets/animations/Panda Happy Jump.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}