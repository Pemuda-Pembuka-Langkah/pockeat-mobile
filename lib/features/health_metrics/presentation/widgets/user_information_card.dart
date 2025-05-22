// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';

class UserInformationCard extends StatelessWidget {
  final String goalsDisplay;
  final HealthMetricsFormState state;
  final Color primaryGreen;
  final Color textDarkColor;
  final Function(DateTime?) calculateAge;
  final Function(String?) formatActivityLevel;

  const UserInformationCard({
    super.key,
    required this.goalsDisplay,
    required this.state,
    required this.primaryGreen,
    required this.textDarkColor,
    required this.calculateAge,
    required this.formatActivityLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assignment, color: primaryGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                "Your Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Goals section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.stars, size: 20, color: primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Goals",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goalsDisplay,
                      style: TextStyle(
                        fontSize: 15,
                        color: textDarkColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body measurements
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.straighten, size: 20, color: primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Body Measurements",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Height: ${state.height != null ? "${state.height} cm" : "-"}",
                            style: TextStyle(
                              fontSize: 15,
                              color: textDarkColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Weight: ${state.weight != null ? "${state.weight} kg" : "-"}",
                            style: TextStyle(
                              fontSize: 15,
                              color: textDarkColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Gender: ${state.gender ?? "-"}",
                            style: TextStyle(
                              fontSize: 15,
                              color: textDarkColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Age: ${calculateAge(state.birthDate)}",
                            style: TextStyle(
                              fontSize: 15,
                              color: textDarkColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Activity & Diet
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.directions_run, size: 20, color: primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Activity & Diet",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Activity Level: ${formatActivityLevel(state.activityLevel)}",
                      style: TextStyle(
                        fontSize: 15,
                        color: textDarkColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Diet Type: ${state.dietType ?? "-"}",
                      style: TextStyle(
                        fontSize: 15,
                        color: textDarkColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target goals
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.track_changes, size: 20, color: primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Target Goals",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Desired Weight: ${state.desiredWeight != null ? "${state.desiredWeight} kg" : "-"}",
                      style: TextStyle(
                        fontSize: 15,
                        color: textDarkColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Weekly Goal: ${state.weeklyGoal != null ? "${state.weeklyGoal!.toStringAsFixed(1)} kg/week" : "-"}",
                      style: TextStyle(
                        fontSize: 15,
                        color: textDarkColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
