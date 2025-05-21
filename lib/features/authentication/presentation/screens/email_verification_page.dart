// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  bool _isLoading = false;
  bool _isEmailSent = false;
  String? _errorMessage;
  Timer? _verificationTimer;
  final int _checkInterval = 300; // seconds (5 minutes)
  int _countdown = 60;
  bool _canResendEmail = false;
  late LoginService _loginService;
  late RegisterService _registerService;

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();
    _registerService = GetIt.instance<RegisterService>();

    // Start timer to periodically check verification status
    _startVerificationCheck();

    // Start countdown for resend button
    _startResendCountdown();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    // Check verification status every few seconds
    _verificationTimer = Timer.periodic(
        Duration(seconds: _checkInterval), (_) => _checkEmailVerification());
  }

  void _startResendCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResendEmail = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      final isVerified = await _loginService.isEmailVerified();

      if (isVerified) {
        _verificationTimer?.cancel();
        // Navigate to homepage if verified
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } catch (e) {
      // Just continue checking
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _registerService.resendEmailVerification();

      setState(() {
        _isLoading = false;
        _isEmailSent = success;
        _canResendEmail = false;
        _countdown = 60;

        if (!success) {
          _errorMessage =
              'Failed to send verification email. Please try again.';
        }
      });

      // Restart countdown if email was sent successfully
      if (success) {
        _startResendCountdown();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent going back
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email icon or animation
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.email_outlined,
                          size: 80,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Title
                  Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryPink,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'We\'ve sent a verification link to:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Email
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please check your email and follow the verification link',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Once verified, you will be automatically redirected to the app',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Message about waiting time
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.timer, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sorry for the inconvenience, this may take a while. The page refreshes automatically every 5 minutes.',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Success message
                  if (_isEmailSent)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verification email sent successfully!',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Resend button
                  SizedBox(
                    height: 55,
                    child: OutlinedButton(
                      onPressed: _canResendEmail && !_isLoading
                          ? _resendVerificationEmail
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: BorderSide(
                            color:
                                _canResendEmail ? primaryGreen : Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledForegroundColor: Colors.grey.withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              _canResendEmail
                                  ? 'Resend Verification Email'
                                  : 'Resend Email in $_countdown seconds',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign out button
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
