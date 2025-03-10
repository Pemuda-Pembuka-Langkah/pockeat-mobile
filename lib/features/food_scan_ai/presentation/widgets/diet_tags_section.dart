import 'package:flutter/material.dart';

class DietTagsSection extends StatelessWidget {
  final List<String> warnings;
  final Color primaryGreen;
  final Color warningYellow;

  const DietTagsSection({
    Key? key,
    required this.warnings,
    required this.primaryGreen,
    required this.warningYellow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Warnings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (warnings.isEmpty)
            _buildSafetyTag()
          else
            _buildWarningTags(),
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
      child: const Text(
        'The food is safe for consumption',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWarningTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: warnings.map((warning) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: warningYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: warningYellow.withOpacity(0.3)),
          ),
          child: Text(
            warning,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
} 