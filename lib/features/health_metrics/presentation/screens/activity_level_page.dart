// ignore_for_file: use_build_context_synchronously

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'form_cubit.dart';
import '../widgets/onboarding_progress_indicator.dart';

/// A page that allows users to select their weekly physical activity level.
///
/// The selection updates the state managed by [HealthMetricsFormCubit] and is
/// used in calculating the user's caloric requirements later in onboarding.
class ActivityLevelPage extends StatefulWidget {
  const ActivityLevelPage({super.key});

  /// Available activity levels with a label, description, and icon for each option.
  static final List<Map<String, dynamic>> activityLevels = [
    {
      "value": "sedentary",
      "label": "Sedentary",
      "description": "Little or no exercise",
      "icon": Icons.weekend
    },
    {
      "value": "light",
      "label": "Light",
      "description": "Exercise 1–3 times/week",
      "icon": Icons.directions_walk
    },
    {
      "value": "moderate",
      "label": "Moderate",
      "description": "Exercise 4–5 times/week",
      "icon": Icons.directions_run
    },
    {
      "value": "active",
      "label": "Active",
      "description": "Daily exercise or intense exercise 3–4 times/week",
      "icon": Icons.fitness_center
    },
    {
      "value": "very active",
      "label": "Very Active",
      "description": "Intense exercise 6–7 times/week",
      "icon": Icons.sports
    },
    {
      "value": "extra active",
      "label": "Extra Active",
      "description": "Very intense daily exercise or physical job",
      "icon": Icons.flash_on
    },
  ];

  @override
  State<ActivityLevelPage> createState() => _ActivityLevelPageState();
}

class _ActivityLevelPageState extends State<ActivityLevelPage> with SingleTickerProviderStateMixin {
  // Colors from the app's design system
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: textDarkColor, size: 20),
          ),
          onPressed: () async {
            // Navigate back based on onboarding progress status
            final prefs = await SharedPreferences.getInstance();
            final inProgress = prefs.getBool('onboardingInProgress') ?? true;

            if (inProgress && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                bgColor,
              ],
              stops: const [0.0, 0.6],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Onboarding progress indicator
                const OnboardingProgressIndicator(
                  totalSteps: 16,
                  currentStep: 8, // This is the ninth step (0-indexed)
                  barHeight: 6.0,
                  showPercentage: true,
                ),

                const SizedBox(height: 20),

                // Title with modern style
                const Text(
                  "Activity Level",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "What best describes your weekly activity level?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 32),

                // Main content in a white container with shadow
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_fadeAnimation),
                        child: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        for (final level in ActivityLevelPage.activityLevels)
                                          _buildActivityOption(
                                            context,
                                            level["value"]!,
                                            level["label"]!,
                                            level["description"]!,
                                            level["icon"] as IconData,
                                            selected: state.activityLevel == level["value"],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Continue button at the bottom of the container
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: state.activityLevel != null
                                        ? () async {
                                            // Mark onboarding as in progress and navigate
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setBool('onboardingInProgress', true);
                                            Navigator.pushNamed(context, '/speed');
                                          }
                                        : null, // Disabled if no selection
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: state.activityLevel != null
                                          ? primaryGreen
                                          : primaryGreenDisabled,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 56),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: state.activityLevel != null ? 2 : 0,
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single tappable activity level option.
  ///
  /// Tapping the option updates the selected activity level in the Cubit state.
  Widget _buildActivityOption(
    BuildContext context,
    String value,
    String label,
    String description,
    IconData icon, {
    required bool selected,
  }) {
    final cubit = context.read<HealthMetricsFormCubit>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => cubit.setActivityLevel(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? primaryGreen : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected 
                    ? primaryGreen.withOpacity(0.1) 
                    : Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected 
                      ? primaryGreen.withOpacity(0.1) 
                      : Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? primaryGreen : Colors.grey.shade400,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? primaryGreen : Colors.grey.shade300,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
