class MacronutrientCalculator {
  /// Calculates daily macronutrient needs (in grams) based on TDEE and standard macro ratio.
  static Map<String, double> calculateGramsFromTDEE(double tdee) {
    const double proteinRatio = 0.3;
    const double carbsRatio = 0.4;
    const double fatRatio = 0.3;

    final double proteinGrams = (tdee * proteinRatio) / 4;
    final double carbsGrams = (tdee * carbsRatio) / 4;
    final double fatGrams = (tdee * fatRatio) / 9;

    return {
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
    };
  }
}