// review_submit_page.dart
// coverage:ignore-file
// ignore_for_file: use_build_context_synchronously

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../widgets/user_information_card.dart';
import '../widgets/calorie_macronutrient_card.dart';
import '../widgets/personalized_message_widget.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'form_cubit.dart';

class ReviewSubmitPage extends StatefulWidget {
  const ReviewSubmitPage({super.key});

  @override
  State<ReviewSubmitPage> createState() => _ReviewSubmitPageState();
}

class _ReviewSubmitPageState extends State<ReviewSubmitPage> 
    with SingleTickerProviderStateMixin {
  // Colors from the app's design system
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Setup animation for content
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

  String formatActivityLevel(String? level) {
    if (level == null) return "-";
    return level
        .replaceAll("_", " ")
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : "")
        .join(' ');
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
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final inProgress = prefs.getBool('onboardingInProgress') ?? true;
            if (!context.mounted) return;

            if (inProgress && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          },
        ),
      ),
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
              child: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
                builder: (context, state) {
              final caloricService = getIt<CaloricRequirementService>();

              final List<String> goals = List<String>.from(state.selectedGoals);
              final hasOther = goals.contains("Other");
              final otherReason = state.otherGoalReason?.trim();

              if (hasOther) {
                goals.remove("Other");
                if (otherReason != null && otherReason.isNotEmpty) {
                  goals.add("Other: $otherReason");
                }
              }

              final goalsDisplay = goals.isEmpty ? "-" : goals.join(", ");

              // Build a temporary HealthMetricsModel to call analyze
              final healthMetrics = HealthMetricsModel(
                userId: "dummy-id",
                height: state.height ?? 0,
                weight: state.weight ?? 0,
                age: _calculateAge(state.birthDate),
                gender: state.gender ?? 'male',
                activityLevel: state.activityLevel ?? "moderate",
                fitnessGoal: goalsDisplay,
                bmi: state.bmi ?? 0,
                bmiCategory: state.bmiCategory ?? "-",
                desiredWeight: state.desiredWeight ?? 0,
              );

              final result = caloricService.analyze(
                userId: "dummy-id",
                model: healthMetrics,
              );

              final macros = {
                'Protein': result.proteinGrams,
                'Carbs': result.carbsGrams,
                'Fat': result.fatGrams,
              };

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Simplified header without line accent
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Health Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Almost there! Review your information below.",
                          style: TextStyle(
                            fontSize: 16,
                            color: textDarkColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Animated info card
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
                              child: UserInformationCard(
                                goalsDisplay: goalsDisplay,
                                state: state,
                                primaryGreen: primaryGreen,
                                textDarkColor: textDarkColor,
                                calculateAge: _calculateAge,
                                formatActivityLevel: formatActivityLevel,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Animated calorie card
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
                              child: CalorieMacronutrientCard(
                                tdee: result.tdee,
                                macros: macros,
                                primaryGreen: primaryGreen,
                                textDarkColor: textDarkColor,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Animated personal message
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
                              child: PersonalizedMessageWidget(
                                goals: goals,
                                primaryGreen: primaryGreen,
                                textDarkColor: textDarkColor,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Continue button with improved design
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: primaryGreen.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 58),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboardingInProgress', false);
                        final loginService = GetIt.instance<LoginService>();
                        final user = await loginService.getCurrentUser();
                        if (user != null) {
                          final formCubit = context.read<HealthMetricsFormCubit>();
                          formCubit.setUserId(user.uid);
                          await formCubit.submit();
                          Navigator.pushReplacementNamed(context, '/');
                        } else {
                          Navigator.pushNamed(context, '/register');
                        }
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
          ],
        ),
      ),
    );
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 25;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Membuat titik-titik dekoratif untuk background
  List<Widget> _buildDecorationDots() {
    final List<Widget> dots = [];
    
    // Posisi-posisi titik dekoratif
    final List<Map<String, dynamic>> fixedDots = [
      {'top': 50.0, 'left': 30.0, 'size': 8.0, 'color': primaryGreen, 'opacity': 0.2},
      {'top': 100.0, 'right': 40.0, 'size': 6.0, 'color': primaryGreen, 'opacity': 0.15},
      {'top': 160.0, 'left': 60.0, 'size': 10.0, 'color': primaryPink, 'opacity': 0.1},
      {'top': 220.0, 'right': 70.0, 'size': 14.0, 'color': primaryPink, 'opacity': 0.2},
      {'bottom': 180.0, 'left': 40.0, 'size': 12.0, 'color': primaryGreen, 'opacity': 0.15},
      {'bottom': 120.0, 'right': 60.0, 'size': 8.0, 'color': primaryGreen, 'opacity': 0.1},
      {'bottom': 70.0, 'right': 30.0, 'size': 6.0, 'color': primaryPink, 'opacity': 0.15},
    ];
    
    for (final dot in fixedDots) {
      dots.add(
        Positioned(
          top: dot['top'] as double?,
          left: dot['left'] as double?,
          right: dot['right'] as double?,
          bottom: dot['bottom'] as double?,
          child: Container(
            width: dot['size'] as double,
            height: dot['size'] as double,
            decoration: BoxDecoration(
              color: (dot['color'] as Color).withOpacity(dot['opacity'] as double),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    
    return dots;
  }
}
