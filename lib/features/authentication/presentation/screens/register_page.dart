// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/authentication/presentation/widgets/google_sign_in_button.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';

/// Registration page for new users
///
/// This page contains a form to fill registration data such as
/// email, password, name, birth date, and gender.
/// Users must also agree to the terms and conditions.
/// 
// coverage:ignore-start
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  // State for registration flow
  bool _isRegistrationSuccess = false;

  // Colors
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  late RegisterService _registerService;
  late AnalyticsService _analyticsService;
  // No gender options needed

  @override
  void initState() {
    super.initState();
    _registerService = GetIt.instance<RegisterService>();
    _analyticsService = GetIt.instance<AnalyticsService>();
    _analyticsService.logScreenView(
        screenName: 'register_page', screenClass: 'RegisterPage');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Handles the registration process
  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'You must agree to the terms and conditions';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _registerService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        termsAccepted: _termsAccepted,
        displayName: _nameController.text.trim(),
        birthDate: null,
        gender: null,
      );

      setState(() {
        _isLoading = false;
      });

      if (result == RegisterResult.success) {
        await _analyticsService.logSignUp(method: 'email');

        final uid = GetIt.instance<FirebaseAuth>().currentUser?.uid;

        if (uid != null && mounted) {
          final formCubit = context.read<HealthMetricsFormCubit>();
          formCubit.setUserId(uid);
          await formCubit.submit();
        }

        setState(() {
          _isRegistrationSuccess = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Registration successful! Please verify your email.'),
              backgroundColor: primaryGreen,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = _getErrorMessage(result);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  // Get error message based on registration result
  String _getErrorMessage(RegisterResult result) {
    switch (result) {
      case RegisterResult.emailAlreadyInUse:
        return 'Email is already in use. Please use a different email.';
      case RegisterResult.invalidEmail:
        return 'Invalid email format.';
      case RegisterResult.weakPassword:
        return 'Password is too weak. Use at least 8 characters with uppercase, lowercase, and numbers.';
      case RegisterResult.operationNotAllowed:
        return 'Operation not allowed.';
      case RegisterResult.unknown:
        return 'An error occurred. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Birth date selection removed

  // Resend verification email
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _registerService.resendEmailVerification();

      setState(() {
        _isLoading = false;
      });

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email has been resent.'),
            backgroundColor: primaryGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to send verification email. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
    
        if (didPop) return;
        // Jika user menekan tombol back, arahkan ke halaman login
        // daripada ke halaman utama yang memerlukan auth
        Navigator.pushReplacementNamed(context, '/login');
        
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _isRegistrationSuccess
                  ? _buildVerificationUI()
                  : _buildRegistrationForm(),
            ),
          ),
        ),
      ),
    );
  }

  // Registration form
  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Create New Account',
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
            'Sign up to start your health journey',
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

          // Full name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person),
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
                return 'Name cannot be empty';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

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
              hintText: 'Minimum 8 characters',
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
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              // Perbaiki validasi password agar lebih jelas dan mengikuti standar
              final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
              final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
              final hasDigit = RegExp(r'\d').hasMatch(value);
              final hasSpecialChar =
                  RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

              if (!hasUppercase) {
                return 'Password must contain at least 1 uppercase letter';
              }
              if (!hasLowercase) {
                return 'Password must contain at least 1 lowercase letter';
              }
              if (!hasDigit && !hasSpecialChar) {
                return 'Password must contain at least 1 number or symbol';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            obscuringCharacter: '•',
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Enter the same password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                return 'Confirm password cannot be empty';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Birth date and Gender fields removed

          const SizedBox(height: 20),

          // Terms and Conditions Checkbox
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  activeColor: primaryPink,
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                      if (_termsAccepted) {
                        _errorMessage = null;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(color: Colors.grey[700]),
                    children: [
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to Terms and Conditions page
                          },
                      ),
                      TextSpan(
                        text: ' of PockEat',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Register Button
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: primaryPink.withOpacity(0.5),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'SIGN UP',
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

          // Google Sign In Button
          const GoogleSignInButton(
            height: 55,
            isRegister: true, // Set to register mode
          ),

          const SizedBox(height: 20),

          // Link to login page
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: Colors.grey[700]),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      color: primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigate to login page
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Email verification UI
  Widget _buildVerificationUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Icon(Icons.mark_email_read, size: 100, color: primaryGreen),

        const SizedBox(height: 30),

        // Title
        Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryPink,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // Description
        Text(
          'We have sent a verification email to ${_emailController.text}. Please check your inbox or spam folder to verify.',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Resend email verification button
        SizedBox(
          height: 55,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _resendVerificationEmail,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryPink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'RESEND EMAIL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: primaryPink,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Back to login button
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text(
            'Back to Sign In',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end