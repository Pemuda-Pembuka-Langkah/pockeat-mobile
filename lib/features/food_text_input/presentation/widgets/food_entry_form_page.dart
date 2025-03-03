import 'package:flutter/material.dart';

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
    
    bool isValid = true;

    if (_foodNameController.text.trim().isEmpty) {
      setState(() => _foodNameError = 'Please insert food name');
      isValid = false;
    } else if (_foodNameController.text.split(' ').length > widget.maxFoodNameWords) {
      setState(() => _foodNameError = 'Food name exceeds maximum word count (${widget.maxFoodNameWords})');
      isValid = false;
    }
    
    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _descriptionError = 'Please insert food description');
      isValid = false;
    } else if (_descriptionController.text.split(' ').length > widget.maxDescriptionWords) {
      setState(() => _descriptionError = 'Description exceeds maximum word count (${widget.maxDescriptionWords})');
      isValid = false;
    }
    
    if (_ingredientsController.text.trim().isEmpty) {
      setState(() => _ingredientsError = 'Please insert food ingredients');
      isValid = false;
    } else if (_ingredientsController.text.split(' ').length > widget.maxIngredientWords) {
      setState(() => _ingredientsError = 'Ingredients exceeds maximum word count (${widget.maxIngredientWords})');
      isValid = false;
    }
    
    if (widget.weightRequired) {
      if (_weightController.text.trim().isEmpty) {
        setState(() => _weightError = 'Please enter a valid number');
        isValid = false;
      } else {
        final weight = int.tryParse(_weightController.text.trim());
        if (weight == null) {
          setState(() => _weightError = 'Please enter a valid number');
          isValid = false;
        } else if (weight < 0) {
          setState(() => _weightError = 'Weight cannot be negative');
          isValid = false;
        }
      }
    }
    
    if (isValid) {
      setState(() => _successMessage = 'Food entry is saved successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Entry Form')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: ValueKey('foodNameField'),
                controller: _foodNameController,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  errorText: _foodNameError,
                ),
              ),
              SizedBox(height: 10),
              
              TextField(
                key: ValueKey('descriptionField'),
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  errorText: _descriptionError,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              
              TextField(
                key: ValueKey('ingredientsField'),
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
                  key: ValueKey('weightField'),
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
                key: ValueKey('saveButton'),
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