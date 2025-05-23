// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../../../health_metrics/domain/models/health_metrics_model.dart';
import '../../services/calorie_calculator.dart';
import 'distance_selection_widget.dart';
import 'personal_data_reminder.dart';
import 'time_selection_widget.dart';

enum CyclingActivityType { mountain, commute, stationary }

class CyclingForm extends StatefulWidget {
  final Color primaryPink;
  final Function(double, Duration, String) onCalculate;
  final Function(String)? onTypeChanged;
  final HealthMetricsModel healthMetrics;

  const CyclingForm({
    super.key,
    required this.primaryPink,
    required this.onCalculate,
    required this.healthMetrics,
    this.onTypeChanged,
  });

  double calculateCalories(HealthMetricsModel healthMetrics) {
    final state = (key as GlobalKey<CyclingFormState>).currentState;
    if (state is CyclingFormState) {
      return state.calculateCalories(healthMetrics);
    }
    return 0.0;
  }

  @override
  State<CyclingForm> createState() => CyclingFormState();
}

class CyclingFormState extends State<CyclingForm> {
  CyclingActivityType selectedCyclingType = CyclingActivityType.mountain;
  int selectedKm = 0;
  int selectedMeter = 0;
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(minutes: 30));

  double calculateCalories(HealthMetricsModel healthMetrics) {
    try {
      final totalDistance = selectedKm + (selectedMeter / 1000);
      final duration = selectedEndTime.difference(selectedStartTime);

      // Check if duration is zero to avoid division by zero
      if (duration.inSeconds <= 0) {
        return 0.0;
      }

      final type = selectedCyclingType
          .toString()
          .split('.')
          .last; // 'mountain', 'commute', or 'stationary'

      widget.onCalculate(totalDistance, duration, type);

      return CalorieCalculator.calculateCyclingCalories(
        distanceKm: totalDistance,
        duration: duration,
        cyclingType: type,
        healthMetrics: healthMetrics,
      );
    } catch (e) {
      debugPrint('Error calculating cycling calories: $e');
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
          const Text(
            'Cycling Activity Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildCyclingTypeSelector(),
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

                // If end time is before start time (e.g. cycling past midnight),
                // adjust end time to maintain duration but with today's date
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

  Widget _buildCyclingTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildCyclingTypeOption(
            type: CyclingActivityType.mountain,
            icon: Icons.terrain,
            label: 'Mountain',
            isLastOption: false,
          ),
          _buildCyclingTypeOption(
            type: CyclingActivityType.commute,
            icon: FontAwesomeIcons.road,
            label: 'Commute',
            isLastOption: false,
            usesFontAwesome: true,
          ),
          _buildCyclingTypeOption(
            type: CyclingActivityType.stationary,
            icon: FontAwesomeIcons.personBiking,
            label: 'Stationary',
            isLastOption: true,
            usesFontAwesome: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCyclingTypeOption({
    required CyclingActivityType type,
    required dynamic icon,
    required String label,
    required bool isLastOption,
    bool usesFontAwesome = false,
  }) {
    bool isSelected = selectedCyclingType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => selectedCyclingType = type);

          // Call the onTypeChanged callback when the type changes
          if (widget.onTypeChanged != null) {
            widget.onTypeChanged!(type.toString().split('.').last);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.primaryPink.withOpacity(0.1)
                : Colors.transparent,
            border: isSelected
                ? Border.all(color: widget.primaryPink, width: 2)
                : !isLastOption
                    ? Border(
                        right: BorderSide(color: Colors.grey[400]!),
                      )
                    : null,
          ),
          child: Column(
            children: [
              if (usesFontAwesome)
                FaIcon(
                  icon,
                  size: 28,
                  color: isSelected ? widget.primaryPink : Colors.black54,
                )
              else
                Icon(
                  icon,
                  size: 28,
                  color: isSelected ? widget.primaryPink : Colors.black54,
                ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? widget.primaryPink : Colors.black54,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
