// calorie_calculation_loading_page.dart
// coverage:ignore-file

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../widgets/circular_loading_indicator.dart';
import '../widgets/decorative_dot.dart';
import '../widgets/feature_loading_item.dart';

class CalorieCalculationLoadingPage extends StatefulWidget {
  const CalorieCalculationLoadingPage({super.key});

  @override
  State<CalorieCalculationLoadingPage> createState() =>
      _CalorieCalculationLoadingPageState();
}

class _CalorieCalculationLoadingPageState
    extends State<CalorieCalculationLoadingPage>
    with SingleTickerProviderStateMixin {
  // Colors from the app's design system (matching review_submit_page)
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;

  late AnimationController _animationController;
  late Animation<double> _loadingAnimation;

  // Current loading percentage
  double _loadingPercentage = 0;

  // Features being loaded - with improved wording
  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Personalized Profile',
      'icon': Icons.person,
    },
    {
      'title': 'Daily Calorie Target',
      'icon': Icons.local_fire_department,
    },
    {
      'title': 'Macronutrient Breakdown',
      'icon': Icons.pie_chart,
    },
    {
      'title': 'Calorie Preference',
      'icon': Icons.food_bank,
    },
    {
      'title': 'Pet Companion',
      'icon': Icons.pets,
    },
  ];

  // To track which features have been "loaded"
  final List<bool> _featureLoaded = [false, false, false, false, false];

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds:
              6000), // Total loading time - increased to give users time to read
    );

    // Animation for the loading progress
    _loadingAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {
          _loadingPercentage = _loadingAnimation.value;

          // Update which features are "completed" based on loading percentage
          if (_loadingPercentage > 20) _featureLoaded[0] = true;
          if (_loadingPercentage > 40) _featureLoaded[1] = true;
          if (_loadingPercentage > 60) _featureLoaded[2] = true;
          if (_loadingPercentage > 80) _featureLoaded[3] = true;
          if (_loadingPercentage > 95) _featureLoaded[4] = true;
        });
      });

    // Start the animation
    _animationController.forward();

    // Set a timer to navigate to the next screen after loading is complete
    Future.delayed(const Duration(milliseconds: 7000), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/review');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative elements - background circles
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Small decorative dots
            ..._buildDecorationDots(),

            // Main content with gradient
            Container(
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),

                      // Loading circular progress and message - removed fade-in
                      Column(
                        children: [
                          // Circular progress indicator with percentage inside
                          CircularLoadingIndicator(
                            percentage: _loadingPercentage,
                            progressColor: primaryGreen,
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(height: 24),

                          // Message below percentage
                          Text(
                            "We're setting\neverything up for you",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.4,
                              color: textDarkColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Features being processed - removed fade transition
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: _boxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryGreen.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.assignment,
                                      color: primaryGreen, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Finalizing Your Results",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textDarkColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // List of features with checkmarks - matching review page style
                            ..._features.asMap().entries.map((entry) {
                              final index = entry.key;
                              final feature = entry.value;
                              return FeatureLoadingItem(
                                title: feature['title'],
                                icon: feature['icon'],
                                isLoaded: _featureLoaded[index],
                                primaryColor: primaryGreen,
                                textDarkColor: textDarkColor,
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: Colors.grey.shade100,
        width: 1.0,
      ),
    );
  }

  // Create decorative dots for the background
  List<Widget> _buildDecorationDots() {
    final List<Widget> dots = [];

    // Decorative dot positions
    final List<Map<String, dynamic>> fixedDots = [
      {
        'top': 50.0,
        'left': 30.0,
        'size': 8.0,
        'color': primaryGreen,
        'opacity': 0.2
      },
      {
        'top': 100.0,
        'right': 40.0,
        'size': 6.0,
        'color': primaryGreen,
        'opacity': 0.15
      },
      {
        'top': 160.0,
        'left': 60.0,
        'size': 10.0,
        'color': primaryPink,
        'opacity': 0.1
      },
      {
        'top': 220.0,
        'right': 70.0,
        'size': 14.0,
        'color': primaryPink,
        'opacity': 0.2
      },
      {
        'bottom': 180.0,
        'left': 40.0,
        'size': 12.0,
        'color': primaryGreen,
        'opacity': 0.15
      },
      {
        'bottom': 120.0,
        'right': 60.0,
        'size': 8.0,
        'color': primaryGreen,
        'opacity': 0.1
      },
      {
        'bottom': 70.0,
        'right': 30.0,
        'size': 6.0,
        'color': primaryPink,
        'opacity': 0.15
      },
    ];

    for (final dot in fixedDots) {
      dots.add(
        DecorativeDot(
          top: dot['top'] as double?,
          left: dot['left'] as double?,
          right: dot['right'] as double?,
          bottom: dot['bottom'] as double?,
          size: dot['size'] as double,
          color: dot['color'] as Color,
          opacity: dot['opacity'] as double,
        ),
      );
    }

    return dots;
  }
}
