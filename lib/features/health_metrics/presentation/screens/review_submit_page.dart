import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

class ReviewSubmitPage extends StatelessWidget {
  const ReviewSubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review & Submit")),
      body: BlocBuilder<HealthMetricsFormCubit, HealthMetricsFormState>(
        builder: (context, state) {
          final List<String> goals = List.from(state.selectedGoals);
          final hasOther = goals.contains("Other");
          final otherReason = state.otherGoalReason?.trim();

          if (hasOther) {
            goals.remove("Other");
            if (otherReason != null && otherReason.isNotEmpty) {
              goals.add("Other: $otherReason");
            }
          }

          final goalsDisplay = goals.isEmpty ? "-" : goals.join(", ");

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItem("Goals", goalsDisplay),
                _buildItem("Height", state.height != null ? "${state.height} cm" : "-"),
                _buildItem("Weight", state.weight != null ? "${state.weight} kg" : "-"),
                _buildItem("Birth Date", state.birthDate?.toLocal().toString().split(" ")[0] ?? "-"),
                _buildItem("Diet Type", state.dietType ?? "-"),
                _buildItem("Desired Weight", state.desiredWeight != null ? "${state.desiredWeight} kg" : "-"),
                _buildItem("Weekly Goal", state.weeklyGoal != null ? "${state.weeklyGoal} kg/week" : "-"),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<HealthMetricsFormCubit>().submit();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Submitted successfully!")),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}