class FormValidator {
  static String? validateFoodName(String value, int maxWords) {
    if (value.trim().isEmpty) {
      return 'Please insert food name';
    }
    
    int wordCount = value.split(' ').where((word) => word.trim().isNotEmpty).length;
    if (wordCount > maxWords) {
      return 'Food name exceeds maximum word count ($maxWords)';
    }
    
    return null;
  }
  
  static String? validateDescription(String value, int maxWords) {
    if (value.trim().isEmpty) {
      return 'Please insert food description';
    }
    
    int wordCount = value.split(' ').where((word) => word.trim().isNotEmpty).length;
    if (wordCount > maxWords) {
      return 'Description exceeds maximum word count ($maxWords)';
    }
    
    return null;
  }
  
  static String? validateIngredients(String value, int maxWords) {
    if (value.trim().isEmpty) {
      return 'Please insert food ingredients';
    }
    
    int wordCount = value.split(' ').where((word) => word.trim().isNotEmpty).length;
    if (wordCount > maxWords) {
      return 'Ingredients exceeds maximum word count ($maxWords)';
    }
    
    return null;
  }
  
  static String? validateWeight(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter a valid number';
    }
    
    double? weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }
    
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    
    return null;
  }
}