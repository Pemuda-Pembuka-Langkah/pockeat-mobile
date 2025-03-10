import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';

void main() {
  test('FoodEntry model is created correctly', () {
    final foodEntry = FoodEntry(
      foodName: 'Nasi Goreng',
      description: 'Fried rice with vegetables',
      ingredients: 'Rice, eggs, soy sauce',
      weight: 300,
    );

    expect(foodEntry.foodName, 'Nasi Goreng');
    expect(foodEntry.description, 'Fried rice with vegetables');
    expect(foodEntry.ingredients, 'Rice, eggs, soy sauce');
    expect(foodEntry.weight, 300);
  });
}