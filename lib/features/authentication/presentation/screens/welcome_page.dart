import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _navigateTo(String routeName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
      if (!mounted) return;
      Navigator.of(context).pushNamed(routeName);
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or app name
                Text(
                  'Pockeat',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: primaryPink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your health companion',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  ElevatedButton(
                    onPressed: () => _navigateTo('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: Size(size.width * 0.7, 48),
                    ),
                    child: const Text('Log In'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _navigateTo('/onboarding/goal'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(size.width * 0.7, 48),
                      side: BorderSide(color: primaryPink),
                      foregroundColor: primaryPink,
                    ),
                    child: const Text('Get Started'),
                  ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}