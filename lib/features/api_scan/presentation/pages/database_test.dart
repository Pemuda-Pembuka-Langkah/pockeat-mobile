// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:pockeat/features/api_scan/models/food_analysis.dart';
// import 'package:pockeat/features/food_database_input/services/food/food_database_service.dart';
// import 'package:pockeat/features/food_database_input/services/base/supabase.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NutritionDatabaseTestPage extends StatefulWidget {
//   const NutritionDatabaseTestPage({Key? key}) : super(key: key);

//   @override
//   State<NutritionDatabaseTestPage> createState() =>
//       _NutritionDatabaseTestPageState();
// }

// class _NutritionDatabaseTestPageState extends State<NutritionDatabaseTestPage> {
//   final NutritionDatabaseServiceInterface _nutritionService =
//       GetIt.instance<NutritionDatabaseServiceInterface>();

//   // Service connection status
//   bool _isSupabaseConnected = false;
//   bool _isFirebaseConnected = false;
//   bool _isCheckingConnections = true;

//   // State variables
//   List<FoodAnalysisResult> _searchResults = [];
//   List<FoodAnalysisResult> _selectedFoods = [];
//   FoodAnalysisResult? _currentMeal;
//   List<FoodAnalysisResult> _savedMeals = [];
//   bool _isLoading = false;
//   bool _isSearching = false;
//   String _statusMessage = '';
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _mealNameController = TextEditingController();
//   final List<TextEditingController> _componentCountControllers = [];
//   final _formKey = GlobalKey<FormState>();
//   // Map to store current portion values for selected foods
//   final Map<int, double> _portionValues = {};

//   @override
//   void initState() {
//     super.initState();
//     _checkServiceConnections();
//   }

//   // Check if Supabase and Firebase are connected
//   Future<void> _checkServiceConnections() async {
//     setState(() {
//       _isCheckingConnections = true;
//     });

//     try {
//       // Check Supabase connection by making a simple query
//       final supabaseService = GetIt.instance<SupabaseService>();
//       final testData =
//           await supabaseService.fetchFromTable('nutrition_data', limit: 1);
//       _isSupabaseConnected = testData.isNotEmpty;
//     } catch (e) {
//       _isSupabaseConnected = false;
//       //print('Supabase connection error: $e');
//     }

//     try {
//       // Check Firebase connection
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         _isFirebaseConnected = true;
//       } else {
//         // Try to access Firestore as anonymous user
//         await FirebaseFirestore.instance
//             .collection('connection_test')
//             .doc('test')
//             .get();
//         _isFirebaseConnected = true;
//       }
//     } catch (e) {
//       _isFirebaseConnected = false;
//       //print('Firebase connection error: $e');
//     }

//     setState(() {
//       _isCheckingConnections = false;
//     });
//   }

//   // Retry connection checks
//   void _retryConnectionChecks() {
//     _checkServiceConnections();
//   }

//   void _searchFoods() async {
//     if (_searchController.text.trim().isEmpty) return;

//     setState(() {
//       _isSearching = true;
//       _statusMessage = 'Searching for "${_searchController.text}"...';
//     });

//     try {
//       final results =
//           await _nutritionService.searchFoods(_searchController.text.trim());
//       setState(() {
//         _searchResults = results;
//         _isSearching = false;
//         _statusMessage = 'Found ${results.length} results';
//       });
//     } catch (e) {
//       setState(() {
//         _isSearching = false;
//         _statusMessage = 'Search error: $e';
//       });
//     }
//   }

//   void _addFoodToSelection(FoodAnalysisResult food) {
//     setState(() {
//       _selectedFoods.add(food);

//       // Initialize portion value for the new food
//       final index = _selectedFoods.length - 1;
//       final initialPortion =
//           food.ingredients.isNotEmpty ? food.ingredients[0].servings : 100.0;
//       _portionValues[index] = initialPortion;

