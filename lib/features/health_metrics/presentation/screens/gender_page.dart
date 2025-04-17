// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

class GenderPage extends StatelessWidget {
  const GenderPage({super.key});

  static final List<String> genderOptions = [
    "Male",
    "Female",
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
          "Your Gender",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What is your gender?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
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
                        for (final option in genderOptions)
                          _buildGenderOption(
                            context,
                            option,
                            selected: state.gender == option,
                          ),
                      ],
                    ),
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
                  onPressed: state.gender != null
                      ? () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('onboardingInProgress', true);

                          Navigator.pushNamed(context, '/activity-level');
                        }
                      : null,
                  child: const Center(child: Text("Next")),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderOption(BuildContext context, String label,
      {required bool selected}) {
    final cubit = context.read<HealthMetricsFormCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: selected
            ? primaryPink.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => cubit.setGender(label),
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
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? primaryPink : Colors.black54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
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