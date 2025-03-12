import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutrition_app_bar.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/bottom_action_bar.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_title_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/calorie_summary_card.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutritional_info_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/additional_nutrients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/ingredients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_loading.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_error.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_scan_page.dart';
import 'package:camera/camera.dart';

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
  bool _hasError = false;
  String _errorMessage = '';
  String _foodName = 'Analyzing...';
  int _calories = 0;
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
    Future.microtask(() => _analyzeFoodImage());
  }

  Future<void> _analyzeFoodImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final result = await widget.foodScanPhotoService
          .analyzeFoodPhoto(File(widget.imagePath));

      setState(() {
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
        _isLoading = false;
        _warnings = result.warnings;
        food = result;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _retryPhotoCapture() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScanFoodPage(cameraController: CameraController(
              CameraDescription(
                name: '0',
                lensDirection: CameraLensDirection.back,
                sensorOrientation: 0,
              ),
              ResolutionPreset.max,
            ),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: FoodAnalysisLoading(
          primaryYellow: primaryYellow,
          primaryPink: primaryPink,
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: FoodAnalysisError(
          errorMessage: _errorMessage,
          primaryPink: primaryPink,
          primaryYellow: primaryYellow,
          onRetry: _retryPhotoCapture,
          onBack: () => Navigator.pop(context),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildAnalysisResultContent(),
      bottomSheet: BottomActionBar(
        isLoading: _isLoading,
        food: food,
        foodScanPhotoService: widget.foodScanPhotoService,
        primaryYellow: primaryYellow,
        primaryPink: primaryPink,
      ),
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
          NutritionAppBar(
            isScrolledToTop: _isScrolledToTop,
            imagePath: widget.imagePath,
            primaryYellow: primaryYellow,
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
                    FoodTitleSection(
                      isLoading: _isLoading,
                      foodName: _foodName,
                      primaryGreen: primaryGreen,
                    ),
                    CalorieSummaryCard(
                      isLoading: _isLoading,
                      calories: _calories,
                      primaryYellow: primaryYellow,
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
                    DietTagsSection(
                      warnings: _warnings,
                      primaryGreen: primaryGreen,
                      warningYellow: warningYellow,
                    ),
                    const SizedBox(height: 100),
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
