import 'package:flutter/material.dart';

class AddFoodLogPage extends StatefulWidget {
  @override
  _AddFoodLogPageState createState() => _AddFoodLogPageState();
}

class _AddFoodLogPageState extends State<AddFoodLogPage> with SingleTickerProviderStateMixin {
  final Color primaryYellow = Color(0xFFFFE893);
  final Color primaryPink = Color(0xFFFF6B6B);
  final Color primaryGreen = Color(0xFF4ECDC4);

  late TabController _tabController;
  final _promptController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  // Sample food database
  List<Map<String, dynamic>> foodDatabase = [
 // Carbs
 {
   'name': 'White Rice',
   'calories': 130,
   'unit': 'serving',
   'protein': 2.7,
   'carbs': 28,
   'fat': 0.3,
   'category': 'Carbs'
 },
 {
   'name': 'Potato',
   'calories': 77,
   'unit': '100g',
   'protein': 2.0,
   'carbs': 17,
   'fat': 0.1,
   'category': 'Carbs'
 },
 {
   'name': 'Instant Noodle',
   'calories': 138,
   'unit': 'pack',
   'protein': 3.0,
   'carbs': 25,
   'fat': 3.3,
   'category': 'Carbs'
 },
 {
   'name': 'White Bread',
   'calories': 66,
   'unit': 'slice',
   'protein': 2,
   'carbs': 12,
   'fat': 1,
   'category': 'Carbs'
 },

 // Protein
 {
   'name': 'Chicken Breast',
   'calories': 165,
   'unit': 'piece',
   'protein': 31,
   'carbs': 0,
   'fat': 3.6,
   'category': 'Protein'
 },
 {
   'name': 'Egg',
   'calories': 155,
   'unit': 'piece',
   'protein': 13,
   'carbs': 1.1,
   'fat': 11,
   'category': 'Protein'
 },
 {
   'name': 'Salmon',
   'calories': 208,
   'unit': '100g',
   'protein': 22,
   'carbs': 0,
   'fat': 13,
   'category': 'Protein'
 },
 {
   'name': 'Tofu',
   'calories': 76,
   'unit': 'piece',
   'protein': 8,
   'carbs': 1.9,
   'fat': 4.8,
   'category': 'Protein'
 },
 {
   'name': 'Tempeh',
   'calories': 193,
   'unit': 'piece',
   'protein': 19,
   'carbs': 9.4,
   'fat': 11,
   'category': 'Protein'
 },

 // Vegetables  
 {
   'name': 'Spinach',
   'calories': 23,
   'unit': 'bowl',
   'protein': 2.9,
   'carbs': 3.6,
   'fat': 0.4,
   'category': 'Vegetables'
 },
 {
   'name': 'Carrot',
   'calories': 41,
   'unit': '100g',
   'protein': 0.9,
   'carbs': 9.6,
   'fat': 0.2,
   'category': 'Vegetables'
 },
 {
   'name': 'Broccoli',
   'calories': 34,
   'unit': '100g',
   'protein': 2.8,
   'carbs': 7,
   'fat': 0.4,
   'category': 'Vegetables'
 },

 // Fruits
 {
   'name': 'Banana',
   'calories': 89,
   'unit': 'piece',
   'protein': 1.1,
   'carbs': 23,
   'fat': 0.3,
   'category': 'Fruits'
 },
 {
   'name': 'Apple',
   'calories': 52,
   'unit': 'piece',
   'protein': 0.3,
   'carbs': 14,
   'fat': 0.2,
   'category': 'Fruits'
 },
 {
   'name': 'Orange',
   'calories': 47,
   'unit': 'piece',
   'protein': 0.9,
   'carbs': 12,
   'fat': 0.1,
   'category': 'Fruits'
 },

 // Fats & Oils
 {
   'name': 'Cooking Oil',
   'calories': 884,
   'unit': 'tablespoon',
   'protein': 0,
   'carbs': 0,
   'fat': 100,
   'category': 'Fats & Oils'
 },
 {
   'name': 'Butter',
   'calories': 717,
   'unit': 'tablespoon',
   'protein': 0.9,
   'carbs': 0.1,
   'fat': 81,
   'category': 'Fats & Oils'
 },
];

  List<Map<String, dynamic>> selectedFoods = [];
  Map<String, dynamic>? aiPrediction;

