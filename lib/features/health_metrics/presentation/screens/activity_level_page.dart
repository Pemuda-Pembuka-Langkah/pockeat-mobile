import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

class ActivityLevelPage extends StatelessWidget {
  const ActivityLevelPage({super.key});

  static final List<Map<String, String>> activityLevels = [
    {
      "value": "sedentary",
      "label": "Sedentary",
      "description": "Little or no exercise"
    },
    {
      "value": "light",
      "label": "Light",
      "description": "Exercise 1–3 times/week"
    },
    {
      "value": "moderate",
      "label": "Moderate",
      "description": "Exercise 4–5 times/week"
    },
    {
      "value": "active",
      "label": "Active",
      "description": "Daily exercise or intense exercise 3–4 times/week"
    },
    {
      "value": "very active",
      "label": "Very Active",
      "description": "Intense exercise 6–7 times/week"
    },
    {
      "value": "extra active",
      "label": "Extra Active",
      "description": "Very intense daily exercise or physical job"
    },
  ];

  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);

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

            if (inProgress && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); 
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst); 
            }
          },
        ),
        title: const Text(
          "Activity Level",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What best describes your weekly activity level?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPink.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final level in activityLevels)
                          _buildActivityOption(
                            context,
                            level["value"]!,
                            level["label"]!,
                            level["description"]!,
                            selected: state.activityLevel == level["value"],
                          ),
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
                    onPressed: state.activityLevel != null
                        ? () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('onboardingInProgress', true);
                            Navigator.pushNamed(context, '/diet');
                          }
                        : null,
                    child: const Center(child: Text("Next")),
                  ),
                ],
              ),
            ),
          );

        },
      ),
    );
  }

  Widget _buildActivityOption(
    BuildContext context,
    String value,
    String label,
    String description, {
    required bool selected,
  }) {
    final cubit = context.read<HealthMetricsFormCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: selected ? primaryPink.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => cubit.setActivityLevel(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? primaryPink : Colors.grey.shade400,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? primaryPink : Colors.black54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}