// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';

class HealthValuePropositionPage extends StatefulWidget {
  const HealthValuePropositionPage({super.key});

  @override
  State<HealthValuePropositionPage> createState() =>
      _HealthValuePropositionPageState();
}

class _HealthValuePropositionPageState extends State<HealthValuePropositionPage>
    with SingleTickerProviderStateMixin {
  // Colors from the app's design system
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Setup animation for chart
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Chart legend item
  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textDarkColor,
          ),
        ),
      ],
    );
  }

  // Build weight comparison chart
  Widget _buildWeightComparisonChart(double animationValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String text = '';
                  if (value == 0) {
                    text = 'Month 1';
                  } else if (value == 5) {
                    text = 'Month 6';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 5,
          minY: 0,
          maxY: 5,
          lineTouchData: const LineTouchData(
            enabled: false,
          ),
          lineBarsData: [
            // Traditional diet line (goes up after initial success)
            LineChartBarData(
              spots: [
                const FlSpot(0, 3.5), // Starting weight
                FlSpot(1, 3.0 - (0.5 * animationValue)), // Initial drop
                FlSpot(2, 2.5 - (0.2 * animationValue)), // Small continued loss
                FlSpot(3, 3.0 + (1.0 * animationValue)), // Starting to regain
                FlSpot(4, 3.5 + (0.5 * animationValue)), // More regain
                const FlSpot(5, 4.0), // Back to higher than starting weight
              ],
              isCurved: true,
              color: primaryPink,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: false,
              ),
            ),
            // PockEat line (goes down consistently)
            LineChartBarData(
              spots: [
                const FlSpot(0, 3.5), // Starting weight
                FlSpot(1, 3.0 - (0.3 * animationValue)), // Initial drop
                FlSpot(2, 2.7 - (0.5 * animationValue)), // Continued loss
                FlSpot(3, 2.2 - (0.5 * animationValue)), // Stable loss
                FlSpot(4, 1.7 - (0.2 * animationValue)), // Continued loss
                const FlSpot(5, 1.5), // Sustained loss
              ],
              isCurved: true,
              color: primaryGreen,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // Only show start and end dots
                  if (index == 0 || index == 5) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: primaryGreen,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: textDarkColor, size: 20),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                bgColor,
              ],
              stops: const [0.0, 0.6],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Onboarding progress indicator
                const OnboardingProgressIndicator(
                  totalSteps: 16,
                  currentStep: 0, // This is the first step (0-indexed)
                  barHeight: 6.0,
                  showPercentage: true,
                ),

                const SizedBox(height: 20),

                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Title - plain text without gradient
                      Text(
                        'PockEat Creates',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textDarkColor,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Long Term Results',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textDarkColor,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Weight section with animated container
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - _animation.value)),
                            child: Opacity(
                              opacity: _animation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Weight Transformation',
                                style: TextStyle(
                                  color: textDarkColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Chart
                              SizedBox(
                                height: 180,
                                child: AnimatedBuilder(
                                  animation: _animation,
                                  builder: (context, child) {
                                    return _buildWeightComparisonChart(
                                        _animation.value);
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Chart labels
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildChartLegendItem(
                                      'Traditional diet', primaryPink),
                                  const SizedBox(width: 24),
                                  _buildChartLegendItem(
                                      'With PockEat', primaryGreen),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Statistic with more creative wording
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - _animation.value)),
                            child: Opacity(
                              opacity: _animation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: primaryGreen.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '80%',
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'of PockEat users maintain their results, even 6 months later. Say goodbye to yo-yo dieting!',
                                  style: TextStyle(
                                    color: textDarkColor,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(
                  height: 12,
                ),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/height-weight');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
