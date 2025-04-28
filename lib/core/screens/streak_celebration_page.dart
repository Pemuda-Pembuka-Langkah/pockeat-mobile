// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/model/streak_message.dart';

/// Page to display streak celebration
///
/// This page is displayed when the user clicks on the streak celebration notification
/// and shows a celebratory message based on the user's streak days
///
/// coverage:ignore-start
class StreakCelebrationPage extends StatefulWidget {
  /// Number of streak days
  final int streak;

  /// Constructor for StreakCelebrationPage
  const StreakCelebrationPage({
    super.key,
    required this.streak,
  });

  @override
  State<StreakCelebrationPage> createState() => _StreakCelebrationPageState();
}

class _StreakCelebrationPageState extends State<StreakCelebrationPage>
    with SingleTickerProviderStateMixin {
  // Colors - match with other screens for consistency
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDark = const Color(0xFF333333);
  final Color textMedium = const Color(0xFF666666);

  late final AnimationController _lottieController;
  late final ConfettiController _confettiController;
  late final StreakMessage _streakMessage;

  @override
  void initState() {
    super.initState();
    // Initialize lottie animation controller
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Initialize confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    // Use Factory Method pattern to get the appropriate message
    _streakMessage = StreakMessageFactory.createMessage(widget.streak);

    // Start the animations immediately
    _lottieController.repeat(); // Keep repeating the animation
    _confettiController.play();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getAnimationPath() {
    if (widget.streak >= 100) {
      return 'assets/animations/Panda Happy Jump.json';
    } else if (widget.streak >= 30) {
      return 'assets/animations/Panda Happy Jump.json';
    } else if (widget.streak >= 7) {
      return 'assets/animations/Panda Happy Jump.json';
    } else {
      return 'assets/animations/Panda Happy Idle.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),

                    // Celebration Animation
                    SizedBox(
                      height: 350,
                      width: 350,
                      child: Lottie.asset(
                        _getAnimationPath(),
                        // Don't use controller with repeat: true together
                        // as it conflicts with each other
                        animate: true,
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title from StreakMessage
                    Text(
                      _streakMessage.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Body from StreakMessage
                    Text(
                      _streakMessage.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: textMedium,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue',
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

          // Confetti animation overlay
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2, // Straight up
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 10,
            gravity: 0.1,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.red,
            ],
          ),
        ],
      ),
    );
  }
}

/// coverage:ignore-end
