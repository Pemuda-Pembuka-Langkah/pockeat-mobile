// Flutter imports:
import 'package:flutter/material.dart';

// // Project imports:
// import 'package:pockeat/features/api_scan/models/food_analysis.dart';

class DietTagsSection extends StatelessWidget {
  final List<String> warnings;
  final Color primaryGreen;
  final Color warningYellow;
  final Map<String, dynamic>? additionalInformation;

  const DietTagsSection({
    super.key,
    required this.warnings,
    required this.primaryGreen,
    required this.warningYellow,
    this.additionalInformation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warnings Section
          const Text(
            'Warnings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (warnings.isEmpty) _buildSafetyTag() else _buildWarningTags(),
        ],
      ),
    );
  }

  Widget _buildSafetyTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: primaryGreen,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'No nutritional concerns detected',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: warnings.map((warning) {
        IconData warningIcon;

        // Choose appropriate icon based on warning content
        if (warning.contains('sodium')) {
          warningIcon = Icons.water_drop;
        } else if (warning.contains('sugar')) {
          warningIcon = Icons.icecream;
        } else if (warning.contains('cholesterol')) {
          warningIcon = Icons.medical_information;
        } else if (warning.contains('fat')) {
          warningIcon = Icons.opacity;
        } else {
          warningIcon = Icons.warning_amber;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: warningYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: warningYellow.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                warningIcon,
                color: warningYellow,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  warning,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
