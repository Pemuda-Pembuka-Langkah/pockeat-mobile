// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:lottie/lottie.dart';

/// Page shown when a user has logged in but not completed onboarding
///
/// This page encourages users to complete their health metrics onboarding
/// and prevents them from using the app until they do
class StillNotCompletedOnboardingPage extends StatelessWidget {
  // Colors - match with other screens for consistency
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDark = const Color(0xFF333333);
  final Color textMedium = const Color(0xFF666666);

  /// Constructor for StillNotCompletedOnboardingPage
  const StillNotCompletedOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitConfirmationDialog(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, bgColor],
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Panda animation
                      SizedBox(
                        height: 220,
                        width: 220,
                        child: Lottie.asset(
                          'assets/animations/Panda Happy.json',
                          animate: true,
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        'Complete Your Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Message
                      Text(
                        'We need a bit more information about your health profile to personalize your journey in PockEat and provide you with a tailored experience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: textMedium,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // White card with features
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildFeatureItem(
                              icon: Icons.person_outline,
                              text: 'Set your health goals',
                            ),
                            const Divider(height: 24),
                            _buildFeatureItem(
                              icon: Icons.fitness_center_outlined, 
                              text: 'Define your activity level',
                            ),
                            const Divider(height: 24),
                            _buildFeatureItem(
                              icon: Icons.restaurant_outlined,
                              text: 'Get a personalized PockEat experience',
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/onboarding');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Start Now',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build feature items
  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Show dialog confirming if user wants to exit the app
  // coverage:ignore-start
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App?'),
          content: const Text(
            'You need to complete your profile to use Pockeat. '
            'Do you want to exit the app?'
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Don't exit, stay on current page
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm exit
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      SystemNavigator.pop(); // Exit the app
    }
    
    return false; // Never allow natural back button to pop this route
  }
  // coverage:ignore-end
}
