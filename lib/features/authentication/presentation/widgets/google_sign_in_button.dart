// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isUnderTest;
  final GoogleSignInService? googleAuthService;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const GoogleSignInButton({
    super.key,
    this.isUnderTest = false,
    this.googleAuthService,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 55, // Match height dengan button login
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            final service = googleAuthService ?? GetIt.I<GoogleSignInService>();
            await service.signInWithGoogle();

            // Navigate to home page on successful login
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: isUnderTest
              ? const Text('G', style: TextStyle(fontWeight: FontWeight.bold))
              // coverage:ignore-start
              : Image.asset(
                  'assets/images/google.png',
                  height: 20,
                ),
          // coverage:ignore-end
        ),
        label: const Text(
          'Sign in with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Match dengan button login
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
