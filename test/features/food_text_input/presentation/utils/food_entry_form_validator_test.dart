import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/presentation/utils/food_entry_form_validator.dart';

void main() {
  group('FormValidator Tests', () {
    test('Validates food name correctly', () {
      expect(FormValidator.validateFoodName('', 20), 'Please insert food name');
      expect(FormValidator.validateFoodName('Nasi Goreng', 20), null);
      expect(FormValidator.validateFoodName('A very long food name that exceeds the limit', 5), 'Food name exceeds maximum word count (5)');
    });

    test('Validates description correctly', () {
      expect(FormValidator.validateDescription('', 50), 'Please insert food description');
      expect(FormValidator.validateDescription('Delicious food', 50), null);
      expect(FormValidator.validateDescription('A long description that exceeds the word limit', 3), 'Description exceeds maximum word count (3)');
    });

    test('Validates ingredients correctly', () {
      expect(FormValidator.validateIngredients('', 50), 'Please insert food ingredients');
      expect(FormValidator.validateIngredients('Rice, eggs, soy sauce', 50), null);
      expect(FormValidator.validateIngredients('A very long ingredients list that exceeds the word limit', 4), 'Ingredients exceeds maximum word count (4)');
    });

    test('Validates weight correctly', () {
      expect(FormValidator.validateWeight(''), 'Please enter a valid number');
      expect(FormValidator.validateWeight('abc'), 'Please enter a valid number');
      expect(FormValidator.validateWeight('-5'), 'Weight must be greater than 0');
      expect(FormValidator.validateWeight('100'), null);
    });
  });
}
