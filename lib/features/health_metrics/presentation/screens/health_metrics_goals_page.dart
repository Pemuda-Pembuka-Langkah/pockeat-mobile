import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("What would you like to accomplish?")),
      body: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
        builder: (context, state) {
          final isOtherSelected = state.selectedGoals.contains("Other");

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16), // spacing below button
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    Scaffold.of(context).appBarMaxHeight!,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    for (final option in HealthMetricsGoalsPage.options)
                      _buildOption(
                        context,
                        option,
                        selected: state.selectedGoals.contains(option),
                        disabled: isOtherSelected && option != "Other" ||
                            !isOtherSelected && option == "Other" && state.selectedGoals.isNotEmpty,
                      ),
                    if (isOtherSelected)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Please specify',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => context.read<HealthMetricsFormCubit>().setOtherGoalReason(value),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: state.selectedGoals.isNotEmpty &&
                                (!isOtherSelected || (state.otherGoalReason?.isNotEmpty ?? false))
                            ? () => Navigator.pushNamed(context, '/height-weight')
                            : null,
                        child: const Text("Next"),
                      ),
                    ),
                  ],
                ),
              ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: selected
            ? Colors.blue[50]
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
                    ? Colors.blue
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
                      ? Colors.blue
                      : disabled
                          ? Colors.grey
                          : Colors.black54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
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