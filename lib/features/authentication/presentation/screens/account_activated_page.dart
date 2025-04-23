import 'package:flutter/material.dart';

class AccountActivatedPage extends StatelessWidget {
  final String email;
  final VoidCallback? onHomeTap;

  const AccountActivatedPage({
    super.key,
    required this.email,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warna yang sama dengan RegisterPage untuk konsistensi
    const Color primaryGreen = Color(0xFF4ECDC4);
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
                // Icon sukses
                const Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: primaryGreen,
                ),

                const SizedBox(height: 30),

                // Title
                const Text(
                  'Account Successfully Activated!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Description
                Text(
                  'Email $email has been successfully verified. You can now use all features of PockEat.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Continue button
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Panggil callback jika ada
                      if (onHomeTap != null) {
                        onHomeTap!();
                      } else {
                        // Navigasi default ke home page
                        // coverage:ignore-line
                        Navigator.of(context).pushReplacementNamed('/');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
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
