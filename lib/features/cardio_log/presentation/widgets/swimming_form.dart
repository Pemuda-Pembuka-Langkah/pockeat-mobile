import 'package:flutter/material.dart';
import 'personal_data_reminder.dart';
import 'time_selection_widget.dart';

class SwimmingForm extends StatefulWidget {
  final Color primaryPink;
  final Function(int, double, String, Duration)
      onCalculate; // laps, poolLength, stroke, duration

  const SwimmingForm({
    super.key,
    required this.primaryPink,
    required this.onCalculate,
  });

  double calculateCalories() {
    final state = (key as GlobalKey<SwimmingFormState>).currentState;
    if (state is SwimmingFormState) {
      return state._calculateFormCalories();
    }
    return 0.0;
  }

  @override
  State<SwimmingForm> createState() => SwimmingFormState();
}

class SwimmingFormState extends State<SwimmingForm> {
  // Swimming stroke options
  final List<String> strokes = [
    'Breaststroke',
    'Freestyle (Front Crawl)',
    'Backstroke',
    'Butterfly'
  ];

  String selectedStroke = 'Freestyle (Front Crawl)';
  double customPoolLength = 25.0;
  int selectedLaps = 20;
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(minutes: 30));

  // Menghitung kalori berdasarkan data form
  double _calculateFormCalories() {
    try {
      Duration duration = selectedEndTime.difference(selectedStartTime);

      // Check if duration is zero to avoid division by zero
      if (duration.inSeconds <= 0) {
        return 0.0;
      }

      return widget.onCalculate(
        selectedLaps,
        customPoolLength,
        selectedStroke,
        duration,
      );
    } catch (e) {
      debugPrint('Error calculating swimming calories: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonalDataReminder(),
          const SizedBox(height: 16),
          TimeSelectionWidget(
            primaryColor: widget.primaryPink,
            selectedStartTime: selectedStartTime,
            selectedEndTime: selectedEndTime,
            onStartTimeChanged: (newStartTime) {
              setState(() {
                final now = DateTime.now();
                selectedStartTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  newStartTime.hour,
                  newStartTime.minute,
                );

                selectedEndTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedEndTime.hour,
                  selectedEndTime.minute,
                );

                // If end time is before start time (e.g. swimming past midnight),
                // add a day to end time
                if (selectedEndTime.isBefore(selectedStartTime)) {
                  selectedEndTime =
                      selectedEndTime.add(const Duration(days: 1));
                }
              });
            },
            onEndTimeChanged: (newEndTime) {
              setState(() {
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
          buildSwimmingDetailsContainer(),
        ],
      ),
    );
  }

  Widget buildSwimmingDetailsContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swimming Stroke Dropdown
          Row(
            children: [
              Icon(Icons.waves, color: widget.primaryPink),
              const SizedBox(width: 8),
              const Text(
                'Swimming Stroke',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedStroke,
                icon: Icon(Icons.arrow_drop_down, color: widget.primaryPink),
                items: strokes.map((String stroke) {
                  return DropdownMenuItem<String>(
                    value: stroke,
                    child: Text(
                      stroke,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedStroke = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pool Length Section
          Row(
            children: [
              Icon(Icons.straighten, color: widget.primaryPink),
              const SizedBox(width: 8),
              const Text(
                'Pool Length',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.primaryPink,
              inactiveTrackColor: widget.primaryPink.withOpacity(0.2),
              thumbColor: widget.primaryPink,
              valueIndicatorColor: widget.primaryPink,
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: Slider(
              value: customPoolLength,
              min: 3,
              max: 100,
              divisions: 97,
              label: '${customPoolLength.toStringAsFixed(1)}m',
              onChanged: (value) {
                setState(() {
                  customPoolLength = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${customPoolLength.toStringAsFixed(1)} meters',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Laps Section
          Row(
            children: [
              Icon(Icons.repeat, color: widget.primaryPink),
              const SizedBox(width: 8),
              const Text(
                'Laps',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.primaryPink,
              inactiveTrackColor: widget.primaryPink.withOpacity(0.2),
              thumbColor: widget.primaryPink,
              valueIndicatorColor: widget.primaryPink,
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: Slider(
              value: selectedLaps.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: selectedLaps.toString(),
              onChanged: (value) {
                setState(() {
                  selectedLaps = value.toInt();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '$selectedLaps laps',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total Distance: ${_calculateTotalDistance()} meters',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalDistance() {
    return (selectedLaps * customPoolLength).toStringAsFixed(1);
  }
}
