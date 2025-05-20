// coverage:ignore-file

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

class PetOnboardPage extends StatefulWidget {
  const PetOnboardPage({super.key});

  @override
  State<PetOnboardPage> createState() => _PetOnboardPageState();
}

class _PetOnboardPageState extends State<PetOnboardPage>
    with SingleTickerProviderStateMixin {
  // Colors from the app's design system
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;
  final Color textLightColor = Colors.black54;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Text controller for pet name input
  final TextEditingController _petNameController = TextEditingController();
  final FocusNode _petNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
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
    _petNameController.dispose();
    _petNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // Enable resize to avoid bottom inset issues with keyboard
      resizeToAvoidBottomInset: true,
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
          child: Column(
            children: [
              // Fixed header with progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Onboarding progress indicator
                    const OnboardingProgressIndicator(
                      totalSteps: 16,
                      currentStep: 15, // This is the 16th step (0-indexed)
                      barHeight: 6.0,
                      showPercentage: true,
                    ),
                  ],
                ),
              ),
              
              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Title with modern style
                        const Text(
                          "Meet Your Pet Companion",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
            
                        const SizedBox(height: 8),
            
                        const Text(
                          "Your friendly panda companion will help motivate you throughout your health journey",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
            
                        const SizedBox(height: 24),
            
                        // Main content in a white container with shadow
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              margin: EdgeInsets.only(
                                bottom: 24,
                              ),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Panda animation with adaptive height
                                  SizedBox(
                                    height: 290,
                                    width: double.infinity,
                                    child: Lottie.asset(
                                      'assets/animations/Panda Happy Jump.json',
                                      repeat: true,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Description text
                                  Text(
                                    "Give your pet companion a name!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: textDarkColor,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Pet name input field with animated border
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryGreen.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _petNameController,
                                      focusNode: _petNameFocus,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        hintText: "Enter pet name",
                                        hintStyle: TextStyle(
                                          color: textLightColor,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: primaryGreen.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: primaryGreen,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.pets,
                                          color: primaryGreen,
                                          size: 22,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: textDarkColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      onChanged: (value) {
                                        // Trigger rebuild to update Continue button state
                                        setState(() {});
                                      },
                                      // Improve keyboard handling
                                      textInputAction: TextInputAction.done,
                                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // Continue button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _petNameController.text.trim().isNotEmpty
                                          ? () async {
                                              // Get UserPreferencesService from GetIt
                                              final preferencesService = GetIt.I<UserPreferencesService>();
                                              
                                              // Save pet name using service
                                              await preferencesService.setPetName(_petNameController.text.trim());
                                              
                                              if (context.mounted) {
                                                Navigator.pushNamed(context, '/calorie-loading');
                                              }
                                            }
                                          : null, // Disabled if no pet name
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _petNameController.text.trim().isNotEmpty
                                            ? primaryGreen
                                            : primaryGreenDisabled,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 56),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 16),
                                        elevation: _petNameController.text.trim().isNotEmpty ? 4 : 0,
                                        shadowColor: primaryGreen.withOpacity(0.5),
                                      ),
                                      child: const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 18,
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}