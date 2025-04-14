import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/food_entry_form_page.dart';
import 'package:pockeat/features/food_text_input/presentation/screens/nutrition_page.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';

class FoodTextInputPage extends StatelessWidget {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  const FoodTextInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Food Details',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your food details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPink.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FoodEntryForm(
                    onSaved: (FoodEntry foodEntry) {
                      final foodText = foodEntry.foodDescription; 
                      final foodTextInputService = getIt<FoodTextInputService>(); 

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NutritionPage(
                            foodText: foodText,
                            foodTextInputService: foodTextInputService,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
