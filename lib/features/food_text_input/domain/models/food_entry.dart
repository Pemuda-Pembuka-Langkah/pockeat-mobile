class FoodEntry {
  final String foodDescription;

  FoodEntry({
    required this.foodDescription,
  });

  @override
  String toString() {
    return 'FoodEntry(description: $foodDescription)';
  }
}