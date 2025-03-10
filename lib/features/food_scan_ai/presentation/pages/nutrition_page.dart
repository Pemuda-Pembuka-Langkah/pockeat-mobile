import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutrition_app_bar.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/bottom_action_bar.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_title_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/calorie_summary_card.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/ai_analysis_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/nutritional_info_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/additional_nutrients_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/recommendations_section.dart';

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
                      AIAnalysisSection(
                        primaryGreen: primaryGreen,
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
                      DietTagsSection(
                        warnings: _warnings,
                        primaryGreen: primaryGreen,
                        warningYellow: warningYellow,
                      ),
                      RecommendationsSection(
                        primaryYellow: primaryYellow,
                        primaryPink: primaryPink,
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
      bottomSheet: BottomActionBar(
        isLoading: _isLoading,
        food: _isLoading ? null : food,
        foodScanPhotoService: widget.foodScanPhotoService,
        primaryYellow: primaryYellow,
        primaryPink: primaryPink,
      ),
    );
  }
}
