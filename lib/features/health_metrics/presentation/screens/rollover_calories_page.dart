// rollover_calories_page.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';

class RolloverCaloriesPage extends StatefulWidget {
  const RolloverCaloriesPage({super.key});

  @override
  State<RolloverCaloriesPage> createState() => _RolloverCaloriesPageState();
}

class _RolloverCaloriesPageState extends State<RolloverCaloriesPage>
    with SingleTickerProviderStateMixin {
  // Colors from the app's design system
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;
  final Color textLightColor = Colors.black54;
  bool? _rolloverCalories;

  // Key for the rollover calories setting
  static const String _rolloverCaloriesKey = 'rollover_calories_enabled';

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Load saved preference
    _loadRolloverCaloriesPreference();

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

  /// Load rollover calories preference
  Future<void> _loadRolloverCaloriesPreference() async {
    try {
      // Try getting setting from local storage
      final prefs = await SharedPreferences.getInstance();
      final localSetting = prefs.getBool(_rolloverCaloriesKey);

      setState(() {
        _rolloverCalories = localSetting;
      });
    } catch (e) {
      debugPrint('Error loading rollover calories setting: $e');
    }
  }

  /// Save rollover calories setting to SharedPreferences
  Future<void> _saveRolloverCaloriesSetting(bool value) async {
    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rolloverCaloriesKey, value);

      setState(() {
        _rolloverCalories = value;
      });
    } catch (e) {
      debugPrint('Error saving rollover calories setting: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save preference'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // Onboarding progress indicator
                  OnboardingProgressIndicator(
                    totalSteps: 16,
                    currentStep: 11, // This is the 12th step (0-indexed)
                    barHeight: 6.0,
                    showPercentage: true,
                  ),

                  SizedBox(height: 20),

                  // Title with modern style
                  Text(
                    "Rollover Calories",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Would you like to roll over your unused calories to the next day?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),

            // Main content in a white container with shadow - using Expanded + ScrollView
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Explanation card
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
                                      Icons.calendar_today_rounded,
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
                                          "What this means",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "If you choose 'Yes', up to 1000 unused calories will roll over to your next day's calorie budget, helping you maintain a flexible diet.",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Option buttons - modern switch style
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // No option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await _saveRolloverCaloriesSetting(
                                            false);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _rolloverCalories == false
                                              ? primaryGreen
                                              : Colors.transparent,
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                  left: Radius.circular(15)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (_rolloverCalories == false)
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.black87,
                                                  size: 14,
                                                ),
                                              ),
                                            if (_rolloverCalories == false)
                                              const SizedBox(width: 8),
                                            Text(
                                              "No",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    _rolloverCalories == false
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Yes option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await _saveRolloverCaloriesSetting(
                                            true);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _rolloverCalories == true
                                              ? primaryGreen
                                              : Colors.transparent,
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                  right: Radius.circular(15)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (_rolloverCalories == true)
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.black87,
                                                  size: 14,
                                                ),
                                              ),
                                            if (_rolloverCalories == true)
                                              const SizedBox(width: 8),
                                            Text(
                                              "Yes",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _rolloverCalories == true
                                                    ? Colors.white
                                                    : Colors.black87,
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

                            const SizedBox(
                                height: 40), // Fixed height instead of Expanded

                            // Continue button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _rolloverCalories != null
                                    ? () async {
                                        if (_rolloverCalories != null) {
                                          await _saveRolloverCaloriesSetting(
                                              _rolloverCalories!);
                                        }
                                        if (context.mounted) {
                                          Navigator.pushNamed(
                                              context, '/used-other-apps');
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: primaryGreenDisabled,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
