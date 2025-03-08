import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

/// Widget to display Smart Exercise details
class SmartExerciseDetailWidget extends StatelessWidget {
  final ExerciseAnalysisResult exercise;
  final Color purpleColor = const Color(0xFF9B6BFF); // Smart exercise color
  
  const SmartExerciseDetailWidget({
    Key? key,
    required this.exercise,
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
          _buildAnalysisDetails(context),
          if (exercise.summary != null) ...[
            const SizedBox(height: 16),
            _buildSummaryCard(context),
          ],
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
                    color: purpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 28,
                    color: purpleColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(exercise.timestamp),
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricColumn('Duration', exercise.duration),
                  _buildMetricColumn('Intensity', exercise.intensity),
                  _buildMetricColumn('Calories', '${exercise.estimatedCalories} kcal'),
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
  
  Widget _buildAnalysisDetails(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: purpleColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Exercise Type', exercise.exerciseType),
            const SizedBox(height: 8),
            _buildDetailRow('Duration', exercise.duration),
            const SizedBox(height: 8),
            _buildDetailRow('Intensity', exercise.intensity),
            const SizedBox(height: 8),
            _buildDetailRow('MET Value', exercise.metValue.toStringAsFixed(1)),
            const SizedBox(height: 8),
            _buildDetailRow('Estimated Calories', '${exercise.estimatedCalories} kcal'),
            const SizedBox(height: 8),
            if (exercise.originalInput.isNotEmpty) ...[
              _buildDetailRow('Original Input', exercise.originalInput),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
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
  
  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: purpleColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              exercise.summary ?? '',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
