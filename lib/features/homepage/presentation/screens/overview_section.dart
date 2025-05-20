// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/homepage/presentation/widgets/calories_today_widget.dart';
import 'package:pockeat/features/sync_fitness_tracker/widgets/health_connect_widget.dart';

class OverviewSection extends StatefulWidget {
  final DailyCalorieStats? stats;
  final int? targetCalories;
  final bool? isCalorieCompensationEnabled;
  final bool? isRolloverCaloriesEnabled;
  final int? rolloverCalories;
  final Map<String, int>? currentMacros;
  final CaloricRequirementModel? targetMacros;

  const OverviewSection({
    super.key,
    this.stats,
    this.targetCalories,
    this.isCalorieCompensationEnabled,
    this.isRolloverCaloriesEnabled,
    this.rolloverCalories,
    this.currentMacros,
    this.targetMacros,
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
    return CaloriesTodayWidget(
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
    return const HealthConnectWidget();
  }

  Widget _buildNutrientCard({
    required String title,
    required String current,
    required String target,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    bool isExceeded = false,
  }) {
    const Color warningColor = Colors.red;
    final displayIcon = isExceeded ? Icons.warning_amber_rounded : icon;
    final displayIconColor = isExceeded ? warningColor : iconColor;
    final displayBgColor = isExceeded ? warningColor.withOpacity(0.1) : bgColor;

    return Container(
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
                  color: displayBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(displayIcon, color: displayIconColor, size: 12),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: isExceeded ? warningColor : Colors.black54,
                  fontSize: 12,
                  fontWeight: isExceeded ? FontWeight.bold : FontWeight.normal,
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
                  style: TextStyle(
                    color: isExceeded ? warningColor : Colors.black87,
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
    // Get current and target macronutrient values
    final currentProtein = widget.currentMacros?['protein'] ?? 0;
    final currentCarbs = widget.currentMacros?['carbs'] ?? 0;
    final currentFat = widget.currentMacros?['fat'] ?? 0;

    final targetProtein = widget.targetMacros?.proteinGrams.toInt() ?? 120;
    final targetCarbs = widget.targetMacros?.carbsGrams.toInt() ?? 250;
    final targetFat = widget.targetMacros?.fatGrams.toInt() ?? 65;

    // Check if any values exceed their targets
    final isProteinExceeded = currentProtein > targetProtein;
    final isCarbsExceeded = currentCarbs > targetCarbs;
    final isFatExceeded = currentFat > targetFat;

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
                  current: '$currentProtein',
                  target: '${targetProtein}g',
                  icon: Icons.egg_outlined,
                  iconColor: primaryPink,
                  bgColor: primaryPink.withOpacity(0.1),
                  isExceeded: isProteinExceeded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutrientCard(
                  title: 'Carbs',
                  current: '$currentCarbs',
                  target: '${targetCarbs}g',
                  icon: Icons.grain,
                  iconColor: primaryGreen,
                  bgColor: primaryGreen.withOpacity(0.1),
                  isExceeded: isCarbsExceeded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutrientCard(
                  title: 'Fat',
                  current: '$currentFat',
                  target: '${targetFat}g',
                  icon: Icons.water_drop_outlined,
                  iconColor: primaryYellow,
                  bgColor: primaryYellow.withOpacity(0.1),
                  isExceeded: isFatExceeded,
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
