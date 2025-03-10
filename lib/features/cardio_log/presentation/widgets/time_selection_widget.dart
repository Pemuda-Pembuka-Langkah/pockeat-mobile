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
                initialTime: TimeOfDay.fromDateTime(selectedEndTime),
              );
              if (time != null) {
                // Handle midnight crossing
                DateTime newEndTime = DateTime(
                  selectedStartTime.year,
                  selectedStartTime.month,
                  selectedStartTime.day,
                  time.hour,
                  time.minute,
                );

                // If end time is before start time, assume it's the next day
                if (time.hour < TimeOfDay.fromDateTime(selectedStartTime).hour ||
                    (time.hour == TimeOfDay.fromDateTime(selectedStartTime).hour &&
                     time.minute < TimeOfDay.fromDateTime(selectedStartTime).minute)) {
                  newEndTime = newEndTime.add(const Duration(days: 1));
                }

                onEndTimeChanged(newEndTime);
              }
            },
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
            'Duration: ${_formatDuration(selectedEndTime.difference(selectedStartTime))}',
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