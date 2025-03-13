import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_text_input/presentation/pages/food_text_input_page.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/text_input_nutrition_app_bar.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/bottom_action_bar.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_title_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/calorie_summary_card.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutritional_info_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/additional_nutrients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/ingredients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_loading.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_error.dart';

class NutritionPage extends StatefulWidget {
  final String foodText;
  final FoodTextInputService foodTextInputService;

  NutritionPage({super.key, required this.foodText, required this.foodTextInputService});

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _foodName = 'Analyzing...';
  int _calories = 0;
  Map<String, dynamic> _nutritionData = {};
  List<String> _warnings = [];
  List<Ingredient> _ingredients = [];
  late FoodAnalysisResult? food;

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

      final result = await widget.foodTextInputService.analyzeFoodText(widget.foodText);

      setState(() {
        _updateFoodData(result);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _updateFoodData(FoodAnalysisResult result) {
    _foodName = result.foodName;
    _calories = result.nutritionInfo.calories.toInt();
    _nutritionData = {
      'protein': result.nutritionInfo.protein.toInt(),
      'carbs': result.nutritionInfo.carbs.toInt(),
      'fat': result.nutritionInfo.fat.toInt(),
      'fiber': result.nutritionInfo.fiber.toInt(),
      'sugar': result.nutritionInfo.sugar.toInt(),
      'sodium': result.nutritionInfo.sodium.toInt(),
    };
    _ingredients = result.ingredients;
    _warnings = result.warnings;
    food = result;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: FoodAnalysisLoading(
          primaryYellow: const Color(0xFFFFE893),
          primaryPink: const Color(0xFFFF6B6B),
          message: 'Analyzing Food Text',
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: FoodAnalysisError(
          errorMessage: _errorMessage,
          primaryPink: const Color(0xFFFF6B6B),
          primaryYellow: const Color(0xFFFFE893),
          onRetry: _analyzeFoodText,
          onBack: () => Navigator.pop(context),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildAnalysisResultContent(),
      bottomSheet: TextBottomActionBar(
        isLoading: _isLoading,
        food: food,
        foodTextInputService: widget.foodTextInputService,
        primaryYellow: const Color(0xFFFFE893),
        primaryPink: const Color(0xFFFF6B6B),
        primaryGreen: const Color(0xFF4ECDC4),
      ),
    );
  }

  Widget _buildAnalysisResultContent() {
    return CustomScrollView(
      slivers: [
        // Simple SliverAppBar with no background image
        SliverAppBar(
          backgroundColor: const Color(0xFFFFE893),
          title: const Text(
            'Nutrition Analysis',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          floating: true,
          pinned: true,
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
                    primaryGreen: const Color(0xFF4ECDC4),
                  ),
                  CalorieSummaryCard(
                    isLoading: _isLoading,
                    calories: _calories,
                    primaryYellow: const Color(0xFFFFE893),
                    primaryPink: const Color(0xFFFF6B6B),
                  ),
                  NutritionalInfoSection(
                    isLoading: _isLoading,
                    nutritionData: _nutritionData,
                    primaryPink: const Color(0xFFFF6B6B),
                    primaryGreen: const Color(0xFF4ECDC4),
                    warningYellow: const Color(0xFFF4D03F),
                  ),
                  AdditionalNutrientsSection(
                    isLoading: _isLoading,
                    nutritionData: _nutritionData,
                    calories: _calories,
                    primaryYellow: const Color(0xFFFFE893),
                  ),
                  IngredientsSection(
                    ingredients: _ingredients,
                    primaryGreen: const Color(0xFF4ECDC4),
                    isLoading: _isLoading,
                  ),
                  DietTagsSection(
                    warnings: _warnings,
                    primaryGreen: const Color(0xFF4ECDC4),
                    warningYellow: const Color(0xFFF4D03F),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}