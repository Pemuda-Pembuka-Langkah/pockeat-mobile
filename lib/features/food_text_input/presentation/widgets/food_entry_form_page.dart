import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/food_text_input/presentation/utils/food_entry_form_validator.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

class FoodEntryForm extends StatefulWidget {
  final Function(FoodEntry)? onSaved;
  final bool weightRequired;
  final int maxFoodNameWords;
  final int maxDescriptionWords;
  final int maxIngredientWords;

  const FoodEntryForm({
    Key? key,
    this.onSaved,
    this.weightRequired = true,
    this.maxFoodNameWords = 20,
    this.maxDescriptionWords = 50,
    this.maxIngredientWords = 50,
  }) : super(key: key);

  @override
  _FoodEntryFormState createState() => _FoodEntryFormState();
}

class _FoodEntryFormState extends State<FoodEntryForm> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _foodNameError;
  String? _descriptionError;
  String? _ingredientsError;
  String? _weightError;
  String? _successMessage;
  String? _analysisError;
  bool _showForm = true;
  FoodEntry? _savedFoodEntry;
  FoodTextAnalysisService? _analysisService;

  @override
  void initState() {
    super.initState();
    _initializeAnalysisService();
  }

  @override
  void dispose() {

    _foodNameError = null;
    _descriptionError = null;
    _ingredientsError = null;
    _weightError = null;
    _successMessage = null;
    _analysisError = null;
    _showForm = true;
    _savedFoodEntry = null;

    _foodNameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _weightController.dispose();
    _analysisService = null;
    
    super.dispose();
  }

  Future<void> _initializeAnalysisService() async {
    try {
      // Use the existing factory method instead of initialize()
      _analysisService = FoodTextAnalysisService.fromEnv();
    } catch (e) {
      // Handle initialization error gracefully
      setState(() {
        _analysisError = 'Failed to initialize analysis service: ${e.toString()}';
      });
    }
  }

  Future<void> _performAnalysis() async {
    if (_analysisService == null) {
      setState(() {
        _analysisError = 'Analysis service is not initialized';
      });
      return;
    }

    try {
      final foodEntry = _savedFoodEntry;
      if (foodEntry == null) return;

      // Create a combined text description for analysis
      final combinedText = "${foodEntry.foodName}: ${foodEntry.description}. Ingredients: ${foodEntry.ingredients}";
      // Use the existing analyze method
      final result = await _analysisService!.analyze(combinedText);
      
      // Handle the analysis result
      setState(() {
        _successMessage = 'Food analyzed successfully!';
        // You can add more UI updates based on the result if needed
      });
    } catch (e) {
      setState(() {
        _analysisError = 'Failed to analyze food entry: ${e.toString()}';
      });
    }
  }

  void _saveForm() {
    setState(() {
      _foodNameError = null;
      _descriptionError = null;
      _ingredientsError = null;
      _weightError = null;
      _successMessage = null;
      _analysisError = null;
    });

    // Validate all required fields
    _foodNameError = FormValidator.validateFoodName(_foodNameController.text.trim(), widget.maxFoodNameWords);
    _descriptionError = FormValidator.validateDescription(_descriptionController.text.trim(), widget.maxDescriptionWords);
    _ingredientsError = FormValidator.validateIngredients(_ingredientsController.text.trim(), widget.maxIngredientWords);
    
    // Always validate weight if required
    if (widget.weightRequired) {
      _weightError = FormValidator.validateWeight(_weightController.text.trim());
    }

    setState(() {});

    bool isValid = _foodNameError == null &&
        _descriptionError == null &&
        _ingredientsError == null &&
        (!widget.weightRequired || _weightError == null);

    if (isValid) {
      int? weight;
      if (_weightController.text.trim().isNotEmpty) {
        weight = double.tryParse(_weightController.text)?.toInt();
        if (widget.weightRequired && (weight == null || weight <= 0)) {
          setState(() {
            _weightError = 'Please enter a valid number greater than 0';
          });
          return;
        }
      } else if (widget.weightRequired) {
        setState(() {
          _weightError = 'Please enter a valid number';
        });
        return;
      }

      FoodEntry foodEntry = FoodEntry(
        foodName: _foodNameController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: _ingredientsController.text.trim(),
        weight: widget.weightRequired ? weight : null,
      );

      setState(() {
        _successMessage = 'Food entry is saved successfully!';
        _showForm = false;
        _savedFoodEntry = foodEntry;
      });

      if (widget.onSaved != null) {
        widget.onSaved!(foodEntry);
      }

      // Only perform analysis if weight is provided
      if (weight != null) {
        _performAnalysis();
      }
    }
  }

  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required String label,
    String? errorText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
          labelStyle: const TextStyle(color: Colors.black54),
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Color(0xFFFF6B6B),
            fontSize: 12,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.black12,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.black12,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4ECDC4),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFFF6B6B),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFFF6B6B),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_showForm) ...[
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
              if (widget.weightRequired)
                _buildTextField(
                  key: const ValueKey('weightField'),
                  controller: _weightController,
                  label: 'Weight (grams)',
                  errorText: _weightError,
                  keyboardType: TextInputType.number,
                ),
              ElevatedButton(
                key: const ValueKey('saveButton'),
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            if (_analysisError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _analysisError!,
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}