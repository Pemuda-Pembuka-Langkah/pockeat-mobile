import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';

/// Widget to display swimming activity details
class SwimmingDetailWidget extends StatelessWidget {
  final SwimmingActivity activity;
  final Color primaryPink = const Color(0xFFFF6B6B); // Cardio color
  
  const SwimmingDetailWidget({
    Key? key,
    required this.activity,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(context),
          const SizedBox(height: 16),
          _buildDetailsList(context),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pool,
                    size: 28,
                    color: primaryPink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Swimming Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(activity.date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricColumn('Distance', '${activity.totalDistance.toInt()} m'),
                  _buildMetricColumn('Duration', _formatDuration(activity.duration)),
                  _buildMetricColumn('Calories', '${activity.caloriesBurned.toInt()} kcal'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailsList(BuildContext context) {
    // Calculate pace per 100m
    final pace100m = activity.totalDistance > 0 
        ? (activity.duration.inSeconds / (activity.totalDistance / 100)) 
        : 0;
    final paceMinutes = (pace100m / 60).floor();
    final paceSeconds = (pace100m % 60).round();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryPink,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Date', DateFormat('dd MMM yyyy').format(activity.date)),
            const SizedBox(height: 8),
            _buildDetailRow('Start Time', DateFormat('HH:mm').format(activity.startTime)),
            const SizedBox(height: 8),
            _buildDetailRow('End Time', DateFormat('HH:mm').format(activity.endTime)),
            const SizedBox(height: 8),
            _buildDetailRow('Distance', '${activity.totalDistance.toInt()} m'),
            const SizedBox(height: 8),
            _buildDetailRow('Duration', _formatDuration(activity.duration)),
            const SizedBox(height: 8),
            _buildDetailRow('Pace (100m)', '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}'),
            const SizedBox(height: 8),
            _buildDetailRow('Stroke Style', _getStrokeStyle(activity.stroke)),
            const SizedBox(height: 8),
            _buildDetailRow('Pool Length', '${activity.poolLength} m'),
            const SizedBox(height: 8),
            _buildDetailRow('Laps', activity.laps.toString()),
            const SizedBox(height: 8),
            _buildDetailRow('Calories Burned', '${activity.caloriesBurned.toInt()} kcal'),
          ],
        ),
      ),
    );
  }
  
  String _getStrokeStyle(String? style) {
    if (style == null || style.isEmpty) {
      return 'Not specified';
    }
    
    // Capitalize first letter
    return style[0].toUpperCase() + style.substring(1).toLowerCase();
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }
}
