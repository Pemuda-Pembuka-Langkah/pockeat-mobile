// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/utils/personalized_message_factory.dart';

class PersonalizedMessageWidget extends StatelessWidget {
  final List<String> goals;
  final Color primaryGreen;
  final Color textDarkColor;

  const PersonalizedMessageWidget({
    super.key,
    required this.goals,
    required this.primaryGreen,
    required this.textDarkColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use the factory to create personalized message data
    final messageData = PersonalizedMessageFactory.createFromGoals(goals);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(messageData.iconData, color: primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  messageData.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  messageData.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: textDarkColor.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
