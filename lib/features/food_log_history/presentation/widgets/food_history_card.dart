import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';

/// Widget untuk menampilkan item makanan dalam history log
///
/// Widget ini menampilkan informasi makanan dalam bentuk card
/// dengan gambar (jika ada), judul, subtitle, dan waktu
class FoodHistoryCard extends StatelessWidget {
  final FoodLogHistoryItem food;
  final VoidCallback? onTap;

  // Colors
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color primaryOrange = const Color(0xFFFF9800);

  const FoodHistoryCard({
    super.key,
    required this.food,
    this.onTap,
  });

  /// Generate a subtitle with highlighting for important information
  Widget _buildEnhancedSubtitle() {
    // Break down subtitle into parts that might need highlighting
    final parts = food.subtitle.split('•');
    
    if (parts.length <= 1) {
      // If there are no bullet points, just return the plain subtitle
      return Text(
        food.subtitle,
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
        
        spans.add(TextSpan(text: '$key: '));
        spans.add(TextSpan(
          text: value,
          style: TextStyle(
            color: primaryGreen,
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

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              // Food Icon (replacing image)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.cart_fill,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Food Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            food.title,
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
                            _getTimeAgo(food.timestamp),
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
                    const SizedBox(height: 8),
                    // Calories badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.flame_fill,
                                color: primaryOrange,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${food.calories.toInt()} cal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
