import 'package:flutter/material.dart';

class AccountActivatedPage extends StatelessWidget {
  final String email;
  final VoidCallback? onHomeTap;
  final VoidCallback? onLoginTap;

  const AccountActivatedPage({
    Key? key,
    required this.email,
    this.onHomeTap,
    this.onLoginTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Warna yang sama dengan RegisterPage untuk konsistensi
    final Color primaryPink = const Color(0xFFFF6B6B);
    final Color primaryGreen = const Color(0xFF4ECDC4);
    final Color bgColor = const Color(0xFFF9F9F9);

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
                Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: primaryGreen,
                ),

                const SizedBox(height: 30),

                // Title
                Text(
                  'Akun Berhasil Diaktifkan!',
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
                  'Email $email telah berhasil diverifikasi. Sekarang kamu dapat menggunakan semua fitur PockEat.',
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
                      'LANJUTKAN KE HOME',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Login button (jika belum login)
                TextButton(
                  onPressed: () {
                    // Panggil callback jika ada
                    if (onLoginTap != null) {
                      onLoginTap!();
                    } else {
                      // Navigasi default ke login
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: Text(
                    'Masuk ke Akun',
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryPink,
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
