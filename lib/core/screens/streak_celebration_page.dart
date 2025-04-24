// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/model/streak_message.dart';

/// Page to display streak celebration
///
/// This page is displayed when the user clicks on the streak celebration notification
/// and shows a celebratory message based on the user's streak days
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
  // Colors - matching design from splash screen
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9); // Light background
  final Color logoBlue = const Color(0xFF8FE0D7); // Light blue for "POCK"
  final Color logoOrange = const Color(0xFFFF6633); // Orange for "EAT"
  final Color textDark = const Color(0xFF333333);

  late final AnimationController _controller;
  late final StreakMessage _streakMessage;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Use Factory Method pattern to get the appropriate message
    _streakMessage = StreakMessageFactory.createMessage(widget.streak);

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
      appBar: AppBar(
        title: const Text('Streak Achievement'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Streak animation
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Lottie Animation
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset(
                              _getAnimationPath(),
                              controller: _controller,
                              repeat: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Streak number
                          Text(
                            widget.streak.toString(),
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: primaryPink,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Streak title based on factory method
                          Text(
                            _streakMessage.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Streak message based on factory method
                          Text(
                            _streakMessage.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
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
      ),
    );
  }
}
