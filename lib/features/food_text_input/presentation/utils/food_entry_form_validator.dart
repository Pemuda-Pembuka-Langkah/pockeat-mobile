class FormValidator {
  static String? validateFoodName(String foodName, int maxWords) {
    if (foodName.isEmpty) return 'Please insert food name';
    if (foodName.split(' ').length > maxWords) { return 'Food name exceeds maximum word count ($maxWords)'; }
  }

  static String? validateDescription(String description, int maxWords) {
    if (description.isEmpty) return 'Please insert food description';
    if (description.split(' ').length > maxWords) {
      return 'Description exceeds maximum word count ($maxWords)';
    }
  }

  static String? validateIngredients(String ingredients, int maxWords) {
    if (ingredients.isEmpty) return 'Please insert food ingredients';
    if (ingredients.split(' ').length > maxWords) { return 'Ingredients exceeds maximum word count ($maxWords)'; }
  }

  static String? validateWeight(String weight) {
    if (weight.isEmpty) return 'Please enter a valid number';
    final weightValue = int.tryParse(weight);
    if (weightValue == null) return 'Please enter a valid number';
    if (weightValue < 0) return 'Weight cannot be negative';
    return null;
  }
}