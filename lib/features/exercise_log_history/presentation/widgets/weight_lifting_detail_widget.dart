import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/services/workout_service.dart';

/// Widget to display weight lifting activity details
class WeightLiftingDetailWidget extends StatelessWidget {
  final WeightLifting weightLifting;
  final Color primaryColor = const Color(0xFF4ECDC4); // Weightlifting color
  
  const WeightLiftingDetailWidget({
    super.key,
    required this.weightLifting,
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
          const SizedBox(height: 16),
          _buildSetsList(context),
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
                  child: Icon(
                    CupertinoIcons.arrow_up_circle_fill,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weightLifting.name,
                        style: const TextStyle(
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
                        weightLifting.bodyPart,
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
                icon: Icons.fitness_center,
                value: '${weightLifting.sets.length}',
                label: 'Sets',
                color: Colors.deepPurple,
                flex: 1,
              ),
              _buildVerticalDivider(),
              _buildMetricItem(
                icon: Icons.repeat,
                value: '${_getTotalReps()}',
                label: 'Total Reps',
                color: Colors.blue,
                flex: 1,
              ),
              _buildVerticalDivider(),
              _buildMetricItem(
                icon: Icons.local_fire_department,
                value: '${_calculateCalories().round()}',
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
                  'Workout Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Date', DateFormat('dd MMM yyyy').format(weightLifting.timestamp)),
            _buildDetailDivider(),
            _buildDetailRow('Time', DateFormat('HH:mm').format(weightLifting.timestamp)),
            _buildDetailDivider(),
            _buildDetailRow('Body Part', weightLifting.bodyPart),
            _buildDetailDivider(),
            _buildDetailRow('Total Sets', weightLifting.sets.length.toString()),
            _buildDetailDivider(),
            _buildDetailRow('Total Reps', _getTotalReps().toString()),
            _buildDetailDivider(),
            _buildDetailRow('Total Weight', '${_getTotalWeight().toStringAsFixed(1)} kg'),
            _buildDetailDivider(),
            _buildDetailRow('MET Value', weightLifting.metValue.toString()),
            _buildDetailDivider(),
            _buildDetailRow('Duration', _formatDuration(_getTotalDuration())),
            _buildDetailDivider(),
            _buildDetailRow('Calories Burned', '${_calculateCalories().round()} kcal'),
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
  
  Widget _buildSetsList(BuildContext context) {
    if (weightLifting.sets.isEmpty) {
      return Card(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No sets recorded for this exercise',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.format_list_numbered,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        ...weightLifting.sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          
          return Card(
            elevation: 3,
            shadowColor: Colors.black26,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: primaryColor,
                    width: 4,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Set ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(set.duration),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSetMetric(Icons.fitness_center, '${set.weight} kg', 'Weight'),
                        const SizedBox(width: 16),
                        _buildSetMetric(Icons.repeat, '${set.reps}', 'Reps'),
                        const SizedBox(width: 16),
                        _buildSetMetric(Icons.timer, _formatDuration(set.duration), 'Duration'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildSetMetric(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  int _getTotalReps() {
    return weightLifting.sets.fold(0, (sum, set) => sum + set.reps);
  }
  
  double _getTotalWeight() {
    return weightLifting.sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }
  
  double _getTotalDuration() {
    return weightLifting.sets.fold(0.0, (sum, set) => sum + set.duration);
  }
  
  String _formatDuration(double minutes) {
    // The duration is already stored in minutes
    return '${minutes.toStringAsFixed(0)} min';
  }
  
  double _calculateCalories() {
    return calculateExerciseCalories(weightLifting);
  }
}
