import 'package:flutter/material.dart';
import 'distance_selection_widget.dart';
import 'time_selection_widget.dart';
import 'date_selection_widget.dart';
import 'personal_data_reminder.dart';


class RunningForm extends StatefulWidget {
  final Color primaryPink;
  final Function(double, Duration) onCalculate;

  const RunningForm({
    super.key,
    required this.primaryPink,
    required this.onCalculate,
  });

  double getCalories() {
    return calculateCalories();
  }

  double calculateCalories() {
    final state = (key as GlobalKey<RunningFormState>).currentState;
    if (state is RunningFormState) {
      return state.calculateCalories();
    }
    return 0.0;
  }
  
  @override
  State<RunningForm> createState() => RunningFormState();
}

class RunningFormState extends State<RunningForm> {
  int selectedKm = 5;
  int selectedMeter = 0;
  DateTime selectedDate = DateTime.now();
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(minutes: 30));

  double calculateCalories() {
    final totalDistance = selectedKm + (selectedMeter / 1000);
    final duration = selectedEndTime.difference(selectedStartTime);
    return widget.onCalculate(totalDistance, duration);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonalDataReminder(),
          const SizedBox(height: 16),
          DateSelectionWidget(
            primaryColor: widget.primaryPink,
            selectedDate: selectedDate,
            onDateChanged: (newDate) {
              setState(() {
                selectedDate = newDate;
                
                // Keep the same time but update date
                selectedStartTime = DateTime(
                  newDate.year,
                  newDate.month,
                  newDate.day,
                  selectedStartTime.hour,
                  selectedStartTime.minute,
                );
                
                selectedEndTime = DateTime(
                  newDate.year,
                  newDate.month,
                  newDate.day,
                  selectedEndTime.hour,
                  selectedEndTime.minute,
                );
                
                // If end time is before start time (e.g. running past midnight),
                // add a day to end time
                if (selectedEndTime.isBefore(selectedStartTime)) {
                  selectedEndTime = selectedEndTime.add(const Duration(days: 1));
                }
              });
            },
          ),
          const SizedBox(height: 16),
          TimeSelectionWidget(
            primaryColor: widget.primaryPink,
            selectedStartTime: selectedStartTime,
            selectedEndTime: selectedEndTime,
            onStartTimeChanged: (newStartTime) {
              setState(() {
                selectedStartTime = newStartTime;
                
                // If end time is now before start time, adjust it
                if (selectedEndTime.isBefore(selectedStartTime)) {
                  selectedEndTime = selectedStartTime.add(const Duration(minutes: 30));
                }
              });
            },
            onEndTimeChanged: (newEndTime) {
              setState(() {
                selectedEndTime = newEndTime;
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