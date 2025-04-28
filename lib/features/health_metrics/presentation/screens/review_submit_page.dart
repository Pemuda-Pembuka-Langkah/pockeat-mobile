// review_submit_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'form_cubit.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

class ReviewSubmitPage extends StatelessWidget {
  const ReviewSubmitPage({super.key});

  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);

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
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
        title: const Text(
          "Review & Submit",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
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
          );

          final result = caloricService.analyze(
            userId: "dummy-id",
            model: healthMetrics,
          );

          final macros = _calculateMacros(result.tdee);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Review your info",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildInfoCard(goalsDisplay, state, context),
                      const SizedBox(height: 24),
                      _buildCalorieMacronutrientCard(result.tdee, macros),
                      const SizedBox(height: 24),
                      _buildPersonalizedMessage(goals),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboardingInProgress', false);

  if (!context.mounted) return;
  
  Navigator.pushNamed(context, '/register');
},

                  child: const Center(child: Text("Continue to Create Account")),
                ),
              ],
            ),
          );
        },
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

  Widget _buildInfoCard(String goalsDisplay, HealthMetricsFormState state, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem("Goals", goalsDisplay),
          _buildItem("Height", state.height != null ? "${state.height} cm" : "-"),
          _buildItem("Weight", state.weight != null ? "${state.weight} kg" : "-"),
          _buildItem("Birth Date", state.birthDate?.toLocal().toString().split(" ")[0] ?? "-"),
          _buildItem("Gender", state.gender ?? "-"),
          _buildItem("Activity Level", formatActivityLevel(state.activityLevel)),
          _buildItem("Diet Type", state.dietType ?? "-"),
          _buildItem("Desired Weight", state.desiredWeight != null ? "${state.desiredWeight} kg" : "-"),
          _buildItem("Weekly Goal", state.weeklyGoal != null ? "${state.weeklyGoal!.toStringAsFixed(1)} kg/week" : "-"),
        ],
      ),
    );
  }

  Widget _buildCalorieMacronutrientCard(double tdee, Map<String, double> macros) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Calorie Target: ${tdee.toStringAsFixed(0)} kcal",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Macronutrient Breakdown:",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildMacroBar(macros),
        ],
      ),
    );
  }

  Widget _buildMacroBar(Map<String, double> macros) {
    return Column(
      children: macros.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text("${e.key}:"),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: e.value,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  color: e.key == 'Protein'
                      ? Colors.blue
                      : e.key == 'Carbs'
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Text("${(e.value * 100).toStringAsFixed(0)}%"),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalizedMessage(List<String> goals) {
    String message;
    if (goals.any((goal) => goal.toLowerCase().contains('lose'))) {
      message = "You're on your way to a healthier, lighter you! 💪";
    } else if (goals.any((goal) => goal.toLowerCase().contains('gain'))) {
      message = "Get ready to build strength and energy! 🚀";
    } else {
      message = "Let's maintain your awesome progress! 🎯";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
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
          color: primaryPink.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateMacros(double tdee) {
    const proteinPercent = 0.3;
    const carbsPercent = 0.4;
    const fatPercent = 0.3;
    return {
      'Protein': proteinPercent,
      'Carbs': carbsPercent,
      'Fat': fatPercent,
    };
  }
}