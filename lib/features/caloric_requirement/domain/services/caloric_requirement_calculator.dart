// lib/features/health_metrics/caloric_requirement/domain/services/caloric_requirement_calculator.dart

class CaloricRequirementCalculator {
  /// Calculates BMR using Mifflin-St Jeor formula
  static double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required String gender,
  }) {
    if (gender.toLowerCase() == "male") {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  /// Returns the activity multiplier based on level
  static double activityMultiplier(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case "sedentary":
        return 1.2;
      case "light":
        return 1.375; // 1–3x/week
      case "moderate":
        return 1.55; // 4–5x/week
      case "active":
        return 1.725; // daily or 3–4 intense
      case "very active":
        return 1.9; // 6–7 intense
      case "extra active":
        return 2.0; // daily intense or physical job
      default:
        return 1.2; // fallback
    }
  }


  /// Calculates Total Daily Energy Expenditure (TDEE)
  static double calculateTDEE(double bmr, String activityLevel) {
    return bmr * activityMultiplier(activityLevel);
  }
}