class FormValidator {
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
  
  }