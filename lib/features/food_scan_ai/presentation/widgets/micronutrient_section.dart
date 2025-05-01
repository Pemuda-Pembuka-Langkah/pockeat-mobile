// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

/// A widget that displays detailed micronutrient information (vitamins and minerals)
/// from a food analysis result. This is designed to complement the standard
/// nutritional information by highlighting often overlooked micronutrient content.
class MicronutrientSection extends StatelessWidget {
  final bool isLoading;
  final FoodAnalysisResult? food;
  final Color primaryColor;
  final Color secondaryColor;

  const MicronutrientSection({
    super.key,
    required this.isLoading,
    required this.food,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || food == null) {
      return _buildLoadingState();
    }

    // Check if there are any micronutrients to display
    if (food!.nutritionInfo.vitaminsAndMinerals.isEmpty) {
      return _buildEmptyState();
    }

    // Separate vitamins and minerals for better organization
    final vitamins = <String, double>{};
    final minerals = <String, double>{};

    food!.nutritionInfo.vitaminsAndMinerals.forEach((key, value) {
      if (key.contains('vitamin')) {
        vitamins[key] = value;
      } else {
        minerals[key] = value;
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Micronutrients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vitamins and minerals contribution to daily values',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Vitamins section
          if (vitamins.isNotEmpty) ...[
            Text(
              'Vitamins',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildNutrientGrid(vitamins, primaryColor),
            const SizedBox(height: 20),
          ],

          // Minerals section
          if (minerals.isNotEmpty) ...[
            Text(
              'Minerals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildNutrientGrid(minerals, secondaryColor),
          ],

          // Reference note
          const SizedBox(height: 24),
          Text(
            'Values shown as percentage of daily recommended intake',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNutrientGrid(Map<String, double> nutrients, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: nutrients.length,
        itemBuilder: (context, index) {
          final entry = nutrients.entries.elementAt(index);
          final name = _formatNutrientName(entry.key);
          final value = entry.value;

          return _buildNutrientTile(name, value, color);
        },
      ),
    );
  }

  Widget _buildNutrientTile(String name, double value, Color color) {
    // Determine the fill level based on % daily value
    final double percentage = value > 100 ? 1.0 : value / 100;

    // Determine color shade based on value
    Color fillColor;
    if (value >= 50) {
      fillColor = color;
    } else if (value >= 15) {
      fillColor = color.withOpacity(0.7);
    } else {
      fillColor = color.withOpacity(0.4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(fillColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: fillColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNutrientName(String key) {
    // Convert snake_case to Title Case with special handling for vitamins
    final parts = key.split('_');
    final formattedParts = parts.map((part) {
      if (part.toLowerCase() == 'b' && parts.length > 1) {
        // Handle B vitamins (B6, B12)
        final nextPartIndex = parts.indexOf(part) + 1;
        if (nextPartIndex < parts.length &&
            int.tryParse(parts[nextPartIndex]) != null) {
          return 'B${parts[nextPartIndex]}';
        }
      }

      // Standard capitalization for other parts
      return part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : '';
    }).toList();

    // Handle special cases like "vitamin_a" -> "Vitamin A"
    if (formattedParts.isNotEmpty &&
        formattedParts[0].toLowerCase() == 'vitamin') {
      return 'Vitamin ${formattedParts.sublist(1).join(" ")}';
    }

    return formattedParts.join(' ');
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Micronutrients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Micronutrients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No detailed micronutrient information available for this food.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
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
}