//       // Add a new component count controller
//       _componentCountControllers.add(TextEditingController(text: "1"));

//       _statusMessage = 'Added ${food.foodName} to meal';
//     });
//   }

//   void _adjustPortion(int index, double grams) async {
//     if (index < 0 || index >= _selectedFoods.length) return;

//     final selectedFood = _selectedFoods[index];

//     try {
//       int foodId;

//       // Handle different ID formats:
//       // 1. Regular food item: "food_123"
//       // 2. Portion-adjusted food: "portion_food_123_100g"
//       if (selectedFood.id.startsWith('food_')) {
//         // Extract the database ID by removing the 'food_' prefix
//         String idString = selectedFood.id.replaceAll('food_', '');
//         foodId = int.parse(idString);
//       } else if (selectedFood.id.startsWith('portion_')) {
//         // Extract the original food ID from additional information
//         if (selectedFood.additionalInformation
//             .containsKey('original_food_id')) {
//           String originalId =
//               selectedFood.additionalInformation['original_food_id'];
//           originalId = originalId.replaceAll('food_', '');
//           foodId = int.parse(originalId);
//         } else {
//           // Try to extract from portion ID format: "portion_food_123_100g"
//           final parts = selectedFood.id.split('_');
//           if (parts.length >= 3) {
//             foodId = int.parse(parts[2]); // Extract the numeric ID
//           } else {
//             throw Exception('Cannot determine food ID from ${selectedFood.id}');
//           }
//         }
//       } else {
//         throw Exception('Unsupported food ID format: ${selectedFood.id}');
//       }

//       // Store the new portion value in the map
//       _portionValues[index] = grams;

//       setState(() {
//         _statusMessage = 'Adjusting portion...';
//         // We don't set _isLoading to true here to allow multiple adjustments
//       });

//       // Call the service method with the correct parameters
//       final adjustedFood = await _nutritionService.adjustPortion(foodId, grams);

//       if (mounted) {
//         setState(() {
//           _selectedFoods[index] = adjustedFood;
//           _statusMessage = 'Adjusted portion to ${grams.toStringAsFixed(2)}g';
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _statusMessage = 'Error adjusting portion: $e';
//         });
//       }
//     }
//   }

//   void _removeFood(int index) {
//     if (index < 0 || index >= _selectedFoods.length) return;

//     setState(() {
//       final removedFood = _selectedFoods.removeAt(index);
//       _statusMessage = 'Removed ${removedFood.foodName}';
//     });
//   }

//   void _createMeal() {
//     if (!_formKey.currentState!.validate()) return;

//     if (_selectedFoods.isEmpty) {
//       setState(() {
//         _statusMessage = 'Please add at least one food to create a meal';
//       });
//       return;
//     }

//     // Create a map of component counts from the controller values
//     Map<String, dynamic> componentInfo = {};
//     List<Map<String, dynamic>> components = [];

//     // Process each food item with its component count and portion
//     for (int i = 0; i < _selectedFoods.length; i++) {
//       final food = _selectedFoods[i];
//       final countText = _componentCountControllers[i].text;

//       // Parse component count (default to 1 if invalid)
//       int count = 1;
//       try {
//         count = int.parse(countText);
//         if (count < 1) count = 1; // Ensure minimum count of 1
//       } catch (e) {
//         //print('Invalid component count for ${food.foodName}: $e');
//       }

//       // Get the adjusted portion for this food
//       final portion = _portionValues[i] ??
//           (food.ingredients.isNotEmpty ? food.ingredients[0].servings : 100.0);

//       // Add to components list
//       components.add({
//         'id': food.id,
//         'name': food.foodName,
//         'count': count,
//         'portion': portion,
//       });
//     }

//     // Add component info to meal metadata
//     componentInfo['components'] = components;
//     componentInfo['component_count'] = components.length;

