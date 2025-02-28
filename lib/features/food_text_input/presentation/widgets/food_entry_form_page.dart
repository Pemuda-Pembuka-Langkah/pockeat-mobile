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
  String? _errorMessage;

  void _saveForm() {
    setState(() {
      _errorMessage = null;
    });
    
    if (_foodNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please insert food name');
      return;
    }
    
    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please insert food description');
      return;
    }
    
    if (_ingredientsController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please insert food ingredients');
      return;
    }
    
    if (widget.weightRequired && _weightController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a valid number');
      return;
    }
    
    if (widget.weightRequired) {
      final weight = int.tryParse(_weightController.text.trim());
      if (weight == null) {
        setState(() => _errorMessage = 'Please enter a valid number');
        return;
      }
      if (weight < 0) {
        setState(() => _errorMessage = 'Weight cannot be negative');
        return;
      }
    }
    
    if (_foodNameController.text.split(' ').length > widget.maxFoodNameWords) {
      setState(() => _errorMessage = 'Food name exceeds maximum word count (${widget.maxFoodNameWords})');
      return;
    }
    
    if (_descriptionController.text.split(' ').length > widget.maxDescriptionWords) {
      setState(() => _errorMessage = 'Description exceeds maximum word count (${widget.maxDescriptionWords})');
      return;
    }
    
    if (_ingredientsController.text.split(' ').length > widget.maxIngredientWords) {
      setState(() => _errorMessage = 'Ingredients exceeds maximum word count (${widget.maxIngredientWords})');
      return;
    }
    
    setState(() => _errorMessage = 'Food entry is saved successfully!');
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
                decoration: InputDecoration(labelText: 'Food Name'),
              ),
              TextField(
                key: ValueKey('descriptionField'),
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                key: ValueKey('ingredientsField'),
                controller: _ingredientsController,
                decoration: InputDecoration(labelText: 'Ingredients'),
                maxLines: 3,
              ),
              TextField(
                key: ValueKey('weightField'),
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (grams)'),
                keyboardType: TextInputType.number,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: _errorMessage == 'Food entry is saved successfully!' ? Colors.green : Colors.red),
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