  Map<String, double> totalNutrition = {
    'calories': 0,
    'protein': 0,
    'carbs': 0,
    'fat': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Food',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryGreen,
          unselectedLabelColor: Colors.black54,
          indicatorColor: primaryGreen,
          tabs: [
            Tab(text: 'AI Assistant'),
            Tab(text: 'Pilih Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAIPromptTab(),
          _buildManualInputTab(),
        ],
      ),
    );
  }

  Widget _buildAIPromptTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explain your food',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Example: 1 serving of white rice with 1 piece of fried chicken',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          TextField(
 controller: _promptController,
 maxLines: 3,
 decoration: InputDecoration(
   hintText: 'Type here...',
   border: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
   ),
   filled: true,
   fillColor: Colors.white,
 ),
),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _analyzeFood,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Analyze Food'),
            ),
          ),
          if (aiPrediction != null) _buildAIPredictionResult(),
        ],
      ),
    );
  }

  Widget _buildManualInputTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Food...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ],
          ),
        ),
        // Food List with Categories
        Expanded(
          child: DefaultTabController(
            length: 5, // Number of categories
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: primaryGreen,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: primaryGreen,
                  tabs: [
                    Tab(text: 'Carbs'),
Tab(text: 'Protein'),
Tab(text: 'Vegetables'),
Tab(text: 'Fruits'),
Tab(text: 'Fats & Oils'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildFoodListByCategory('Carbs'),
                      _buildFoodListByCategory('Protein'),
                      _buildFoodListByCategory('Vegetables'),
                      _buildFoodListByCategory('Fruits'),
                      _buildFoodListByCategory('Fats and Oils'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedFoods.isNotEmpty) _buildNutritionSummary(),
      ],
    );
  }

  Widget _buildFoodListByCategory(String category) {
    final filteredFoods = foodDatabase.where((food) {
      final matchesCategory = food['category'] == category;
      final matchesSearch = food['name'].toString().toLowerCase().contains(_searchQuery);
      return matchesCategory && (_searchQuery.isEmpty || matchesSearch);
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredFoods.length,
      itemBuilder: (context, index) {
        final food = filteredFoods[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              food['name'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  '${food['calories']} kcal/${food['unit']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'P: ${food['protein']}g | K: ${food['carbs']}g | L: ${food['fat']}g',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.add_circle, color: primaryGreen),
              onPressed: () => _addFood(food),
            ),
          ),
        );
      },
    );
  }


  Widget _buildFoodList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: foodDatabase.length,
      itemBuilder: (context, index) {
        final food = foodDatabase[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(food['name']),
            subtitle: Text(
              '${food['calories']} kcal/${food['unit']}',
              style: TextStyle(color: Colors.black54),
            ),
            trailing: IconButton(
              icon: Icon(Icons.add_circle_outline, color: primaryGreen),
              onPressed: () => _addFood(food),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedFoods() {
    if (selectedFoods.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Selected Food(s)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: selectedFoods.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final food = selectedFoods[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['name'],
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${food['calories']} kcal/${food['unit']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixText: food['unit'],
                        ),
                        onChanged: (value) => _updateAmount(index, value),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: primaryPink),
                      onPressed: () => _removeFood(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _nutritionItem('Calori', totalNutrition['calories']!, 'kcal', primaryPink),
              _nutritionItem('Protein', totalNutrition['protein']!, 'g', primaryGreen),
              _nutritionItem('Carb', totalNutrition['carbs']!, 'g', primaryYellow),
              _nutritionItem('Fat', totalNutrition['fat']!, 'g', Colors.blue),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveFoodLog,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPredictionResult() {
    return Container(
      margin: EdgeInsets.only(top: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Results',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildNutritionRow('Calories', '${aiPrediction!['calories']} kcal'),
_buildNutritionRow('Protein', '${aiPrediction!['protein']}g'),
_buildNutritionRow('Carbs', '${aiPrediction!['carbs']}g'),
_buildNutritionRow('Fat', '${aiPrediction!['fat']}g'),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAIPrediction,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionItem(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _addFood(Map<String, dynamic> food) {
    setState(() {
      selectedFoods.add({...food, 'amount': 1});
      _calculateTotalNutrition();
    });
  }

  void _removeFood(int index) {
    setState(() {
      selectedFoods.removeAt(index);
      _calculateTotalNutrition();
    });
  }

  void _updateAmount(int index, String value) {
    final amount = double.tryParse(value) ?? 0;
    setState(() {
      selectedFoods[index]['amount'] = amount;
      _calculateTotalNutrition();
    });
  }

  void _calculateTotalNutrition() {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (var food in selectedFoods) {
      final amount = food['amount'] ?? 0;
      calories += food['calories'] * amount;
      protein += food['protein'] * amount;
      carbs += food['carbs'] * amount;
      fat += food['fat'] * amount;
    }

    setState(() {
      totalNutrition = {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
    });
  }

  Future<void> _analyzeFood() async {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please explain your food')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement AI API call
      await Future.delayed(Duration(seconds: 2));
      
      setState(() {
        aiPrediction = {
          'name': 'Nasi dengan Ayam Goreng',
          'calories': 450,
          'protein': 22,
          'carbs': 65,
          'fat': 12,
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menganalisis makanan: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveAIPrediction() {
    // TODO: Implement save logic for AI prediction
    Navigator.pop(context);
  }

  void _saveFoodLog() {
    // TODO: Implement save logic for manual input
    Navigator.pop(context);
  }
}