//     setState(() {
//       // Create meal with additional component information
//       _currentMeal = _nutritionService.createLocalMeal(
//           _mealNameController.text.trim(), _selectedFoods,
//           additionalInformation: componentInfo);
//       _statusMessage =
//           'Created meal "${_mealNameController.text}" with ${components.length} components';
//     });
//   }

//   void _clearMeal() {
//     setState(() {
//       _currentMeal = null;
//       _selectedFoods.clear();
//       _mealNameController.clear();
//       _statusMessage = 'Cleared current meal';
//     });
//   }

//   // Helper methods for formatting
//   String _formatDate(DateTime date) {
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
//         '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   String _formatNutrientName(String name) {
//     // Replace underscores with spaces
//     String formattedName = name.replaceAll('_', ' ');

//     // Capitalize first letter of each word
//     formattedName = formattedName.split(' ').map((word) {
//       if (word.isEmpty) return '';
//       return word[0].toUpperCase() + word.substring(1);
//     }).join(' ');

//     return formattedName;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Nutrition Database Test'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _retryConnectionChecks,
//             tooltip: 'Check connections',
//           )
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Connection status card
//                 Card(
//                   elevation: 4,
//                   color: _isSupabaseConnected && _isFirebaseConnected
//                       ? Colors.green[50]
//                       : Colors.red[50],
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: _isCheckingConnections
//                         ? const Center(
//                             child: Column(
//                               children: [
//                                 CircularProgressIndicator(),
//                                 SizedBox(height: 8),
//                                 Text('Checking service connections...'),
//                               ],
//                             ),
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Service Status',
//                                 style: Theme.of(context).textTheme.titleLarge,
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     _isSupabaseConnected
//                                         ? Icons.check_circle
//                                         : Icons.error,
//                                     color: _isSupabaseConnected
//                                         ? Colors.green
//                                         : Colors.red,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   const Text('Supabase Connection:'),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     _isSupabaseConnected
//                                         ? 'Connected'
//                                         : 'Failed',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: _isSupabaseConnected
//                                           ? Colors.green
//                                           : Colors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     _isFirebaseConnected
//                                         ? Icons.check_circle
//                                         : Icons.error,
//                                     color: _isFirebaseConnected
//                                         ? Colors.green
//                                         : Colors.red,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   const Text('Firebase Connection:'),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     _isFirebaseConnected
//                                         ? 'Connected'
//                                         : 'Failed',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: _isFirebaseConnected
//                                           ? Colors.green
//                                           : Colors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               if (!_isSupabaseConnected ||
//                                   !_isFirebaseConnected)
//                                 const Padding(
//                                   padding: EdgeInsets.only(top: 8.0),
//                                   child: Text(
//                                     'Some features may not work properly without connection to both services.',
//                                     style: TextStyle(
//                                       fontStyle: FontStyle.italic,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Search section
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Food Search',
//                           style: Theme.of(context).textTheme.titleLarge),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: _searchController,
//                               decoration: const InputDecoration(
//                                 hintText:
//                                     'Search for foods (e.g., apple, chicken)',
//                                 border: OutlineInputBorder(),
//                               ),
//                               onFieldSubmitted: (_) => _searchFoods(),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             onPressed: _isSearching || !_isSupabaseConnected
//                                 ? null
//                                 : _searchFoods,
//                             child:
//                                 Text(_isSearching ? 'Searching...' : 'Search'),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 16),

//                       // Meal name input
//                       Text('Create Meal',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _mealNameController,
//                         decoration: const InputDecoration(
//                           hintText: 'Enter meal name',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Please enter a meal name';
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Search results
//                 if (_searchResults.isNotEmpty) ...[
//                   Text('Search Results',
//                       style: Theme.of(context).textTheme.titleMedium),
//                   const SizedBox(height: 8),
//                   Container(
//                     height: 200,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: ListView.builder(
//                       itemCount: _searchResults.length,
//                       itemBuilder: (context, index) {
//                         final food = _searchResults[index];
//                         return ListTile(
//                           title: Text(food.foodName),
//                           subtitle: Text(
//                               'Cal: ${food.nutritionInfo.calories.toStringAsFixed(2)} | '
//                               'P: ${food.nutritionInfo.protein.toStringAsFixed(2)}g | '
//                               'C: ${food.nutritionInfo.carbs.toStringAsFixed(2)}g | '
//                               'F: ${food.nutritionInfo.fat.toStringAsFixed(2)}g'),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.add),
//                             onPressed: () => _addFoodToSelection(food),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],

