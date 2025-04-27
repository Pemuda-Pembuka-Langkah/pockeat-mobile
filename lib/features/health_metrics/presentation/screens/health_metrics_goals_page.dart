// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'form_cubit.dart';

class HealthMetricsGoalsPage extends StatefulWidget {
  const HealthMetricsGoalsPage({super.key});

  static final List<String> options = [
    "Eat and live healthier",
    "Boost my energy and mood",
    "Stay motivated and consistent",
    "Feel better about my body",
    "I'm still exploring",
    "Other",
  ];

  @override
  State<HealthMetricsGoalsPage> createState() => _HealthMetricsGoalsPageState();
}

class _HealthMetricsGoalsPageState extends State<HealthMetricsGoalsPage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        title: const Text(
          "Your Goals",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
        builder: (context, state) {
          final isOtherSelected = state.selectedGoals.contains("Other");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What would you like to accomplish?",
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final option in HealthMetricsGoalsPage.options)
                            _buildOption(
                              context,
                              option,
                              selected: state.selectedGoals.contains(option),
                              disabled: isOtherSelected && option != "Other" ||
                                  (!isOtherSelected &&
                                      option == "Other" &&
                                      state.selectedGoals.isNotEmpty),
                            ),
                          if (isOtherSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Please specify',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) => context
                                    .read<HealthMetricsFormCubit>()
                                    .setOtherGoalReason(value),
                              ),
                            ),
                        ],
                      ),
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
                  onPressed: state.selectedGoals.isNotEmpty &&
                          (!isOtherSelected ||
                              (state.otherGoalReason?.isNotEmpty ?? false))
                      ? () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool(
                              'onboardingInProgress', true); // ✅ set flag
                          if (!context.mounted) return;
                          Navigator.pushNamed(context, '/height-weight');
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

  Widget _buildOption(
    BuildContext context,
    String label, {
    required bool selected,
    required bool disabled,
  }) {
    final cubit = context.read<HealthMetricsFormCubit>();
    const Color primaryPink = Color(0xFFFF6B6B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: selected
            ? primaryPink.withOpacity(0.1)
            : disabled
                ? Colors.grey.shade100
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: disabled ? null : () => cubit.toggleGoal(label),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected
                    ? primaryPink
                    : disabled
                        ? Colors.grey.shade300
                        : Colors.grey.shade400,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected
                      ? primaryPink
                      : disabled
                          ? Colors.grey
                          : Colors.black54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: disabled ? Colors.grey : Colors.black87,
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
