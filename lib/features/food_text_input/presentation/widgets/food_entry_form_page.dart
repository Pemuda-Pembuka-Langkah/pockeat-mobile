import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/food_text_input/presentation/utils/food_entry_form_validator.dart';

class FoodEntryForm extends StatefulWidget {
  final int maxFoodNameWords;
  final int maxDescriptionWords;
  final int maxIngredientWords;
  final bool weightRequired;
  final Function(FoodEntry)? onSaved;

  const FoodEntryForm({
    this.maxFoodNameWords = 20,
    this.maxDescriptionWords = 50,
    this.maxIngredientWords = 50,
    this.weightRequired = true,
    this.onSaved,
    super.key,
  });

  @override
  _FoodEntryFormState createState() => _FoodEntryFormState();
}

class _FoodEntryFormState extends State<FoodEntryForm> {
  final _formKey = GlobalKey<FormState>();
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

    _foodNameError = FormValidator.validateFoodName(_foodNameController.text, widget.maxFoodNameWords);
    _descriptionError = FormValidator.validateDescription(_descriptionController.text, widget.maxDescriptionWords);
    _ingredientsError = FormValidator.validateIngredients(_ingredientsController.text, widget.maxIngredientWords);
    
    if (widget.weightRequired) {
      _weightError = FormValidator.validateWeight(_weightController.text);
    }

    setState(() {});

    bool isValid = _foodNameError == null &&
        _descriptionError == null &&
        _ingredientsError == null &&
        (!widget.weightRequired || _weightError == null);

    if (isValid) {
      final weight = widget.weightRequired && _weightController.text.trim().isNotEmpty
          ? double.tryParse(_weightController.text)?.toInt()
          : null;

      FoodEntry foodEntry = FoodEntry(
        foodName: _foodNameController.text,
        description: _descriptionController.text,
        ingredients: _ingredientsController.text,
        weight: weight,
      );

      if (widget.onSaved != null) {
        widget.onSaved!(foodEntry);
      }

      setState(() {
        _successMessage = 'Food entry is saved successfully!';
      });
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? errorText,
    int maxLines = 1,
    TextInputType? keyboardType,
    Key? key,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        key: key,
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.black54),
          errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Entry Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                key: const ValueKey('foodNameField'),
                controller: _foodNameController,
                label: 'Food Name',
                errorText: _foodNameError,
              ),
              _buildTextField(
                key: const ValueKey('descriptionField'),
                controller: _descriptionController,
                label: 'Description',
                errorText: _descriptionError,
                maxLines: 3,
              ),
              _buildTextField(
                key: const ValueKey('ingredientsField'),
                controller: _ingredientsController,
                label: 'Ingredients',
                errorText: _ingredientsError,
                maxLines: 3,
              ),
              _buildTextField(
                key: const ValueKey('weightField'),
                controller: _weightController,
                label: 'Weight (grams)',
                errorText: _weightError,
                keyboardType: TextInputType.number,
              ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  key: const ValueKey('saveButton'),
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}