//                 const SizedBox(height: 16),

//                 // Selected foods for meal
//                 Text('Selected Foods',
//                     style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: _selectedFoods.isEmpty
//                       ? const Padding(
//                           padding: EdgeInsets.all(16.0),
//                           child: Center(child: Text('No foods selected yet')),
//                         )
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: _selectedFoods.length,
//                           itemBuilder: (context, index) {
//                             final food = _selectedFoods[index];
//                             // Use the stored portion value from the map if available
//                             final portion = _portionValues[index] ??
//                                 (food.ingredients.isNotEmpty
//                                     ? food.ingredients[0].servings
//                                     : 100.0);

//                             return Card(
//                               margin: const EdgeInsets.symmetric(vertical: 4),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             food.foodName,
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.delete,
//                                               color: Colors.red),
//                                           onPressed: () => _removeFood(index),
//                                           iconSize: 20,
//                                           padding: EdgeInsets.zero,
//                                           constraints: const BoxConstraints(),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                         'Cal: ${food.nutritionInfo.calories.toStringAsFixed(1)} | '
//                                         'P: ${food.nutritionInfo.protein.toStringAsFixed(1)}g | '
//                                         'C: ${food.nutritionInfo.carbs.toStringAsFixed(1)}g | '
//                                         'F: ${food.nutritionInfo.fat.toStringAsFixed(1)}g'),
//                                     const SizedBox(height: 8),

//                                     // Portion adjustment
//                                     Row(
//                                       children: [
//                                         const Text('Portion: '),
//                                         Text('${portion.toStringAsFixed(1)}g',
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold)),
//                                         const Spacer(),
//                                         // Component count input
//                                         SizedBox(
//                                           width: 90,
//                                           child: Row(
//                                             children: [
//                                               const Text('Count: '),
//                                               Expanded(
//                                                 child: TextFormField(
//                                                   controller:
//                                                       _componentCountControllers[
//                                                           index],
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   textAlign: TextAlign.center,
//                                                   decoration:
//                                                       const InputDecoration(
//                                                     contentPadding:
//                                                         EdgeInsets.symmetric(
//                                                             vertical: 8,
//                                                             horizontal: 8),
//                                                     isDense: true,
//                                                     border: OutlineInputBorder(
//                                                       borderRadius:
//                                                           BorderRadius.all(
//                                                               Radius.circular(
//                                                                   4)),
//                                                     ),
//                                                   ),
//                                                   onChanged: (value) {
//                                                     // Handle component count change
//                                                     setState(() {
//                                                       _statusMessage =
//                                                           'Updated component count';
//                                                     });
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 4),

//                                     // Slider for portion adjustment
//                                     Slider(
//                                       min: 10,
//                                       max: 500,
//                                       divisions: 49,
//                                       label: '${portion.toStringAsFixed(1)}g',
//                                       value: portion,
//                                       onChanged: (value) =>
//                                           _adjustPortion(index, value),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Current meal details
//                 if (_currentMeal != null) ...[
//                   Text('Current Meal',
//                       style: Theme.of(context).textTheme.titleMedium),
//                   const SizedBox(height: 8),
//                   Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(_currentMeal!.foodName,
//                               style: Theme.of(context).textTheme.titleLarge),
//                           const Divider(),

