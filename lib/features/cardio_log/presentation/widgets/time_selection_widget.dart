import 'package:flutter/material.dart';

class TimeSelectionWidget extends StatelessWidget {
  final Color primaryColor;
  final DateTime selectedStartTime;
  final DateTime selectedEndTime;
  final Function(DateTime) onStartTimeChanged;
  final Function(DateTime) onEndTimeChanged;

  const TimeSelectionWidget({
    super.key,
    required this.primaryColor,
    required this.selectedStartTime,
    required this.selectedEndTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Force minimum 1 minute duration when building the widget
    final currentDuration = selectedEndTime.difference(selectedStartTime);
    if (currentDuration.inMinutes < 1) {
      // This rebuilds with correct values when displayed initially
      // coverage:ignore-start

      WidgetsBinding.instance.addPostFrameCallback((_) {
        onEndTimeChanged(selectedStartTime.add(const Duration(minutes: 1)));
      });
    }
      // coverage:ignore-end
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
        children: [
          // Start Time
          Row(
            children: [
              Icon(Icons.play_circle, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Start Time',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedStartTime),
              );
              if (time != null) {
                final newStartTime = DateTime(
                  selectedStartTime.year,
                  selectedStartTime.month,
                  selectedStartTime.day,
                  time.hour,
                  time.minute,
                );
                onStartTimeChanged(newStartTime);
              }
            },
            child: Text(
              TimeOfDay.fromDateTime(selectedStartTime).format(context),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // End Time
          Row(
            children: [
              Icon(Icons.stop_circle, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                'End Time',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final TimeOfDay? time = await showTimePicker(
                context: context,
// coverage:ignore-start
                initialTime: TimeOfDay.fromDateTime(selectedEndTime),
              );
              if (time != null && context.mounted) {
                // Create a new DateTime from the same day as the start time
                DateTime newEndTime = DateTime(
                  selectedStartTime.year,
                  selectedStartTime.month,
                  selectedStartTime.day,
                  time.hour,
                  time.minute,
                );

                // Handle overnight workouts - if end time is earlier than start time
                // on the same day, assume it's for the next day
                if (time.hour <
                        TimeOfDay.fromDateTime(selectedStartTime).hour ||
                    (time.hour ==
                            TimeOfDay.fromDateTime(selectedStartTime).hour &&
                        time.minute <
                            TimeOfDay.fromDateTime(selectedStartTime).minute)) {
                  newEndTime = newEndTime.add(const Duration(days: 1));
                }

                // Ensure minimum 1 minute difference
                final minimumEndTime =
                    selectedStartTime.add(const Duration(minutes: 1));
                if (newEndTime.isBefore(minimumEndTime)) {
                  newEndTime = minimumEndTime;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Minimum activity duration is 1 minute'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                onEndTimeChanged(newEndTime);
              }
            },
// coverage:ignore-end

            child: Text(
              TimeOfDay.fromDateTime(selectedEndTime).format(context),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Duration Display
          Text(
            'Duration: ${_formatDuration(currentDuration.inMinutes < 1 ? const Duration(minutes: 1) : currentDuration)}',
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

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} min';
    } else {
      return '$minutes min';
    }
  }
}
