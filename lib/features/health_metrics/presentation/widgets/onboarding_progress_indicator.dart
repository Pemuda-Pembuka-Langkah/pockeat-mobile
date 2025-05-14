// Flutter imports:
import 'package:flutter/material.dart';

/// A reusable onboarding progress indicator widget that shows the user's
/// current position in a multi-step onboarding flow using a linear progress bar.
///
/// This implementation is optimized for flows with many steps (10+) where
/// individual step indicators would become too crowded.
class OnboardingProgressIndicator extends StatelessWidget {
  /// The total number of steps in the onboarding flow.
  final int totalSteps;

  /// The current step index (1-based for display, internally 0-based).
  final int currentStep;

  /// Color for completed portion of the progress bar.
  final Color activeColor;

  /// Color for incomplete portion of the progress bar.
  final Color inactiveColor;

  /// Height of the progress bar.
  final double barHeight;

  /// Whether to show percentage along with step count.
  final bool showPercentage;

  /// Text style for the step label.
  final TextStyle? labelStyle;

  /// Animation duration for transitions.
  final Duration animationDuration;

  /// Border radius for the progress bar.
  final double borderRadius;

  const OnboardingProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor =
        const Color(0xFF4ECDC4), // Default to PockEat's primary green
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.barHeight = 6.0,
    this.showPercentage = true,
    this.labelStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius = 3.0,
  })  : assert(totalSteps > 0, 'Total steps must be greater than zero'),
        assert(currentStep >= 0 && currentStep < totalSteps,
            'Current step must be within range [0, totalSteps)');

  /// Calculate the completion percentage
  double get completionPercentage => (currentStep + 1) / totalSteps * 100;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultLabelStyle = textTheme.bodySmall?.copyWith(
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step label and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: labelStyle ?? defaultLabelStyle,
              ),
              if (showPercentage)
                Text(
                  '${completionPercentage.toInt()}%',
                  style: labelStyle ?? defaultLabelStyle,
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress bar
          Stack(
            children: [
              // Background (inactive) bar
              Container(
                height: barHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: inactiveColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),

              // Active progress bar
              AnimatedFractionallySizedBox(
                duration: animationDuration,
                alignment: Alignment.centerLeft,
                widthFactor: (currentStep + 1) / totalSteps,
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
