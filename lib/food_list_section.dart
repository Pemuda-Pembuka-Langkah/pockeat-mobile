import 'package:flutter/material.dart';

Widget buildCaloriesByFoods() {
  // Data struktur yang menyimpan total konsumsi per makanan
  final List<FoodConsumption> foodConsumptions = [
    FoodConsumption(
      name: 'White Rice',
      portion: '1 cup (158g)',
      caloriesPerServing: 200,
      totalServings: 3, // 3x makan (breakfast, lunch, dinner)
      imagePath: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSsoXPqMWeu76TgfRXiFLnV7vEee0Wdr8uCXA&s',
    ),
    FoodConsumption(
      name: 'Chicken Breast',
      portion: '100g',
      caloriesPerServing: 165,
      totalServings: 2, // 2x makan (lunch & dinner)
      imagePath: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrpy00P1laaOiH3FH1oCWKtH8BMse2DYIdNA&s',
    ),
    FoodConsumption(
      name: 'Eggs',
      portion: '1 large',
      caloriesPerServing: 70,
      totalServings: 2, // 2 butir
      imagePath: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ--6ksABrErROnRjv12yumEyJM7iImOAMOmQ&s',
    ),

    FoodConsumption(
      name: 'White Bread',
      portion: '1 slice',
      caloriesPerServing: 110,
      totalServings: 4, // 4 slices
      imagePath: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRy6LIwYTLHVj9wTIn3whrgfXGQWXAoGJ1eZQ&s',
    ),
    FoodConsumption(
      name: 'Banana',
      portion: '1 medium',
      caloriesPerServing: 105,
      totalServings: 2, // 2 buah
      imagePath: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGHPr49bv2cMFJZ0z9WfjG3dqS8Wor6ghljw&s',
    ),
  ];

  // Sort berdasarkan total kalori (tertinggi ke terendah)
  foodConsumptions.sort((a, b) => b.totalCalories.compareTo(a.totalCalories));

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Calories Distributed by Foods',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: foodConsumptions.map((food) {
            return Column(
              children: [
                _buildFoodCalorieItem(food),
                if (food != foodConsumptions.last)
                  const Divider(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildFoodCalorieItem(FoodConsumption food) {
  return Row(
    children: [
      // Food Image
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          food.imagePath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 12),
      // Food Details
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${food.portion} × ${food.totalServings}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      // Total Calories
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${food.totalCalories} kcal',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${food.caloriesPerServing} × ${food.totalServings}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ],
  );
}

class FoodConsumption {
  final String name;
  final String portion;
  final int caloriesPerServing;
  final int totalServings;
  final String imagePath;

  FoodConsumption({
    required this.name,
    required this.portion,
    required this.caloriesPerServing,
    required this.totalServings,
    required this.imagePath,
  });

  int get totalCalories => caloriesPerServing * totalServings;
}