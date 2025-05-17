// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

// coverage:ignore-start
/// A widget that displays a shareable card with food analysis information.
///
/// This card is designed to be rendered offscreen and captured as an image for sharing.
/// It displays the food name in multiple places (header and image overlay), so when testing,
/// use `findsWidgets` instead of `findsOneWidget` when searching for food name text.
///
/// All Row widgets that contain Text should use Expanded with overflow: TextOverflow.ellipsis
/// to prevent layout overflow errors when text is too long.
class FoodSummaryCard extends StatelessWidget {
  final FoodAnalysisResult food;
  final GlobalKey cardKey;

  const FoodSummaryCard({
    super.key,
    required this.food,
    required this.cardKey,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate macronutrient percentages
    final totalCarbs = food.nutritionInfo.carbs.toInt();
    final totalProtein = food.nutritionInfo.protein.toInt();
    final totalFat = food.nutritionInfo.fat.toInt();
    final totalMacros = totalCarbs + totalProtein + totalFat;

    final carbPercentage =
        totalMacros > 0 ? (totalCarbs / totalMacros) * 100 : 0;
    final proteinPercentage =
        totalMacros > 0 ? (totalProtein / totalMacros) * 100 : 0;
    final fatPercentage = totalMacros > 0 ? (totalFat / totalMacros) * 100 : 0;

    // Make flexes at least 1 to avoid zero-sized divisions
    final carbFlex = carbPercentage.toInt() < 1 ? 1 : carbPercentage.toInt();
    final proteinFlex =
        proteinPercentage.toInt() < 1 ? 1 : proteinPercentage.toInt();
    final fatFlex = fatPercentage.toInt() < 1 ? 1 : fatPercentage.toInt();

    return RepaintBoundary(
      key: cardKey,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food image at the top with rounded corners
              _buildFoodImageHeader(),

              // Content padding
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PockEat branding & Calories
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/Logo_PockEat_draft_transparent.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF4CAF50),
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'PockEat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Color(0xFFFF9800),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${food.nutritionInfo.calories.toInt()} cal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Health Score indicator - enhanced
                    _buildHealthScoreIndicator(food),
                    const SizedBox(height: 16),

                    // Food name
                    Text(
                      food.foodName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Macronutrient bar and details
                    const Text(
                      'Macronutrients',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 14,
                        child: Row(
                          children: [
                            Expanded(
                              flex: carbFlex,
                              child: Container(color: Colors.amber),
                            ),
                            Expanded(
                              flex: proteinFlex,
                              child: Container(color: const Color(0xFF2196F3)),
                            ),
                            Expanded(
                              flex: fatFlex,
                              child: Container(color: const Color(0xFFE57373)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacronutrientItem(
                            'Carbs', '$totalCarbs g', Colors.amber),
                        _buildMacronutrientItem('Protein', '$totalProtein g',
                            const Color(0xFF2196F3)),
                        _buildMacronutrientItem(
                            'Fat', '$totalFat g', const Color(0xFFE57373)),
                      ],
                    ),

                    // Additional nutrients - show all defined attributes
                    _buildAdditionalNutrients(),

                    // Ingredients with calories - new section
                    _buildIngredientsSection(),

                    // Warning section (simplified)
                    if (food.warnings.isNotEmpty && food.warnings.length == 1)
                      _buildSimpleWarning(food.warnings.first)
                    else if (food.warnings.isNotEmpty)
                      _buildWarningCount(food.warnings.length),

                    // Footer branding
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'tracked with PockEat',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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

  // New method to display food image with proper rounded corners
  Widget _buildFoodImageHeader() {
    if (food.foodImageUrl == null || food.foodImageUrl!.isEmpty) {
      return _buildFoodImagePlaceholder();
    }

    return Container(
      width: double.infinity,
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            food.foodImageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
            errorBuilder: (context, error, stackTrace) {
              return _buildFoodImagePlaceholder();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              );
            },
          ),
          // Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
                stops: const [0.7, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 8),
            Text(
              food.foodName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced health score indicator
  Widget _buildHealthScoreIndicator(FoodAnalysisResult food) {
    // Determine color based on health score
    Color scoreColor;
    String scoreLabel;
    IconData scoreIcon;

    if (food.healthScore >= 7) {
      scoreColor = const Color(0xFF4CAF50); // Green
      scoreLabel = 'Excellent';
      scoreIcon = Icons.sentiment_very_satisfied;
    } else if (food.healthScore >= 4) {
      scoreColor = const Color(0xFFFF9800); // Orange
      scoreLabel = 'Fair';
      scoreIcon = Icons.sentiment_neutral;
    } else {
      scoreColor = const Color(0xFFE57373); // Red
      scoreLabel = 'Poor';
      scoreIcon = Icons.sentiment_dissatisfied;
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            scoreIcon,
            color: scoreColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Health Score: ${food.healthScore.toStringAsFixed(1)} - $scoreLabel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Show all defined additional nutrients, regardless of value
  Widget _buildAdditionalNutrients() {
    // Define all nutrients with their properties
    final additionalNutrients = <String, Map<String, dynamic>>{
      'Sodium': {
        'value': food.nutritionInfo.sodium,
        'unit': 'mg',
        'icon': Icons.water_drop,
        'color': Colors.blue
      },
      'Fiber': {
        'value': food.nutritionInfo.fiber,
        'unit': 'g',
        'icon': Icons.grass,
        'color': Colors.green
      },
      'Sugar': {
        'value': food.nutritionInfo.sugar,
        'unit': 'g',
        'icon': Icons.icecream,
        'color': Colors.pink
      },
      'Sat. Fat': {
        'value': food.nutritionInfo.saturatedFat,
        'unit': 'g',
        'icon': Icons.opacity,
        'color': Colors.orange
      },
      'Cholesterol': {
        'value': food.nutritionInfo.cholesterol,
        'unit': 'mg',
        'icon': Icons.medical_information,
        'color': Colors.purple
      },
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Additional Nutrients',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: additionalNutrients.entries.map((entry) {
            final String name = entry.key;
            final double value = entry.value['value'] as double;
            final String unit = entry.value['unit'] as String;
            final IconData icon = entry.value['icon'] as IconData;
            final Color color = entry.value['color'] as Color;

            return _buildNutrientChip(name, value, unit, icon, color);
          }).toList(),
        ),
      ],
    );
  }

  // New section to display ingredients with calories
  Widget _buildIngredientsSection() {
    if (food.ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            ...food.ingredients.take(5).map((ingredient) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    // Bullet point
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Ingredient name and calories
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              ingredient.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (ingredient.servings > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Color(0xFFFF9800),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${ingredient.servings} cal',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFF9800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Show ingredient count if there are more than 5
            if (food.ingredients.length > 5)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Center(
                  child: Text(
                    '+${food.ingredients.length - 5} more ingredients',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientChip(
      String name, double value, String unit, IconData icon, Color color) {
    // Format value appropriately (whole number for mg, 1 decimal place for g)
    String formattedValue;
    if (unit == 'mg') {
      formattedValue = '${value.round()} $unit';
    } else {
      formattedValue = '${value.toStringAsFixed(1)} $unit';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(value > 0 ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(value > 0 ? 0.3 : 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: value > 0 ? color : color.withOpacity(0.5),
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$name: $formattedValue',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value > 0 ? color : color.withOpacity(0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Simple warning display for a single warning
  Widget _buildSimpleWarning(String warning) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning,
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Warning count for multiple warnings
  Widget _buildWarningCount(int count) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count nutritional warnings',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              label[0],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end
