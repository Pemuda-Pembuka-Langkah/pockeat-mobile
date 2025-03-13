import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';

void main() {
  test('FoodEntry model is created correctly', () {
    final foodEntry = FoodEntry(
      foodDescription: 'Fried rice with vegetables',
    );

    expect(foodEntry.foodDescription, 'Fried rice with vegetables');
  });

  test('FoodEntry should not accept an empty foodDescription', () {
    final foodEntry = FoodEntry(foodDescription: '');
    
    expect(foodEntry.foodDescription.isEmpty, true);
  });
}
