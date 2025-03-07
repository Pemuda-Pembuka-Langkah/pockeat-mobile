
// exercise_input_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What type of exercise\ndid you do?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // Running Option
              ExerciseOptionCard(
                icon: Icons.directions_run,
<<<<<<< HEAD
                title: 'Cardio',
                subtitle: 'Track your cardio session',
                color: pinkColor,
                route: '/cardio',
=======
                title: 'Running',
                subtitle: 'Track your running session',
                color: pinkColor,
                route: '/running-input',
>>>>>>> a1c8b5d039a9590b2d350e974a1b4baf76ef76b3
              ),
              
              const SizedBox(height: 16),
              
              // Weightlifting Option
              ExerciseOptionCard(
                icon: CupertinoIcons.arrow_up_circle_fill,
                title: 'Weightlifting',
                subtitle: 'Log your strength training',
                color: greenColor,
                route: '/weightlifting-input',
              ),
              
              const SizedBox(height: 16),
              
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
    );
  }
}