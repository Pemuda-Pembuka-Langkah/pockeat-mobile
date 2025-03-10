import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';

/// A reusable widget that displays an exercise history item in a card format.
///
/// This widget is extracted from the RecentExerciseSection's buildExerciseCard
/// but uses the ExerciseLogHistoryItem model instead of a Map.
class ExerciseHistoryCard extends StatelessWidget {
  final ExerciseLogHistoryItem exercise;
  final VoidCallback? onTap;

  // Colors
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color purpleColor = const Color(0xFF9B6BFF);

  const ExerciseHistoryCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  /// Get the appropriate icon based on activity type
  IconData _getIconForActivityType(String activityType) {
    switch (activityType) {
      case ExerciseLogHistoryItem.typeCardio:
        return Icons.directions_run;
      case ExerciseLogHistoryItem.typeWeightlifting:
        return CupertinoIcons.arrow_up_circle_fill;
      case ExerciseLogHistoryItem.typeSmartExercise:
        return CupertinoIcons.text_badge_checkmark;
      default:
        return Icons.fitness_center;
    }
  }

  /// Get the appropriate color based on activity type
  Color _getColorForActivityType(String activityType) {
    switch (activityType) {
      case ExerciseLogHistoryItem.typeCardio:
        return primaryPink;
      case ExerciseLogHistoryItem.typeWeightlifting:
        return primaryGreen;
      case ExerciseLogHistoryItem.typeSmartExercise:
        return purpleColor;
      default:
        return Colors.blue;
    }
  }

  /// Generate a subtitle with highlighting for important information
  Widget _buildEnhancedSubtitle() {
    // Break down subtitle into parts that might need highlighting
    final parts = exercise.subtitle.split('•');
    
    if (parts.length <= 1) {
      // If there are no bullet points, just return the plain subtitle
      return Text(
        exercise.subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    // Build a rich subtitle with highlighted metrics
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          height: 1.3,
        ),
        children: _buildRichTextSpans(parts),
      ),
    );
  }
  
  /// Build rich text spans for subtitle highlighting
  List<TextSpan> _buildRichTextSpans(List<String> parts) {
    final List<TextSpan> spans = [];
    
    // Add the first part without a bullet
    if (parts[0].isNotEmpty) {
      spans.add(TextSpan(text: parts[0].trim()));
    }
    
    // Add the remaining parts with bullet points and highlighted values
    for (int i = 1; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      
      // Add bullet point
      spans.add(const TextSpan(text: ' • '));
      
      final String part = parts[i].trim();
      
      // Check if this part contains a colon (key-value pair)
      if (part.contains(':')) {
        final keyValue = part.split(':');
        final key = keyValue[0].trim();
        final value = keyValue.length > 1 ? keyValue[1].trim() : '';
        
        spans.add(TextSpan(text: key + ': '));
        spans.add(TextSpan(
          text: value,
          style: TextStyle(
            color: _getColorForActivityType(exercise.activityType),
            fontWeight: FontWeight.w600,
          ),
        ));
      } else {
        // No colon, just add the part as is
        spans.add(TextSpan(text: part));
      }
    }
    
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final activityColor = _getColorForActivityType(exercise.activityType);
    final activityIcon = _getIconForActivityType(exercise.activityType);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  activityIcon,
                  color: activityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Exercise Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exercise.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            exercise.timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildEnhancedSubtitle(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
