// Dart imports:
//
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:camera/camera.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/food_scan_ai/presentation/screens/food_scan_page.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/additional_nutrients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/bottom_action_bar.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/calorie_summary_card.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_error.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_loading.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_title_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/health_score_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/ingredients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutrition_app_bar.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutritional_info_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/vitamins_and_minerals_section.dart';

class NutritionPage extends StatefulWidget {
  final String imagePath;
  final bool isLabelScan;
  final FoodScanPhotoService foodScanPhotoService;
  final double servingSize;

  NutritionPage({
    super.key,
    required this.imagePath,
    this.isLabelScan = false,
    this.servingSize = 1.0,
  }) : foodScanPhotoService = getIt<FoodScanPhotoService>();

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  bool _isScrolledToTop = true;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _foodName = 'Analyzing...';
  double _calories = 0; // Changed from int to double
  Map<String, dynamic> _nutritionData = {};
  List<String> _warnings = [];
  List<Ingredient> _ingredients = [];
  late FoodAnalysisResult? food;

  // Track if analysis is being corrected
  bool _isCorrectingAnalysis = false;

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

      final result = widget.isLabelScan
          ? await widget.foodScanPhotoService.analyzeNutritionLabelPhoto(
              File(widget.imagePath), widget.servingSize)
          : await widget.foodScanPhotoService
              .analyzeFoodPhoto(File(widget.imagePath));

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

  // Update UI data with analysis result
  void _updateFoodData(FoodAnalysisResult result) {
    _foodName = result.foodName;
    _calories =
        result.nutritionInfo.calories; // Use calories directly as double
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
  }

  // Handle analysis correction
  void _handleAnalysisCorrected(FoodAnalysisResult correctedResult) {
    // Debug prints to see correction response data
    print('=========== CORRECTION RESPONSE ===========');
    print('Food Name: ${correctedResult.foodName}');
    print('Calories: ${correctedResult.nutritionInfo.calories}');
    print('Health Score: ${correctedResult.healthScore}');
    print('Vitamins: ${correctedResult.nutritionInfo.vitaminsAndMinerals}');
    print('========================================');

    // Calculate health score if not provided by API response
    double calculatedHealthScore = correctedResult.healthScore ?? 5.0;
    String healthCategory = "Fair"; // Default medium category

    // Use healthScore to determine category if available
    if (correctedResult.healthScore != null) {
      if (calculatedHealthScore >= 8)
        healthCategory = "Excellent";
      else if (calculatedHealthScore >= 6)
        healthCategory = "Good";
      else if (calculatedHealthScore >= 4)
        healthCategory = "Fair";
      else if (calculatedHealthScore >= 2)
        healthCategory = "Poor";
      else
        healthCategory = "Very Poor";
    }

    // Ensure state update is synchronous and complete
    setState(() {
      _isCorrectingAnalysis = false;
      food = correctedResult; // Update the food object first
      _updateFoodData(correctedResult); // Then update all the derived data

      // Force update of health score section data with calculated values
      _nutritionData['healthScore'] = calculatedHealthScore;
      _nutritionData['healthScoreCategory'] = healthCategory;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analysis corrected successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _retryPhotoCapture() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScanFoodPage(
          cameraController: CameraController(
            const CameraDescription(
              name: '0',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0,
            ),
            ResolutionPreset.max,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isCorrectingAnalysis) {
      return Scaffold(
        body: FoodAnalysisLoading(
          primaryYellow: primaryYellow,
          primaryPink: primaryPink,
          message:
              _isCorrectingAnalysis ? 'Correcting Analysis' : 'Analyzing Food',
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
        isLoading: _isLoading || _isCorrectingAnalysis,
        food: food,
        foodScanPhotoService: widget.foodScanPhotoService,
        primaryYellow: primaryYellow,
        primaryPink: primaryPink,
        primaryGreen: primaryGreen,
        isLabelScan: widget.isLabelScan,
        servingSize: widget.servingSize,
        onAnalysisCorrected: (correctedResult) {
          setState(() {
            _isCorrectingAnalysis = true;
          });

          // Process the correction asynchronously and update UI when done
          Future.delayed(Duration.zero, () {
            _handleAnalysisCorrected(correctedResult);
          });
        },
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
                    // Health Score Section here
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
                    // Vitamins and Minerals Section
                    VitaminsAndMineralsSection(
                      isLoading: _isLoading,
                      food: food,
                      primaryColor: primaryGreen,
                    ),
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
