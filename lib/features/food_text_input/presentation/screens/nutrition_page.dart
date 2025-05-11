// Flutter imports:
//

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/additional_nutrients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/calorie_summary_card.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_loading.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_title_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/health_score_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/ingredients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutritional_info_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/vitamins_and_minerals_section.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/food_text_input_analysis_error.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/text_bottom_action_bar.dart';

class NutritionPage extends StatefulWidget {
  final String foodText;
  final FoodTextInputService foodTextInputService;

  const NutritionPage(
      {super.key, required this.foodText, required this.foodTextInputService});

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  bool _isScrolledToTop = true;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isSaving = false;
  String _foodName = 'Analyzing...';
  double _calories = 0; // Changed from int to double
  Map<String, dynamic> _nutritionData = {};
  List<String> _warnings = [];
  List<Ingredient> _ingredients = [];
  late FoodAnalysisResult? food;

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color warningYellow = const Color(0xFFF4D03F);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _analyzeFoodText());
  }

  Future<void> _analyzeFoodText() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final result =
          await widget.foodTextInputService.analyzeFoodText(widget.foodText);

      setState(() {
        _updateFoodData(result);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _updateFoodData(FoodAnalysisResult result, {bool isCorrection = false}) {
    _foodName = result.foodName;
    _calories = result.nutritionInfo.calories;
    _nutritionData = {
      'protein': result.nutritionInfo.protein,
      'carbs': result.nutritionInfo.carbs,
      'fat': result.nutritionInfo.fat,
      'fiber': result.nutritionInfo.fiber,
      'sugar': result.nutritionInfo.sugar,
      'sodium': result.nutritionInfo.sodium,
      'saturatedFat': result.nutritionInfo.saturatedFat,
      'cholesterol': result.nutritionInfo.cholesterol,
      'nutritionDensity': result.nutritionInfo.nutritionDensity,
      'healthScore': result.healthScore,
      'healthScoreCategory': result.getHealthScoreCategory(),
    };
    _ingredients = result.ingredients;
    _warnings = result.warnings;
    food = result;

    if (!isCorrection) {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: FoodAnalysisLoading(
          primaryYellow: primaryYellow,
          primaryPink: primaryPink,
          message: 'Analyzing Food',
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: FoodTextInputAnalysisError(
          primaryPink: primaryPink,
          primaryYellow: primaryYellow,
          onRetry: _analyzeFoodText,
          onBack: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildAnalysisResultContent(),
      bottomSheet: TextBottomActionBar(
          isLoading: _isLoading || _isSaving,
          food: food,
          foodTextInputService: widget.foodTextInputService,
          primaryYellow: primaryYellow,
          primaryPink: primaryPink,
          primaryGreen: primaryGreen,
          onAnalysisCorrected: (FoodAnalysisResult correctedResult) {
            setState(() {
              _updateFoodData(correctedResult, isCorrection: true);
            });
          },
          onSavingStateChange: (bool saving) {
            setState(() {
              _isSaving = saving;
            });
          }),
    );
  }

  Widget _buildAnalysisResultContent() {
    return NotificationListener<ScrollNotification>(
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
            backgroundColor: primaryYellow,
            title: const Text(
              'Nutrition Analysis',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            floating: true,
            pinned: true,
            elevation: _isScrolledToTop ? 0 : 4,
          ),
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
                    FoodTitleSection(
                      isLoading: _isLoading,
                      foodName: _foodName,
                      primaryGreen: primaryGreen,
                      healthScore: _nutritionData['healthScore'] as double?,
                      healthCategory:
                          _nutritionData['healthScoreCategory'] as String?,
                    ),
                    CalorieSummaryCard(
                      isLoading: _isLoading,
                      calories: _calories,
                      primaryYellow: primaryYellow,
                      primaryPink: primaryPink,
                    ),
                    // Add Health Score Section
                    HealthScoreSection(
                      isLoading: _isLoading,
                      nutritionData: _nutritionData,
                      primaryGreen: primaryGreen,
                      primaryPink: primaryPink,
                    ),
                    NutritionalInfoSection(
                      isLoading: _isLoading,
                      nutritionData: _nutritionData,
                      primaryPink: primaryPink,
                      primaryGreen: primaryGreen,
                      warningYellow: warningYellow,
                    ),
                    AdditionalNutrientsSection(
                      isLoading: _isLoading,
                      nutritionData: _nutritionData,
                      calories: _calories,
                      primaryYellow: primaryYellow,
                    ),
                    IngredientsSection(
                      ingredients: _ingredients,
                      primaryGreen: primaryGreen,
                      isLoading: _isLoading,
                    ),
                    VitaminsAndMineralsSection(
                      isLoading: _isLoading,
                      food: food,
                      primaryColor: primaryGreen,
                    ),
                    // Vitamins and Minerals Section
                    DietTagsSection(
                      warnings: _warnings,
                      primaryGreen: primaryGreen,
                      warningYellow: warningYellow,
                    ),
                    const SizedBox(height: 100),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
