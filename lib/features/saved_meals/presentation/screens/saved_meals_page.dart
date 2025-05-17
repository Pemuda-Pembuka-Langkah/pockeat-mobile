// Flutter imports:
//

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/saved_meals/domain/models/saved_meal.dart';
import 'package:pockeat/features/saved_meals/domain/services/saved_meal_service.dart';
import 'package:pockeat/features/saved_meals/presentation/widgets/saved_meal_card.dart';

class SavedMealsPage extends StatefulWidget {
  final SavedMealService savedMealService;

  const SavedMealsPage({super.key, required this.savedMealService});

  @override
  State<SavedMealsPage> createState() => _SavedMealsPageState();
}

class _SavedMealsPageState extends State<SavedMealsPage> {
  String _searchQuery = '';

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Saved Meals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            //coverage:ignore-start
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  //coverage:ignore-end
                });
              },
              decoration: InputDecoration(
                hintText: 'Search saved meals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SavedMeal>>(
              stream: widget.savedMealService.getSavedMeals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final meals = snapshot.data ?? [];
                final filteredMeals = _searchQuery.isEmpty
                    ? meals
                    : meals
                        //coverage:ignore-start
                        .where((meal) =>
                            meal.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            meal.foodAnalysis.foodName
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                        .toList();
                //coverage:ignore-end

                if (filteredMeals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_food,
                          size: 72,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No saved meals yet'
                              : 'No meals match your search',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 24),
                          ElevatedButton(
                            //coverage:ignore-start
                            onPressed: () {
                              // Navigate to food input page
                              Navigator.of(context).pushNamed('/analytic',
                                  arguments: {'initialTabIndex': 1});
                              //coverage:ignore-end
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Save your first meal!'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredMeals.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final savedMeal = filteredMeals[index];
                    return SavedMealCard(
                      savedMeal: savedMeal,
                      //coverage:ignore-start
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/saved-meal-detail',
                          arguments: {
                            'savedMealId': savedMeal.id,
                            //coverage:ignore-end
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        //coverage:ignore-start
        onPressed: () {
          Navigator.pushNamed(context, '/add-food');
          //coverage:ignore-end
        },
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
