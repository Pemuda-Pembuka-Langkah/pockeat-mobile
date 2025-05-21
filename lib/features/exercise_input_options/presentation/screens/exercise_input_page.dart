// exercise_input_page.dart

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/exercise_input_options/presentation/widgets/exercise_option_card.dart';
import 'package:pockeat/features/free_limit/services/free_limit_service.dart';

class ExerciseInputPage extends StatefulWidget {
  const ExerciseInputPage({super.key});

  @override
  State<ExerciseInputPage> createState() => _ExerciseInputPageState();
}

class _ExerciseInputPageState extends State<ExerciseInputPage> {
  // Warna yang lebih kontras tapi tetap cute
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color pinkColor = const Color(0xFFFF6B6B);
  final Color greenColor = const Color(0xFF4ECDC4);
  final Color purpleColor = const Color(0xFF9B6BFF);

  // Free limit service to check trial validity
  final FreeLimitService _freeLimitService = GetIt.instance<FreeLimitService>();

  @override
  void initState() {
    super.initState();
    // Check if trial is valid when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTrialValidity();
    });
  }

  // Check if user can access this feature
  Future<void> _checkTrialValidity() async {
    await _freeLimitService.checkAndRedirect(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
    );
  }
}
