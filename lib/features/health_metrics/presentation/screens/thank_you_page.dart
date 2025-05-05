// thank_you_page.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              color: primaryPink,
              size: 100,
            ),
            const SizedBox(height: 30),
            const Text(
              "Thank You!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Thanks for trusting us! Let's move forward together 🚀",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  // ✅ Still set onboardingInProgress = true
                  await prefs.setBool('onboardingInProgress', true);
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/add-calories-back');
                  }
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
