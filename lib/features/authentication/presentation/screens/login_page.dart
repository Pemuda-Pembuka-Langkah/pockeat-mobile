// Flutter imports:
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/authentication/presentation/widgets/google_sign_in_button.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

/// Login page for existing users
///
/// This page contains a form to input login credentials such as
/// email and password. Users can also navigate to registration page
/// or request password reset.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // Colors
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  late LoginService _loginService;
  late AnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();
    _analyticsService = GetIt.instance<AnalyticsService>();
    _analyticsService.logScreenView(
        screenName: 'login_page', screenClass: 'LoginPage');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle login
  Future<void> _login() async {
    // Close keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loginService.loginByEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if email is verified
      final isEmailVerified = await _loginService.isEmailVerified();

      if (!isEmailVerified) {
        // If email is not verified, show error and don't proceed with login
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Please verify your email before logging in. Check your inbox for a verification link.';
        });

        // Navigate to email verification page
        if (mounted) {
          Navigator.pushNamed(context, '/email-verification',
              arguments: {'email': _emailController.text.trim()});
        }
        return;
      }

      // Synchronize user preferences from local storage to Firebase
      final userPreferencesService = GetIt.instance<UserPreferencesService>();
      await userPreferencesService.synchronizePreferencesAfterLogin();

      setState(() {
        _isLoading = false;
      });

      // Navigate to home page on successful login
      if (mounted) {
        // Log successful login event
        await _analyticsService.logLogin(method: 'email');
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  // Get error message based on exception
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Email not registered. Please check your email or register first.';
        case 'wrong-password':
          return 'Incorrect password. Please check your password.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact admin.';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        case 'invalid-email':
          return 'Invalid email format. Please check your email.';
        case 'operation-not-allowed':
          return 'Login with email and password is not allowed. Please use another login method.';
        case 'network-request-failed':
          return 'Network problem occurred. Please check your internet connection.';
        case 'email-not-verified':
          return 'Please verify your email before logging in. Check your inbox for a verification link or tap "Resend Verification Email" below.';
        default:
          return 'Login failed: ${error.message ?? error.code}';
      }
    }

    return 'An unexpected error occurred during login. Please try again later.';
  }

  // Function to handle resending verification email
  Future<void> _resendVerificationEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage =
            'Please enter your email address to resend verification.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try to sign in with the provided email to get a user object
      await _loginService.loginByEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // If we get here, we have a user, so try to send verification email
      final success = await _loginService.sendEmailVerification();

      setState(() {
        _isLoading = false;
        if (success) {
          _errorMessage =
              'Verification email sent! Please check your inbox and spam folder.';
        } else {
          _errorMessage =
              'Failed to send verification email. Please try again later.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is FirebaseAuthException && e.code == 'email-not-verified') {
          // This is fine - we want to send the verification email
          _errorMessage =
              'Verification email sent! Please check your inbox and spam folder.';
        } else {
          _errorMessage = _getErrorMessage(e);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if the /welcome route exists in the route stack
        bool welcomeExists = false;
        Navigator.popUntil(context, (route) {
          if (route.settings.name == '/welcome') {
            welcomeExists = true;
            return true;
          }
          return false;
        });

        // If /welcome doesn't exist in the route stack, exit the app
        if (!welcomeExists) {
          // Exit the app
          SystemNavigator.pop();
        }

        // Always return false as we're handling navigation manually
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildLoginForm(),
            ),
          ),
        ),
      ),
    );
  }

  // Login form
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryPink,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Sign in to continue your health journey',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          if (_errorMessage != null) const SizedBox(height: 20),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPink),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email cannot be empty';
              }
              // Email format validation
              final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegExp.hasMatch(value)) {
                return 'Invalid email format';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            obscuringCharacter: '•',
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPink),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password cannot be empty';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // Navigate to forgot password page
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: primaryPink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Login Button
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: primaryGreen.withOpacity(0.5),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // Or divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Resend verification email button - only shown when there's an email verification error
          if (_errorMessage != null &&
              _errorMessage!.contains('verify your email'))
            Column(
              children: [
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryPink,
                    side: BorderSide(color: primaryPink),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Resend Verification Email'),
                ),
                const SizedBox(height: 20),
              ],
            ), // Google Sign In Button
          const GoogleSignInButton(
            height: 55, // Sama dengan button sign in
          ),

          // Small space after Google button
          const SizedBox(height: 16),

          // Subtle "Start Over" button right under Google signin
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Double tap check to prevent accidental navigation
                  final currentTime = DateTime.now();
                  if (_lastTapTime != null &&
                      currentTime.difference(_lastTapTime!).inMilliseconds <
                          300) {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('Start Over?',
                            style: TextStyle(
                                color: primaryPink,
                                fontWeight: FontWeight.bold)),
                        content: const Text('Return to the welcome screen?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(
                                  context, '/welcome');
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  }
                  _lastTapTime = currentTime;
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        'Start Over',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Used for double-tap detection
  DateTime? _lastTapTime;
}
