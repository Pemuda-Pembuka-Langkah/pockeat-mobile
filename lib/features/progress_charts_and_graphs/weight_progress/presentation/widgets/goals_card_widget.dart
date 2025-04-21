import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';

class GoalsCardWidget extends StatelessWidget {
  final WeightGoal weightGoal;
  final Color primaryGreen;
  final Color primaryPink;
  final Color primaryYellow;
  
  const GoalsCardWidget({
    super.key,
    required this.weightGoal,
    required this.primaryGreen,
    required this.primaryPink,
    required this.primaryYellow,
  });

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weight Goals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  weightGoal.isOnTrack ? 'On Track' : 'Off Track',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGoalDetail('Starting', weightGoal.startingWeight, weightGoal.startingDate, Icons.history),
              Container(height: 40, width: 1, color: Colors.grey[200]),
              _buildGoalDetail('Target', weightGoal.targetWeight, weightGoal.targetDate, Icons.flag),
              Container(height: 40, width: 1, color: Colors.grey[200]),
              _buildGoalDetail('To Go', weightGoal.remainingWeight, weightGoal.daysLeft, Icons.trending_down),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryYellow.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Color(0xFFFFB946), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weightGoal.insightMessage,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalDetail(String label, String value, String subtitle, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryPink, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}