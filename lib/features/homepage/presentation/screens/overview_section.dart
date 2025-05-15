// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/calories_today_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/health_connect_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/nutrient_card_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/widgets/calories_today_widget.dart';
import 'package:pockeat/features/sync_fitness_tracker/widgets/health_connect_widget.dart';

class OverviewSection extends StatefulWidget {
  final DailyCalorieStats? stats;
  final int? targetCalories;
  final bool isLoading;
  final bool? isCalorieCompensationEnabled;
  final bool? isRolloverCaloriesEnabled;
  final int? rolloverCalories;

  const OverviewSection({
    super.key,
    this.isLoading = false,
    this.stats,
    this.targetCalories,
    this.isCalorieCompensationEnabled,
    this.isRolloverCaloriesEnabled,
    this.rolloverCalories,
  });

  @override
  State<OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<OverviewSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        2,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? primaryPink
                : primaryPink.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesToday() {
    return widget.isLoading
        ? const CaloriesTodaySkeleton()
        : CaloriesTodayWidget(
            stats: widget.stats,
            targetCalories: widget.targetCalories ?? 0,
            isCalorieCompensationEnabled:
                widget.isCalorieCompensationEnabled ?? false,
            isRolloverCaloriesEnabled:
                widget.isRolloverCaloriesEnabled ?? false,
            rolloverCalories: widget.rolloverCalories ?? 0,
          );
  }

  Widget _buildFitnessTrackerSection() {
    return widget.isLoading
        ? const HealthConnectSkeleton()
        : const HealthConnectWidget();
  }

  Widget _buildNutrientCard({
    required String title,
    required String current,
    required String target,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return widget.isLoading
        ? const NutrientCardSkeleton()
        : Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: iconColor, size: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: current,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '/$target',
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(
                height: 300,
                child: PageView(
                  physics: const BouncingScrollPhysics(),
                  controller: _pageController,
                  children: [
                    _buildCaloriesToday(),
                    _buildFitnessTrackerSection(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildPageIndicator(),
            ],
          ),

          // Nutrients Grid
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNutrientCard(
                  title: 'Protein',
                  current: '45',
                  target: '120g',
                  icon: Icons.egg_outlined,
                  iconColor: primaryPink,
                  bgColor: primaryPink.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutrientCard(
                  title: 'Carbs',
                  current: '156',
                  target: '250g',
                  icon: Icons.grain,
                  iconColor: primaryGreen,
                  bgColor: primaryGreen.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutrientCard(
                  title: 'Fat',
                  current: '32',
                  target: '65g',
                  icon: Icons.water_drop_outlined,
                  iconColor: primaryYellow,
                  bgColor: primaryYellow.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A widget that catches errors in its child during rendering
/// This is useful for testing when dependencies might not be properly mocked
class ErrorBoundaryWidget extends StatelessWidget {
  final Widget child;

  const ErrorBoundaryWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          // Return a placeholder widget instead of crashing
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Widget unavailable in test environment',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
      },
    );
  }
}
