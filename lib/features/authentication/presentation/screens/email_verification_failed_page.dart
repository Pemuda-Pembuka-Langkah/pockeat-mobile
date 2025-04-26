// Flutter imports:
import 'package:flutter/material.dart';

class EmailVerificationFailedPage extends StatelessWidget {
  final String error;

  const EmailVerificationFailedPage({
    super.key,
    required this.error,
  });
  // coverage:ignore-line

  @override
  Widget build(BuildContext context) {
    // Warna yang sama dengan halaman lain untuk konsistensi
    const Color primaryPink = Color(0xFFFF6B6B);
    const Color bgColor = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon error
                Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.red[400],
                ),

                const SizedBox(height: 30),

                // Title
                Text(
                  'Email Verification Failed',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Error message
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Login button
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
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

                // Register button
                SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/register');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryPink),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'CREATE NEW ACCOUNT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: primaryPink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
