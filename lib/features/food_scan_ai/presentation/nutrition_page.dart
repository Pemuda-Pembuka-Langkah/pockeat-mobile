import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/core/di/service_locator.dart';

class NutritionPage extends StatefulWidget {
  final String imagePath;
  final FoodScanPhotoService foodScanPhotoService;

  NutritionPage({super.key, required this.imagePath})
      : foodScanPhotoService = getIt<FoodScanPhotoService>();

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  bool _isScrolledToTop = true;
  bool _isLoading = true;
  String _foodName = 'Analyzing...';
  double _calories = 0;
  Map<String, dynamic> _nutritionData = {};
  List<String> _warnings = [];
  late FoodAnalysisResult food;

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color warningYellow = const Color(0xFFF4D03F);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _analyzeFoodImage());
  }

  Future<void> _analyzeFoodImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await widget.foodScanPhotoService
          .analyzeFoodPhoto(File(widget.imagePath));

      setState(() {
        _foodName = result.foodName;
        _calories = result.nutritionInfo.calories.toDouble();
        _nutritionData = {
          'protein': result.nutritionInfo.protein,
          'carbs': result.nutritionInfo.carbs,
          'fat': result.nutritionInfo.fat,
          'fiber': result.nutritionInfo.fiber,
          'sugar': result.nutritionInfo.sugar,
          'sodium': result.nutritionInfo.sodium,
        };
        _isLoading = false;
        _warnings = result.warnings;
        food = result;
      });
    } catch (e) {
      setState(() {
        _foodName = 'Analysis Failed';
        _isLoading = false;
      });
      // Tampilkan error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to analyze food: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              _isScrolledToTop = scrollNotification.metrics.pixels < 100;
            });
          }
          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor:
                  _isScrolledToTop ? Colors.transparent : primaryYellow,
              elevation: 0,
              title: Text(
                'Nutrition Analysis',
                style: TextStyle(
                  color: _isScrolledToTop ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              leading: CupertinoButton(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: _isScrolledToTop ? Colors.white : Colors.black87,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoButton(
                  child: Icon(
                    CupertinoIcons.share,
                    color: _isScrolledToTop ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {},
                ),
                CupertinoButton(
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: _isScrolledToTop ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            // Content
            SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Title Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isLoading ? 'Analyzing...' : _foodName,
                                        key: const Key('food_title'),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.visible,
                                        maxLines: 2,
                                        softWrap: true,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isLoading ? '' : '1 plate • 300g',
                                        key: const Key('food_portion'),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        '92',
                                        key: Key('food_score'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Score',
                                        key: Key('food_score_text'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Calorie Summary Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isLoading ? '--' : '$_calories',
                                        key: Key('food_calories'),
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'calories',
                                        key: Key('food_calories_text'),
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryPink,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '22% of daily goal',
                                      key: Key('food_calories_goal'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.22,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryPink),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // AI Analysis
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(CupertinoIcons.sparkles,
                                      color: primaryGreen),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'AI Analysis',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '• High protein content aligns well with your fitness goals\n'
                                '• Consider adding vegetables to increase fiber intake\n'
                                '• Sodium content is within your daily limit\n'
                                '• Good pre-workout meal option',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Macro Details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nutritional Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Column(
                                children: [
                                  _buildMacroItem(
                                    'Protein',
                                    _isLoading
                                        ? 0
                                        : (_nutritionData['protein'] ?? 0),
                                    120,
                                    primaryPink,
                                    subtitle: _isLoading
                                        ? 'Loading...'
                                        : '${(_nutritionData['protein'] ?? 0) * 100 ~/ 120}% of daily goal',
                                  ),
                                  const Divider(height: 1),
                                  _buildMacroItem(
                                    'Carbs',
                                    _isLoading
                                        ? 0
                                        : (_nutritionData['carbs'] ?? 0),
                                    250,
                                    primaryGreen,
                                    subtitle: _isLoading
                                        ? 'Loading...'
                                        : '${(_nutritionData['carbs'] ?? 0) * 100 ~/ 250}% of daily goal',
                                  ),
                                  const Divider(height: 1),
                                  _buildMacroItem(
                                    'Fat',
                                    _isLoading
                                        ? 0
                                        : (_nutritionData['fat'] ?? 0),
                                    65,
                                    warningYellow,
                                    subtitle: _isLoading
                                        ? 'Loading...'
                                        : '${(_nutritionData['fat'] ?? 0) * 100 ~/ 65}% of daily goal',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Additional Nutrients
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildNutrientsGrid(),
                      ),

                      // Diet Tags
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildDietTags(),
                      ),

                      // Recommendations
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recommendations',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryYellow.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.lightbulb_fill,
                                    color: primaryPink,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Add a side of vegetables to increase your fiber intake and reach your daily nutrition goals.',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black12,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: primaryYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  key: const Key('fix_button'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.wand_stars,
                            size: 20, color: primaryPink),
                        const SizedBox(width: 6),
                        const Text(
                          'Fix',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Material(
                color: primaryPink,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  key: const Key('add_to_log_button'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    if (!_isLoading) {
                      try {
                        final message = await widget.foodScanPhotoService
                            .saveFoodAnalysis(food);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Gagal menyimpan: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.plus,
                            color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Add to Log',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, double value, double total, Color color,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$value of ${total}g',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / total,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutrientsGrid() {
    final nutrients = [
      {
        'name': 'Fiber',
        'value': _isLoading ? '0g' : '${_nutritionData['fiber'] ?? 0}g',
        'goal': '25g'
      },
      {
        'name': 'Sugar',
        'value': _isLoading ? '0g' : '${_nutritionData['sugar'] ?? 0}g',
        'goal': '25g'
      },
      {
        'name': 'Sodium',
        'value': _isLoading ? '0mg' : '${_nutritionData['sodium'] ?? 0}mg',
        'goal': '2300mg'
      },
      {
        'name': 'Calories',
        'value': _isLoading ? '0' : '$_calories',
        'goal': '2000'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: nutrients.length,
      itemBuilder: (context, index) {
        final nutrient = nutrients[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryYellow.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nutrient['name']!,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nutrient['value']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'of ${nutrient['goal']}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDietTags() {
    return Column(
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
        if (_warnings.isEmpty)
          Container(
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
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _warnings.map((warning) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          ),
      ],
    );
  }
}
