import 'package:flutter/material.dart';
import 'package:pockeat/features/homepage/presentation/widgets/calories_today_widget.dart';
import 'package:pockeat/features/homepage/presentation/screens/pet_section.dart';
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

        // Pet Section
        const SizedBox(height: 24),
        const PetSection(),

        // Weekly Stats
        const SizedBox(height: 24),
        const Text(
          'Weekly Overview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1,850',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Avg. daily calories',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '5/7 days on track',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ...List.generate(7, (index) {
                      final values = [1600, 1800, 1750, 1950, 2100, 1800, 1850];
                      final days = ['S', 'S', 'M', 'T', 'W', 'T', 'F'];
                      final isToday = index == 6;
                      final value = values[index];
                      final servings = value / 2500;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$value',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 140 * servings,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: isToday
                                      ? primaryPink
                                      : primaryPink.withOpacity(0.2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                days[index],
                                style: TextStyle(
                                  color:
                                      isToday ? Colors.black87 : Colors.black54,
                                  fontSize: 12,
                                  fontWeight: isToday
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryYellow.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryPink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Daily Goal: 2000 kcal',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
