// ignore_for_file: use_build_context_synchronously

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';
import 'form_cubit.dart';

class SpeedSelectionPage extends StatefulWidget {
  const SpeedSelectionPage({super.key});

  @override
  State<SpeedSelectionPage> createState() => _SpeedSelectionPageState();
}

class _SpeedSelectionPageState extends State<SpeedSelectionPage>
    with SingleTickerProviderStateMixin {
class _SpeedSelectionPageState extends State<SpeedSelectionPage>
    with SingleTickerProviderStateMixin {
  double _weeklyGoal = 0.5; // kg/week
  bool _isMaintenanceMode = false; // true when current weight = desired weight

  // Colors from the app's design system
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;
  final Color textLightColor = Colors.black54;


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

      // Check if current weight equals desired weight
      final cubit = context.read<HealthMetricsFormCubit>();
      final currentWeight = cubit.state.weight;
      final desiredWeight = cubit.state.desiredWeight;
      final storedWeeklyGoal = cubit.state.weeklyGoal;
      
      // Check if we're in maintenance mode (current weight = desired weight)
      if (currentWeight != null && desiredWeight != null) {
        if ((currentWeight - desiredWeight).abs() < 0.1) { // Account for small floating point differences
          setState(() {
            _isMaintenanceMode = true;
            _weeklyGoal = 0.0; // Set to 0 for maintenance
          });
        } else {
          // NOT in maintenance mode - ensure we have a proper weekly goal
          setState(() {
            _isMaintenanceMode = false;
            
            // If user coming from maintenance mode (weeklyGoal was 0) or has no weeklyGoal,
            // set a reasonable default of 0.5 kg/week
            if (storedWeeklyGoal == null || storedWeeklyGoal <= 0.0) {
              _weeklyGoal = 0.5; // Set default value for weight loss/gain mode
            } else {
              _weeklyGoal = storedWeeklyGoal;
            }
          });
        }
      }
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),

              // Onboarding progress indicator
              const OnboardingProgressIndicator(
                totalSteps: 16,
                currentStep: 9, // This is the tenth step (0-indexed)
                barHeight: 6.0,
                showPercentage: true,
              ),

              const SizedBox(height: 20),

              // Title with modern style
              const Text(
                "Goal Speed",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "How fast do you want to reach your goal?",
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Only show weight change info when NOT in maintenance mode
                          if (!_isMaintenanceMode) ...[                          
                            // Weekly weight change info container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryGreen.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: primaryGreen.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.monitor_weight_outlined,
                                      color: primaryGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Weekly weight change",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${_weeklyGoal.toStringAsFixed(1)} kg/week",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Min and max indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Slow",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  "Fast",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),
                          ],

                          // Clear, simplified maintenance mode notice when current weight = desired weight
                          if (_isMaintenanceMode)
                            Container(
                              margin: const EdgeInsets.only(top: 10, bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Colors.amber,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Weight Maintenance",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textDarkColor,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Your current weight equals your desired weight. Goal speed will be set to 0 kg/week for weight maintenance.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textDarkColor.withOpacity(0.7),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Only show slider when NOT in maintenance mode
                          if (!_isMaintenanceMode)
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                activeTrackColor: primaryGreen,
                                inactiveTrackColor: Colors.grey.shade200,
                                thumbColor: primaryGreen,
                                overlayColor: primaryGreen.withOpacity(0.2),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 10),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 20),
                              ),
                              child: Slider(
                                value: _weeklyGoal,
                                onChanged: (value) {
                                  setState(() => _weeklyGoal = value);
                                },
                                min: 0.1,
                                max: 2.0,
                                divisions: 20,
                                label: _isMaintenanceMode
                                    ? "Maintenance"
                                    : "${_weeklyGoal.toStringAsFixed(1)} kg/week",
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Speed description with icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _weeklyGoal < 0.5
                                    ? Icons.accessibility_new
                                    : _weeklyGoal < 1.2
                                        ? Icons.directions_run
                                        : Icons.bolt,
                                color: primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _weeklyGoal < 0.5
                                    ? "Slow & Steady 🐢"
                                    : _weeklyGoal < 1.2
                                        ? "Balanced & Consistent 🧘"
                                        : "Ambitious & Fast ⚡️",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Description text
                          Text(
                            _isMaintenanceMode
                                ? "Focus on maintaining your current weight with balanced nutrition"
                                : _weeklyGoal < 0.5
                                    ? "Gentle, sustainable pace for long-term results"
                                    : _weeklyGoal < 1.2
                                        ? "Moderate pace balancing results and sustainability"
                                        : "Rapid results but may be more challenging to maintain",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              height: 1.3,
                            ),
                          ),

                          const Spacer(),

                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // If in maintenance mode, set weekly goal to 0
                                context
                                    .read<HealthMetricsFormCubit>()
                                    .setWeeklyGoal(_isMaintenanceMode ? 0.0 : _weeklyGoal);
                                Navigator.pushNamed(
                                    context, '/add-calories-back');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                elevation: 2,
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
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}
