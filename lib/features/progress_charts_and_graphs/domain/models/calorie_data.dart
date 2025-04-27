class CalorieData {
  final String day;
  final double protein;
  final double carbs;
  final double fats;
  final double calories; // Tambahkan field calories

  CalorieData(this.day, this.protein, this.carbs, this.fats, [this.calories = 0]);
}