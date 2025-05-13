// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../health_metrics/domain/models/health_metrics_model.dart';
import '../../services/calorie_calculator.dart';
import 'distance_selection_widget.dart';
import 'personal_data_reminder.dart';
import 'time_selection_widget.dart';

class RunningForm extends StatefulWidget {
  final Color primaryPink;
  final Function(double, Duration) onCalculate;
  final HealthMetricsModel healthMetrics;

  const RunningForm({
    super.key,
    required this.primaryPink,
    required this.onCalculate,
    required this.healthMetrics,
  });

  double calculateCalories(HealthMetricsModel healthMetrics) {
    final state = (key as GlobalKey<RunningFormState>).currentState;
    if (state is RunningFormState) {
      return state.calculateCalories(healthMetrics);
    }
    return 0.0;
  }

  @override
  State<RunningForm> createState() => RunningFormState();
}

class RunningFormState extends State<RunningForm> {
  int selectedKm = 0;
  int selectedMeter = 0;
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(minutes: 30));

  @override
  void initState() {
    super.initState();
    // Ensure minimum 1 minute difference on initialization
    selectedStartTime = DateTime.now();
    selectedEndTime = selectedStartTime.add(const Duration(minutes: 1));
  }

  double calculateCalories(HealthMetricsModel healthMetrics) {
    try {
      final totalDistance = selectedKm + (selectedMeter / 1000);
      final duration = selectedEndTime.difference(selectedStartTime);

      // Check if duration is zero to avoid division by zero
      if (duration.inSeconds <= 0) {
        return 0.0;
      }

      return CalorieCalculator.calculateRunningCalories(
        distanceKm: totalDistance,
        duration: duration,
        healthMetrics: healthMetrics,
      );
    } catch (e) {
      debugPrint('Error calculating running calories: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PersonalDataReminder(),
          const SizedBox(height: 16),
          TimeSelectionWidget(
            primaryColor: widget.primaryPink,
            selectedStartTime: selectedStartTime,
            selectedEndTime: selectedEndTime,
            onStartTimeChanged: (newStartTime) {
              setState(() {
                // Keep the same time but update to today's date
                final now = DateTime.now();
                selectedStartTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  newStartTime.hour,
                  newStartTime.minute,
                );

                // If end time is before start time, adjust it to maintain duration
                // but with today's date
                if (selectedEndTime.isBefore(selectedStartTime)) {
                  selectedEndTime =
                      selectedStartTime.add(const Duration(minutes: 30));
                } else {
                  // Keep existing end time but update to today's date
                  selectedEndTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    selectedEndTime.hour,
                    selectedEndTime.minute,
                  );
                }
              });
            },
            onEndTimeChanged: (newEndTime) {
              setState(() {
                // Keep the same time but ensure it's today's date
                final now = DateTime.now();
                selectedEndTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  newEndTime.hour,
                  newEndTime.minute,
                );

                // If end time is before start time, add a day to end time
                if (selectedEndTime.isBefore(selectedStartTime)) {
                  selectedEndTime =
                      selectedEndTime.add(const Duration(days: 1));
                }
              });
            },
          ),
          const SizedBox(height: 16),
          DistanceSelectionWidget(
            primaryColor: widget.primaryPink,
            selectedKm: selectedKm,
            selectedMeter: selectedMeter,
            onKmChanged: (km) {
              setState(() {
                selectedKm = km;
              });
            },
            onMeterChanged: (meter) {
              setState(() {
                selectedMeter = meter;
              });
            },
          ),
        ],
      ),
    );
  }
}
