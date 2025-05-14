// ignore_for_file: use_build_context_synchronously

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'form_cubit.dart';
import '../widgets/onboarding_progress_indicator.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> with SingleTickerProviderStateMixin {
  // Adding a ScrollController to fix the error
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _options = [
    {
      'title': 'No specific diet',
      'description': 'You eat a general diet without any specific restrictions.',
      'icon': Icons.restaurant,
    },
    {
      'title': 'Vegetarian',
      'description': 'No meat or fish, but may include dairy and eggs.',
      'icon': Icons.eco,
    },
    {
      'title': 'Vegan',
      'description': 'No animal products, including dairy, eggs, and honey.',
      'icon': Icons.spa,
    },
    {
      'title': 'Keto',
      'description': 'Low-carb, high-fat diet focused on ketosis.',
      'icon': Icons.food_bank,
    },
    {
      'title': 'Paleo',
      'description': 'Whole foods, lean meats, vegetables, no processed items.',
      'icon': Icons.grass,
    },
    {
      'title': 'Low-carb',
      'description': 'Reduces carbohydrate intake, often for weight loss.',
      'icon': Icons.no_food,
    },
    {
      'title': 'Other',
      'description': 'A different diet not listed above.',
      'icon': Icons.more_horiz,
    },
  ];

  String? _selected;

  // Colors from the app's design system
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);
  
  // Animation controllers
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
    _scrollController.dispose(); // Dispose the ScrollController when the widget is disposed
    super.dispose();
  }

  Widget _buildDietOption(Map<String, dynamic> option) {
    final bool isSelected = _selected == option['title'];
    
    return InkWell(
      onTap: () {
        setState(() => _selected = option['title']);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? primaryGreen.withOpacity(0.1) 
                  : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected 
                    ? primaryGreen.withOpacity(0.1) 
                    : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                option['icon'],
                color: isSelected ? primaryGreen : Colors.grey.shade400,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option['description'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? primaryGreen : Colors.grey.shade300,
              size: 22,
            ),
          ],
        ),
      ),
    );
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
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final inProgress = prefs.getBool('onboardingInProgress') ?? true;

            if (inProgress && Navigator.of(context).canPop()) {
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
                  currentStep: 6, // This is the seventh step (0-indexed)
                  barHeight: 6.0,
                  showPercentage: true,
                ),

                const SizedBox(height: 20),

                // Title with modern style
                const Text(
                  "Diet Preference",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Do you follow a specific diet?",
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
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                thickness: 4,
                                radius: const Radius.circular(8),
                                child: ListView(
                                  controller: _scrollController,
                                  children: _options.map((option) => _buildDietOption(option)).toList(),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Continue button at the bottom of the container
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _selected == null
                                    ? null
                                    : () {
                                        context
                                            .read<HealthMetricsFormCubit>()
                                            .setDietType(_selected!);
                                        Navigator.pushNamed(context, '/onboarding/goal');
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selected != null
                                      ? primaryGreen
                                      : primaryGreenDisabled,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: _selected != null ? 2 : 0,
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
}
