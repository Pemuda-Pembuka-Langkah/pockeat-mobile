import 'package:flutter/material.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

class FoodDetailPage extends StatelessWidget {
  final FoodAnalysisResult food;

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  const FoodDetailPage({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(food.foodName),
        backgroundColor: primaryYellow,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar makanan
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: primaryYellow.withOpacity(0.2),
              ),
              child: food.foodImageUrl != null && food.foodImageUrl!.isNotEmpty
                  ? Image.network(
                      food.foodImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 80,
                            color: primaryPink,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 80,
                        color: primaryPink,
                      ),
                    ),
            ),
            
            // Informasi makanan
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.foodName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Kartu informasi nutrisi
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Nutrisi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildNutrientRow('Kalori', '${food.nutritionInfo.calories.toInt()} kkal'),
                          _buildNutrientRow('Protein', '${food.nutritionInfo.protein.toInt()}g'),
                          _buildNutrientRow('Karbohidrat', '${food.nutritionInfo.carbs.toInt()}g'),
                          _buildNutrientRow('Lemak', '${food.nutritionInfo.fat.toInt()}g'),
                          _buildNutrientRow('Serat', '${food.nutritionInfo.fiber.toInt()}g'),
                          _buildNutrientRow('Gula', '${food.nutritionInfo.sugar.toInt()}g'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 