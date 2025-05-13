// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/feature_card.dart';

// Flutter imports only

import 'package:flutter/services.dart'; // Import untuk SystemNavigator

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  // Colors from the app's design system
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;

  final List<FeatureCard> _featureCards = [
    FeatureCard(
      icon: Icons.check_circle,
      iconColor: const Color(0xFF4ECDC4),
      title: "Track your meals effortlessly",
      subtitle: "With AI-powered meal analysis",
    ),
    FeatureCard(
      icon: Icons.pets,
      iconColor: const Color(0xFFFF6B6B),
      title: "Raise your virtual pet",
      subtitle: "Stay motivated with your cute companion",
    ),
    FeatureCard(
      icon: Icons.fitness_center,
      iconColor: const Color(0xFF9B6BFF),
      title: "Smart Exercise Log",
      subtitle: "Let AI analyze your workout",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start auto-scroll timer
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _featureCards.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          // Keluar dari aplikasi ketika tombol back ditekan
          SystemNavigator.pop();
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative background elements
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
              // Decorative small circles
              ..._buildDecorationDots(primaryGreen, primaryPink),
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),

                    // Panda and logo
                    Center(
                      child: SizedBox(
                        height: 200, // Reduced height
                        width: 200, // Reduced width
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // Logo Pockeat sebagai base yang besar
                            Positioned(
                              top: 30, // Adjusted position
                              right: -30,
                              child: Image.asset(
                                'assets/icons/Logo_PockEat_draft_transparent.png',
                                height: 160, // Reduced size
                                width: 160, // Reduced size
                              ),
                            ),
                            // Panda di atas logo dengan ukuran lebih kecil
                            Positioned(
                              bottom: 30, // Adjusted position
                              left: -15,
                              child: Image.asset(
                                'assets/images/panda_get_started.png',
                                height: 120, // Reduced size
                                width: 120, // Reduced size
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Main tagline
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: "Every Meal ",
                            style: TextStyle(color: primaryGreen),
                          ),
                          const TextSpan(
                            text: "Matters",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: "Every Move ",
                            style: TextStyle(color: primaryPink),
                          ),
                          const TextSpan(
                            text: "Counts",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Subtitle
                    const Text(
                      "AI-Driven Smart Companion for Seamless Calorie & Health Tracking",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100, // Reduced height from 120
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _featureCards.length,
                              onPageChanged: (int page) {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
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
                                        Icon(_featureCards[index].icon,
                                            color:
                                                _featureCards[index].iconColor,
                                            size:
                                                32), // Increased icon size from 24 to 32
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _featureCards[index].title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: textDarkColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Expanded(
                                                child: Text(
                                                  _featureCards[index].subtitle,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Page indicator dots
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _featureCards.length,
                              (index) => _buildDotIndicator(index),
                            ),
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: 20),

                    // Get Started Button
                    ElevatedButton(
                      onPressed: () => _navigateToOnboarding(context),
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
                        "Get Started",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login button
                    TextButton(
                      onPressed: () => _navigateToLogin(context),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        foregroundColor: textDarkColor,
                      ),
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "Log in",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToOnboarding(BuildContext context) {
    Navigator.pushNamed(context, '/onboarding');
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  // Build page indicator dot
  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? primaryGreen : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Generate decorative dots for background dengan posisi fixed
  List<Widget> _buildDecorationDots(Color color1, Color color2) {
    final List<Widget> dots = [];

    // Posisi dot yang sudah ditentukan
    final List<Map<String, dynamic>> fixedDots = [
      {'top': 50.0, 'left': 30.0, 'size': 8.0, 'color': color1, 'opacity': 0.2},
      {
        'top': 120.0,
        'left': 250.0,
        'size': 6.0,
        'color': color2,
        'opacity': 0.15
      },
      {
        'top': 200.0,
        'left': 80.0,
        'size': 10.0,
        'color': color1,
        'opacity': 0.1
      },
      {
        'top': 300.0,
        'left': 300.0,
        'size': 5.0,
        'color': color2,
        'opacity': 0.25
      },
      {
        'top': 400.0,
        'left': 150.0,
        'size': 7.0,
        'color': color1,
        'opacity': 0.2
      },
      {
        'top': 500.0,
        'left': 100.0,
        'size': 9.0,
        'color': color2,
        'opacity': 0.15
      },
      {
        'top': 180.0,
        'left': 200.0,
        'size': 6.0,
        'color': color1,
        'opacity': 0.2
      },
      {
        'top': 250.0,
        'left': 50.0,
        'size': 8.0,
        'color': color2,
        'opacity': 0.1
      },
      {
        'top': 350.0,
        'left': 220.0,
        'size': 5.0,
        'color': color1,
        'opacity': 0.25
      },
      {
        'top': 420.0,
        'left': 280.0,
        'size': 7.0,
        'color': color2,
        'opacity': 0.2
      },
      {
        'top': 150.0,
        'left': 320.0,
        'size': 9.0,
        'color': color1,
        'opacity': 0.15
      },
      {
        'top': 480.0,
        'left': 170.0,
        'size': 6.0,
        'color': color2,
        'opacity': 0.2
      },
    ];

    for (var dot in fixedDots) {
      dots.add(
        Positioned(
          top: dot['top'],
          left: dot['left'],
          child: Container(
            height: dot['size'],
            width: dot['size'],
            decoration: BoxDecoration(
              color: dot['color'].withOpacity(dot['opacity']),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return dots;
  }
}
