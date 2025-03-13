import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/presentation/utils/food_entry_form_validator.dart';

void main() {
  group('FormValidator Tests', () {
    test('Validates description correctly', () {
      expect(FormValidator.validateDescription('', 50), 'Please insert food description');
      expect(FormValidator.validateDescription('Delicious food', 50), null);
      expect(FormValidator.validateDescription('A long description that exceeds the word limit', 3), 'Description exceeds maximum word count (3)');
    });
  });
}
