// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';

class HeardAboutPage extends StatefulWidget {
  const HeardAboutPage({super.key});

  static const List<String> options = [
    'Friend / Family',
    'Social Media (Instagram, TikTok, etc)',
    'Google Search',
    'Ad / Promotion',
    'Other',
  ];

  @override
  State<HeardAboutPage> createState() => _HeardAboutPageState();
}

class _HeardAboutPageState extends State<HeardAboutPage> with SingleTickerProviderStateMixin {
  // Colors from the app's design system
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;
  final Color textLightColor = Colors.black54;

  String? _selectedOption;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: textDarkColor, size: 20),
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ),
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
                  currentStep: 13, // This is the 14th step (0-indexed)
                  barHeight: 6.0,
                  showPercentage: true,
                ),
                
                const SizedBox(height: 20),
                
                // Title with modern style
                const Text(
                  "How You Found Us",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Where did you hear about PockEat?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Main content in a white container with shadow
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_fadeAnimation),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    for (final option in HeardAboutPage.options)
                                      _buildOption(
                                        option,
                                        selected: _selectedOption == option,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Continue button at the bottom of the container
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _selectedOption != null
                                    ? () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setString('heardAboutPockEat', _selectedOption!);
                                        if (context.mounted) {
                                          Navigator.pushNamed(context, '/sync-fitness-tracker');
                                        }
                                      }
                                    : null, // Disabled if no selection
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedOption != null
                                      ? primaryGreen
                                      : primaryGreenDisabled,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: _selectedOption != null ? 2 : 0,
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
                          ],
                        ),
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

  /// Builds a single tappable option.
  Widget _buildOption(
    String option, {
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedOption = option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? primaryGreen : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected 
                    ? primaryGreen.withOpacity(0.1) 
                    : Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? primaryGreen : Colors.grey.shade300,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
