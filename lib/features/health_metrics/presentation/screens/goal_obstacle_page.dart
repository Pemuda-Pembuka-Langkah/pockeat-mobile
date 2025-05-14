// goal_obstacle_page.dart

// ignore_for_file: use_build_context_synchronously

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'form_cubit.dart';
import '../widgets/onboarding_progress_indicator.dart';

/// A page that asks users what obstacles they face in reaching their goals.
class GoalObstaclePage extends StatefulWidget {
  const GoalObstaclePage({super.key});

  /// Predefined obstacles users might face.
  static final List<String> obstacles = [
    "Lack of Time",
    "Lack of Motivation",
    "Not Sure Where to Start",
    "Unhealthy Eating Habits",
    "Inconsistent Exercise",
    "Stress or Mental Health",
    "Other",
  ];

  @override
  State<GoalObstaclePage> createState() => _GoalObstaclePageState();
}

class _GoalObstaclePageState extends State<GoalObstaclePage> with SingleTickerProviderStateMixin {
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

  /// Builds a single obstacle option card.
  Widget _buildObstacleOption(
    BuildContext context,
    String value, {
    required bool selected,
  }) {
    final cubit = context.read<HealthMetricsFormCubit>();
    final IconData icon = _getIconForObstacle(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => cubit.setDietType(value),
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
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: textDarkColor,
                  ),
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

  /// Get appropriate icon for each obstacle type
  IconData _getIconForObstacle(String obstacle) {
    switch (obstacle) {
      case "Lack of Time":
        return Icons.access_time;
      case "Lack of Motivation":
        return Icons.battery_alert;
      case "Not Sure Where to Start":
        return Icons.help_outline;
      case "Unhealthy Eating Habits":
        return Icons.fastfood;
      case "Inconsistent Exercise":
        return Icons.fitness_center;
      case "Stress or Mental Health":
        return Icons.psychology;
      case "Other":
        return Icons.more_horiz;
      default:
        return Icons.label_important_outline;
    }
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
                  currentStep: 5, // This is the sixth step (0-indexed)
                  barHeight: 6.0,
                  showPercentage: true,
                ),

                const SizedBox(height: 20),

                // Title with modern style
                const Text(
                  "Challenges",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "What's your biggest obstacle?",
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
                                builder: (context, state) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        // Removed goal info section as it's redundant
                                        
                                        // Obstacle options
                                        for (final obstacle in GoalObstaclePage.obstacles)
                                          _buildObstacleOption(
                                            context,
                                            obstacle,
                                            selected: state.dietType == obstacle,
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            // Continue button within the white container
                            BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: state.dietType != null
                                        ? () async {
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setBool('onboardingInProgress', true);
                                            Navigator.pushNamed(context, '/diet');
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: state.dietType != null
                                          ? primaryGreen
                                          : primaryGreenDisabled,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 56),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: state.dietType != null ? 2 : 0,
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
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
  
  // Goal info section removed as it's redundant
}