//                           // Nutritional Summary
//                           Text('Nutritional Summary',
//                               style: Theme.of(context).textTheme.titleSmall),
//                           const SizedBox(height: 4),
//                           Text(
//                               'Calories: ${_currentMeal!.nutritionInfo.calories.toStringAsFixed(2)} kcal'),
//                           Text(
//                               'Protein: ${_currentMeal!.nutritionInfo.protein.toStringAsFixed(2)}g'),
//                           Text(
//                               'Carbs: ${_currentMeal!.nutritionInfo.carbs.toStringAsFixed(2)}g'),
//                           Text(
//                               'Fat: ${_currentMeal!.nutritionInfo.fat.toStringAsFixed(2)}g'),
//                           Text(
//                               'Saturated Fat: ${_currentMeal!.nutritionInfo.saturatedFat.toStringAsFixed(2)}g'),
//                           Text(
//                               'Sodium: ${_currentMeal!.nutritionInfo.sodium.toStringAsFixed(2)}g'),
//                           Text(
//                               'Sugar: ${_currentMeal!.nutritionInfo.sugar.toStringAsFixed(2)}g'),
//                           Text(
//                               'Fiber: ${_currentMeal!.nutritionInfo.fiber.toStringAsFixed(2)}g'),
//                           Text(
//                               'Cholesterol: ${_currentMeal!.nutritionInfo.cholesterol.toStringAsFixed(2)}mg'),

//                           const SizedBox(height: 8),

//                           // Health Score
//                           Row(
//                             children: [
//                               Text(
//                                   'Health Score: ${_currentMeal!.healthScore.toStringAsFixed(2)}',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: _currentMeal!.healthScore > 7
//                                         ? Colors.green
//                                         : _currentMeal!.healthScore > 4
//                                             ? Colors.orange
//                                             : Colors.red,
//                                   )),
//                               const SizedBox(width: 8),
//                               Text(
//                                   '(${_currentMeal!.getHealthScoreCategory()})'),
//                             ],
//                           ),

//                           const Divider(),

//                           // Ingredients Section
//                           Text(
//                               'Ingredients (${_currentMeal!.ingredients.length})',
//                               style: Theme.of(context).textTheme.titleSmall),
//                           const SizedBox(height: 4),
//                           ListView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: _currentMeal!.ingredients.length,
//                             itemBuilder: (context, index) {
//                               final ingredient =
//                                   _currentMeal!.ingredients[index];

//                               // Find the matching food item to get its calories
//                               String calorieInfo = "";
//                               if (_currentMeal!.additionalInformation
//                                       .containsKey('components') &&
//                                   _currentMeal!
//                                           .additionalInformation['components']
//                                       is List) {
//                                 final components =
//                                     List<Map<String, dynamic>>.from(
//                                         _currentMeal!.additionalInformation[
//                                             'components']);
//                                 if (index < components.length) {
//                                   final portion = components[index]['portion'];
//                                   // Get calories from selected foods if they exist
//                                   if (_selectedFoods.isNotEmpty &&
//                                       index < _selectedFoods.length) {
//                                     final calories = _selectedFoods[index]
//                                         .nutritionInfo
//                                         .calories;
//                                     calorieInfo =
//                                         " (${portion.toStringAsFixed(2)}g, ${calories.toStringAsFixed(2)} kcal)";
//                                   }
//                                 }
//                               }

//                               return Padding(
//                                 padding: const EdgeInsets.only(
//                                     left: 8.0, bottom: 2.0),
//                                 child: Text(
//                                     '• ${ingredient.name} - ${ingredient.servings.toStringAsFixed(2)}g$calorieInfo'),
//                               );
//                             },
//                           ),

//                           const SizedBox(height: 8),

//                           // Warnings Section
//                           if (_currentMeal!.warnings.isNotEmpty) ...[
//                             Text('Warnings',
//                                 style: Theme.of(context).textTheme.titleSmall),
//                             const SizedBox(height: 4),
//                             ...(_currentMeal!.warnings.map((w) => Text('• $w',
//                                 style: const TextStyle(color: Colors.red)))),
//                           ],

