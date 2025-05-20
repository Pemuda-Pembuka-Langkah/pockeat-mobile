// coverage:ignore-file
// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/exercise_input_options/presentation/widgets/exercise_option_card.dart';

class ExerciseInputPage extends StatelessWidget {
  // Warna yang lebih kontras tapi tetap cute
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color pinkColor = const Color(0xFFFF6B6B);
  final Color greenColor = const Color(0xFF4ECDC4);
  final Color purpleColor = const Color(0xFF9B6BFF);

  const ExerciseInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to the root route instead of just popping
        await Navigator.of(context).pushReplacementNamed('/');
        return false; // Prevents default pop behavior
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Use pushReplacementNamed to navigate to the root route
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        title: const Text(
          'Add Exercise',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What type of exercise\ndid you do?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 36),

              // Running Option
              ExerciseOptionCard(
                icon: Icons.directions_run,
                title: 'Cardio',
                subtitle: 'Track your cardio session',
                color: pinkColor,
                route: '/cardio',
              ),

              const SizedBox(height: 20),

              // Weightlifting Option
              ExerciseOptionCard(
                icon: CupertinoIcons.arrow_up_circle_fill,
                title: 'Weightlifting',
                subtitle: 'Log your strength training',
                color: greenColor,
                route: '/weightlifting-input',
              ),

              const SizedBox(height: 20),

              // Smart Workout Log Option
              ExerciseOptionCard(
                icon: CupertinoIcons.text_badge_checkmark,
                title: 'Smart Exercise Log',
                subtitle: 'Let AI analyze your workout',
                color: purpleColor,
                route: '/smart-exercise-log',
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
