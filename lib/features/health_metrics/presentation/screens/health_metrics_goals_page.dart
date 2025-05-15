// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';
import 'form_cubit.dart';

class HealthMetricsGoalsPage extends StatefulWidget {
  const HealthMetricsGoalsPage({super.key});

  static final List<Map<String, dynamic>> options = [
    {
      "title": "Eat and live healthier",
      "icon": Icons.restaurant_menu,
    },
    {
      "title": "Boost my energy and mood",
      "icon": Icons.battery_charging_full,
    },
    {
      "title": "Stay motivated and consistent",
      "icon": Icons.schedule,
    },
    {
      "title": "Feel better about my body",
      "icon": Icons.favorite,
    },
    {
      "title": "I'm still exploring",
      "icon": Icons.explore,
    },
    {
      "title": "Other",
      "icon": Icons.more_horiz,
    },
  ];

  @override
  State<HealthMetricsGoalsPage> createState() => _HealthMetricsGoalsPageState();
}

class _HealthMetricsGoalsPageState extends State<HealthMetricsGoalsPage>
    with SingleTickerProviderStateMixin {
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
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
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
                  currentStep: 7, // This is the eighth step (0-indexed)
                  barHeight: 6.0,
                  showPercentage: true,
                ),

                const SizedBox(height: 20),

                // Title with modern style
                const Text(
                  "Your Goals",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "What would you like to accomplish?",
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
                      child: BlocBuilder<HealthMetricsFormCubit,
                          HealthMetricsFormState>(
                        builder: (context, state) {
                          final isOtherSelected =
                              state.selectedGoals.contains("Other");

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // Prompt text
                                      const Text(
                                        "Select all that apply",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Goal options
                                      for (final option
                                          in HealthMetricsGoalsPage.options)
                                        _buildOption(
                                          context,
                                          option,
                                          selected: state.selectedGoals
                                              .contains(option["title"]),
                                          disabled: isOtherSelected &&
                                                  option["title"] != "Other" ||
                                              (!isOtherSelected &&
                                                  option["title"] == "Other" &&
                                                  state.selectedGoals
                                                      .isNotEmpty),
                                        ),

                                      // Text field for Other option
                                      if (isOtherSelected)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              labelText: 'Please specify',
                                              labelStyle: const TextStyle(
                                                  color: Colors.black54),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: primaryGreen,
                                                    width: 2),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                            ),
                                            cursorColor: primaryGreen,
                                            onChanged: (value) => context
                                                .read<HealthMetricsFormCubit>()
                                                .setOtherGoalReason(value),
                                          ),
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
                                  onPressed: state.selectedGoals.isNotEmpty &&
                                          (!isOtherSelected ||
                                              (state.otherGoalReason
                                                      ?.isNotEmpty ??
                                                  false))
                                      ? () async {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          await prefs.setBool(
                                              'onboardingInProgress', true);
                                          if (!context.mounted) return;
                                          Navigator.pushNamed(
                                              context, '/activity-level');
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        state.selectedGoals.isNotEmpty &&
                                                (!isOtherSelected ||
                                                    (state.otherGoalReason
                                                            ?.isNotEmpty ??
                                                        false))
                                            ? primaryGreen
                                            : primaryGreenDisabled,
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    elevation:
                                        state.selectedGoals.isNotEmpty ? 2 : 0,
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

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    Map<String, dynamic> option, {
    required bool selected,
    required bool disabled,
  }) {
    final cubit = context.read<HealthMetricsFormCubit>();
    final String title = option["title"];
    final IconData icon = option["icon"];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: disabled ? null : () => cubit.toggleGoal(title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? primaryGreen
                  : disabled
                      ? Colors.grey.shade200
                      : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              if (!disabled)
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
                      : disabled
                          ? Colors.grey.shade100
                          : Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? primaryGreen
                      : disabled
                          ? Colors.grey.shade400
                          : Colors.grey.shade500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: disabled ? Colors.grey.shade400 : Colors.black87,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected
                    ? primaryGreen
                    : disabled
                        ? Colors.grey.shade300
                        : Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
