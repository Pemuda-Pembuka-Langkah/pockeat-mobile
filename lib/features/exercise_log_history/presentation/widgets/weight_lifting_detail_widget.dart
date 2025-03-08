import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

/// Widget to display weight lifting activity details
class WeightLiftingDetailWidget extends StatelessWidget {
  final WeightLifting weightLifting;
  final Color primaryGreen = const Color(0xFF4ECDC4); // Weightlifting color
  
  const WeightLiftingDetailWidget({
    Key? key,
    required this.weightLifting,
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
          const SizedBox(height: 16),
          _buildSetsList(context),
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
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_up_circle_fill,
                    size: 28,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weightLifting.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        weightLifting.bodyPart,
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
                  _buildMetricColumn(
                    'Sets',
                    '${weightLifting.sets.length}',
                  ),
                  _buildMetricColumn(
                    'Total Reps',
                    '${_getTotalReps()}',
                  ),
                  _buildMetricColumn(
                    'Calories',
                    '${_calculateCalories().round()} kcal',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailsList(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Date', DateFormat('dd MMM yyyy').format(weightLifting.timestamp)),
            const SizedBox(height: 8),
            _buildDetailRow('Time', DateFormat('HH:mm').format(weightLifting.timestamp)),
            const SizedBox(height: 8),
            _buildDetailRow('Body Part', weightLifting.bodyPart),
            const SizedBox(height: 8),
            _buildDetailRow('Total Sets', weightLifting.sets.length.toString()),
            const SizedBox(height: 8),
            _buildDetailRow('Total Reps', _getTotalReps().toString()),
            const SizedBox(height: 8),
            _buildDetailRow('Total Weight', '${_getTotalWeight().toStringAsFixed(1)} kg'),
            const SizedBox(height: 8),
            _buildDetailRow('MET Value', weightLifting.metValue.toString()),
            const SizedBox(height: 8),
            _buildDetailRow('Duration', _formatDuration(_getTotalDuration())),
            const SizedBox(height: 8),
            _buildDetailRow('Calories Burned', '${_calculateCalories().round()} kcal'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSetsList(BuildContext context) {
    if (weightLifting.sets.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No sets recorded for this exercise',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Sets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
        ),
        ...weightLifting.sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: primaryGreen,
                        ),
                      ),
                      Text(
                        _formatDuration(set.duration),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMetricColumn(
                          'Weight',
                          '${set.weight} kg',
                        ),
                        _buildMetricColumn(
                          'Reps',
                          '${set.reps}',
                        ),
                        _buildMetricColumn(
                          'Volume',
                          '${(set.weight * set.reps).toStringAsFixed(1)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
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
  
  int _getTotalReps() {
    return weightLifting.sets.fold(0, (sum, set) => sum + set.reps);
  }
  
  double _getTotalWeight() {
    return weightLifting.sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }
  
  double _getTotalDuration() {
    return weightLifting.sets.fold(0.0, (sum, set) => sum + set.duration);
  }
  
  String _formatDuration(double seconds) {
    int totalSeconds = seconds.round();
    int minutes = totalSeconds ~/ 60;
    int remainingSeconds = totalSeconds % 60;
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutesStr = twoDigits(minutes);
    final secondsStr = twoDigits(remainingSeconds);
    return '$minutesStr:$secondsStr';
  }
  
  double _calculateCalories() {
    // Calculate calories burned based on MET value, duration, and weight
    // Formula: Calories = MET value × weight (kg) × duration (hours)
    double durationInHours = _getTotalDuration() / 3600; // convert seconds to hours
    double standardWeight = 70.0; // default weight assumption
    return weightLifting.metValue * standardWeight * durationInHours;
  }
}
