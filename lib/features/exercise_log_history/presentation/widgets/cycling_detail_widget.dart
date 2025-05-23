// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';

/// Widget to display cycling activity details
class CyclingDetailWidget extends StatelessWidget {
  final CyclingActivity activity;
  final Color primaryColor = const Color(0xFFFF6B6B); // Cardio color

  const CyclingDetailWidget({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 16),
          _buildMetricsCard(context),
          const SizedBox(height: 16),
          _buildDetailsList(context),
          const SizedBox(height: 24), // Extra padding at the bottom
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_bike,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cycling Session',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(activity.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context) {
    final speed = activity.distanceKm > 0
        ? (activity.distanceKm / (activity.duration.inSeconds / 3600))
        : 0;

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _buildMetricItem(
                icon: Icons.straighten,
                value: '${activity.distanceKm.toStringAsFixed(1)} km',
                label: 'Distance',
                color: Colors.blue,
                flex: 1,
              ),
              _buildVerticalDivider(),
              _buildMetricItem(
                icon: Icons.speed,
                value: '${speed.toStringAsFixed(1)} km/h',
                label: 'Avg Speed',
                color: Colors.amber,
                flex: 1,
              ),
              _buildVerticalDivider(),
              _buildMetricItem(
                icon: Icons.local_fire_department,
                value: '${activity.caloriesBurned.toInt()}',
                label: 'Calories',
                color: Colors.red,
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(BuildContext context) {
    final speed = activity.distanceKm > 0
        ? (activity.distanceKm / (activity.duration.inSeconds / 3600))
        : 0;

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Activity Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                'Date', DateFormat('dd MMM yyyy').format(activity.date)),
            _buildDetailDivider(),
            _buildDetailRow(
                'Start Time', DateFormat('HH:mm').format(activity.startTime)),
            _buildDetailDivider(),
            _buildDetailRow(
                'End Time', DateFormat('HH:mm').format(activity.endTime)),
            _buildDetailDivider(),
            _buildDetailRow(
                'Distance', '${activity.distanceKm.toStringAsFixed(1)} km'),
            _buildDetailDivider(),
            _buildDetailRow('Duration', _formatDuration(activity.duration)),
            _buildDetailDivider(),
            _buildDetailRow(
                'Average Speed', '${speed.toStringAsFixed(1)} km/h'),
            _buildDetailDivider(),
            _buildDetailRow(
                'Cycling Type', _getCyclingTypeString(activity.cyclingType)),
            _buildDetailDivider(),
            _buildDetailRow(
                'Calories Burned', '${activity.caloriesBurned.toInt()} kcal'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.grey.withOpacity(0.2),
        height: 1,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
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
    return hours == '00' ? '$minutes:$seconds min' : '$hours:$minutes:$seconds';
  }

  String _getCyclingTypeString(CyclingType type) {
    switch (type) {
      case CyclingType.mountain:
        return 'Mountain Biking';
      case CyclingType.commute:
        return 'Commute/Road Cycling';
      case CyclingType.stationary:
        return 'Stationary Bike';
    }
  }
}
