import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/food_text_input/presentation/utils/food_entry_form_validator.dart';

class FoodEntryForm extends StatefulWidget {
  final int maxFoodNameWords;
  final int maxDescriptionWords;
  final int maxIngredientWords;
  final bool weightRequired;

  const FoodEntryForm({
    this.maxFoodNameWords = 20,
    this.maxDescriptionWords = 50,
    this.maxIngredientWords = 50,
    this.weightRequired = true,
    Key? key,
  }) : super(key: key);

  @override
  _FoodEntryFormState createState() => _FoodEntryFormState();
}

class _FoodEntryFormState extends State<FoodEntryForm> {
  final _foodNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _weightController = TextEditingController();

  String? _foodNameError;
  String? _descriptionError;
  String? _ingredientsError;
  String? _weightError;
  String? _successMessage;

  void _saveForm() {
    setState(() {
      _foodNameError = null;
      _descriptionError = null;
      _ingredientsError = null;
      _weightError = null;
      _successMessage = null;
    });

    bool isValid = true;
    _foodNameError = FormValidator.validateFoodName(_foodNameController.text, widget.maxFoodNameWords);
    if (_foodNameError != null) isValid = false;

    _descriptionError = FormValidator.validateDescription(_descriptionController.text, widget.maxDescriptionWords);
    if (_descriptionError != null) isValid = false;

    _ingredientsError = FormValidator.validateIngredients(_ingredientsController.text, widget.maxIngredientWords);
    if (_ingredientsError != null) isValid = false;

    if (widget.weightRequired) {
      _weightError = FormValidator.validateWeight(_weightController.text);
      if (_weightError != null) isValid = false;
    }

    if (isValid) {
      FoodEntry foodEntry = FoodEntry(
        foodName: _foodNameController.text,
        description: _descriptionController.text,
        ingredients: _ingredientsController.text,
        weight: widget.weightRequired ? int.tryParse(_weightController.text) : null,
      );

      setState(() {
        _successMessage = 'Food entry is saved successfully!';
      });

      print(foodEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Entry Form')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _foodNameController,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  errorText: _foodNameError,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  errorText: _descriptionError,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Ingredients',
                  errorText: _ingredientsError,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              if (widget.weightRequired)
                TextField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (grams)',
                    errorText: _weightError,
                  ),
                  keyboardType: TextInputType.number,
                ),
              SizedBox(height: 10),
              if (_successMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}