//                           const SizedBox(height: 8),

//                           // Vitamins & Minerals (if available)
//                           if (_currentMeal!.nutritionInfo.vitaminsAndMinerals
//                               .isNotEmpty) ...[
//                             ExpansionTile(
//                               title: Text('Vitamins & Minerals',
//                                   style:
//                                       Theme.of(context).textTheme.titleSmall),
//                               children: [
//                                 Wrap(
//                                   spacing: 12,
//                                   runSpacing: 4,
//                                   children: _currentMeal!
//                                       .nutritionInfo.vitaminsAndMinerals.entries
//                                       .map((entry) => Chip(
//                                             label: Text(
//                                               '${_formatNutrientName(entry.key)}: ${entry.value.toStringAsFixed(2)}',
//                                               style:
//                                                   const TextStyle(fontSize: 12),
//                                             ),
//                                             backgroundColor: Colors.blue[50],
//                                           ))
//                                       .toList(),
//                                 ),
//                                 const SizedBox(height: 8),
//                               ],
//                             ),
//                           ],

//                           // Additional Information
//                           ExpansionTile(
//                             title: Text('Additional Information',
//                                 style: Theme.of(context).textTheme.titleSmall),
//                             children: [
//                               ListView(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 children: [
//                                   ListTile(
//                                     dense: true,
//                                     title: Text('Meal ID: ${_currentMeal!.id}'),
//                                   ),
//                                   if (_currentMeal!.additionalInformation
//                                       .containsKey('component_count'))
//                                     ListTile(
//                                       dense: true,
//                                       title: Text(
//                                           'Component Count: ${_currentMeal!.additionalInformation['component_count']}'),
//                                     ),
//                                   ListTile(
//                                     dense: true,
//                                     title: Text(
//                                         'Created: ${_formatDate(_currentMeal!.timestamp)}'),
//                                   ),
//                                   ListTile(
//                                     dense: true,
//                                     title: Text(
//                                         'User ID: ${_currentMeal!.userId}'),
//                                   ),
//                                   ListTile(
//                                     dense: true,
//                                     title: Text(
//                                         'Saved to Firebase: ${_currentMeal!.additionalInformation['saved_to_firebase'] ?? 'No'}'),
//                                   ),
//                                   if (_currentMeal!.additionalInformation
//                                       .containsKey('nutrition_density'))
//                                     ListTile(
//                                       dense: true,
//                                       title: Text(
//                                           'Nutrition Density: ${double.parse(_currentMeal!.additionalInformation['nutrition_density'].toString()).toStringAsFixed(2)}'),
//                                     ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],

//                 const SizedBox(height: 16),

//                 // Display saved meals
//                 Text('Saved Meals',
//                     style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 _isLoading && _savedMeals.isEmpty
//                     ? const Center(child: CircularProgressIndicator())
//                     : _savedMeals.isEmpty
//                         ? const Center(child: Text('No saved meals found'))
//                         : ListView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: _savedMeals.length,
//                             itemBuilder: (context, index) {
//                               final meal = _savedMeals[index];
//                               return Card(
//                                 margin: const EdgeInsets.only(bottom: 8),
//                                 child: ListTile(
//                                   title: Text(meal.foodName),
//                                   subtitle: Text(
//                                       'Cal: ${meal.nutritionInfo.calories.toStringAsFixed(2)} | '
//                                       'P: ${meal.nutritionInfo.protein.toStringAsFixed(2)}g | '
//                                       'C: ${meal.nutritionInfo.carbs.toStringAsFixed(2)}g | '
//                                       'F: ${meal.nutritionInfo.fat.toStringAsFixed(2)}g'),
//                                 ),
//                               );
//                             },
//                           ),

//                 const SizedBox(height: 16),

//                 // Status message
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   color: Colors.grey[200],
//                   width: double.infinity,
//                   child: Text(_statusMessage),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _mealNameController.dispose();
//     for (var controller in _componentCountControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }
