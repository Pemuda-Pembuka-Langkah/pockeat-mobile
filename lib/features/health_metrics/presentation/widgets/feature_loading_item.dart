import 'package:flutter/material.dart';

class FeatureLoadingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isLoaded;
  final Color primaryColor;
  final Color textDarkColor;

  const FeatureLoadingItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isLoaded,
    required this.primaryColor,
    required this.textDarkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feature icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLoaded
                  ? primaryColor.withOpacity(0.1)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isLoaded ? primaryColor : Colors.grey,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Feature title and processing text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDarkColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoaded ? "Completed" : "Processing...",
                  style: TextStyle(
                    fontSize: 14,
                    color: isLoaded
                        ? primaryColor
                        : textDarkColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Checkmark indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: isLoaded ? primaryColor : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: isLoaded
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isLoaded
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
