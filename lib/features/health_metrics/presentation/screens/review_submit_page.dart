import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

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
          onPressed: () => Navigator.pop(context),
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
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                    child: ListView(
                      children: [
                        _buildItem("Goals", goalsDisplay),
                        _buildItem("Height", state.height != null ? "${state.height} cm" : "-"),
                        _buildItem("Weight", state.weight != null ? "${state.weight} kg" : "-"),
                        _buildItem("Birth Date", state.birthDate?.toLocal().toString().split(" ")[0] ?? "-"),
                        _buildItem("Gender", state.gender ?? "-"),
                        _buildItem("Activity Level", formatActivityLevel(state.activityLevel)),
                        _buildItem("Diet Type", state.dietType ?? "-"),
                        _buildItem("Desired Weight", state.desiredWeight != null ? "${state.desiredWeight} kg" : "-"),
                        _buildItem("Weekly Goal", state.weeklyGoal != null ? "${state.weeklyGoal} kg/week" : "-"),
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
                  onPressed: () async {
                    try {
                      await context.read<HealthMetricsFormCubit>().submit();

                      // ✅ SET SharedPreferences flags
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboardingInProgress', false);
                      await prefs.setBool('hasCompletedOnboarding', true);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green.shade600,
                            content: const Text("Submitted successfully!"),
                          ),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: primaryPink,
                            content: Text("Error: ${e.toString()}"),
                          ),
                        );
                      }
                    }
                  },

                  child: const Center(child: Text("Submit")),
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
}