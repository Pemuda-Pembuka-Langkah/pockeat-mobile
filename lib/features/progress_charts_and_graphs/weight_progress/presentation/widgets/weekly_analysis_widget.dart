import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';

class WeeklyAnalysisWidget extends StatelessWidget {
  final WeeklyAnalysis weeklyAnalysis;
  final Color primaryGreen;
  final Color primaryPink;
  
  const WeeklyAnalysisWidget({
    Key? key,
    required this.weeklyAnalysis,
    required this.primaryGreen,
    required this.primaryPink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week\'s Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnalysisItem(
                icon: Icons.arrow_downward,
                label: 'Weight Change',
                value: weeklyAnalysis.weightChange,
                color: primaryGreen,
              ),
              _buildAnalysisItem(
                icon: Icons.local_fire_department,
                label: 'Calories Burned',
                value: weeklyAnalysis.caloriesBurned,
                color: primaryPink,
              ),
              _buildAnalysisItem(
                icon: Icons.speed,
                label: 'Progress Rate',
                value: weeklyAnalysis.progressRate,
                color: const Color(0xFFFFB946),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: weeklyAnalysis.weeklyGoalPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
          ),
          const SizedBox(height: 8),
          Text(
            '${(weeklyAnalysis.weeklyGoalPercentage * 100).toInt()}% of weekly goal achieved',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}