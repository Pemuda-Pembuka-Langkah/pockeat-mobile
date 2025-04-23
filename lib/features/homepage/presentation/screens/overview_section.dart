// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/homepage/presentation/widgets/calories_today_widget.dart';
import 'package:pockeat/features/sync_fitness_tracker/widgets/health_connect_widget.dart';

class OverviewSection extends StatefulWidget {
  const OverviewSection({super.key});

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
    return const CaloriesTodayWidget();
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
  }) {
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
                  current: '25',
                  target: '65g',
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFFFFB946),
                  bgColor: const Color(0xFFFFB946).withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
