class FoodEntry {
  final String foodName;
  final String description;
  final String ingredients;
  final int? weight;

  FoodEntry({
    required this.foodName,
    required this.description,
    required this.ingredients,
    this.weight,
  });

  @override
  String toString() {
    return 'FoodEntry(foodName: $foodName, description: $description, ingredients: $ingredients, weight: $weight)';
  }
}