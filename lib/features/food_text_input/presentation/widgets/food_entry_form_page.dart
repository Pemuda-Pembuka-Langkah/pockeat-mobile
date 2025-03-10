import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/food_text_input/presentation/utils/food_entry_form_validator.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

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
  final _correctionController = TextEditingController();

  String? _foodNameError;
  String? _descriptionError;
  String? _ingredientsError;
  String? _weightError;
  String? _successMessage;
  bool _showCorrectionInterface = false;
  bool _isAnalyzing = false;
  bool _showForm = true;
  bool _showAnalysisResults = false;
  FoodEntry? _savedFoodEntry;
  FoodAnalysisResult? _analysisResult;
  String? _analysisError;

  late FoodTextAnalysisService _analysisService;

  @override
  void initState() {
    super.initState();
    // Initialize the analysis service
    _analysisService = FoodTextAnalysisService.fromEnv();
  }

  Future<void> _performAnalysis() async {
    if (_savedFoodEntry == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    try {
      // Combine food name, description and ingredients for analysis
      final textToAnalyze = 
          "${_savedFoodEntry!.foodName}\n${_savedFoodEntry!.description}\n${_savedFoodEntry!.ingredients}";
      
      final result = await _analysisService.analyze(textToAnalyze);
      
      setState(() {
        _analysisResult = result;
        _showAnalysisResults = true;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _analysisError = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _correctAnalysis() async {
    if (_analysisResult == null || _correctionController.text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _analysisService.correctAnalysis(
        _analysisResult!,
        _correctionController.text,
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
        // Clear the correction input after applying
        _correctionController.clear();
        _showCorrectionInterface = false;
      });
    } catch (e) {
      setState(() {
        _analysisError = e.toString();
        _isAnalyzing = false;
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
        _successMessage = 'Food entry saved successfully!';
        _showForm = false;
        _savedFoodEntry = foodEntry;
      });

      // Trigger analysis after saving
      _performAnalysis();
    }
  }

  void _toggleCorrectionInterface() {
    setState(() {
      _showCorrectionInterface = !_showCorrectionInterface;
    });
  }

  void _goBackToForm() {
    setState(() {
      _showForm = true;
      _showAnalysisResults = false;
      _analysisResult = null;
      _savedFoodEntry = null;
      _successMessage = null;
    });
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _weightController.dispose();
    _correctionController.dispose();
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

  Widget _buildSavedFoodEntryView() {
    if (_savedFoodEntry == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_successMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _successMessage!,
                style: const TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Food Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF4ECDC4)),
                onPressed: _goBackToForm,
                tooltip: 'Edit food details',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailItem('Name', _savedFoodEntry!.foodName),
          _buildDetailItem('Description', _savedFoodEntry!.description),
          _buildDetailItem('Ingredients', _savedFoodEntry!.ingredients),
          if (_savedFoodEntry!.weight != null)
            _buildDetailItem('Weight', '${_savedFoodEntry!.weight}g'),
          const SizedBox(height: 16),
          
          if (_isAnalyzing)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF4ECDC4)),
                  SizedBox(height: 16),
                  Text('Analyzing food details...'),
                ],
              ),
            )
          else if (_analysisError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                SizedBox(height: 8),
                Text(_analysisError!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _performAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Retry Analysis'),
                ),
              ],
            )
          else if (_showAnalysisResults && _analysisResult != null)
            _buildAnalysisResultView(_analysisResult!)
        ],
      ),
    );
  }

  Widget _buildAnalysisResultView(FoodAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Analysis Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Nutrition Info Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nutrition Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(height: 12),
              _buildNutritionRow('Calories', '${result.nutritionInfo.calories}'),
              _buildNutritionRow('Protein', '${result.nutritionInfo.protein}g'),
              _buildNutritionRow('Carbs', '${result.nutritionInfo.carbs}g'),
              _buildNutritionRow('Fat', '${result.nutritionInfo.fat}g'),
              _buildNutritionRow('Fiber', '${result.nutritionInfo.fiber}g'),
              _buildNutritionRow('Sugar', '${result.nutritionInfo.sugar}g'),
              _buildNutritionRow('Sodium', '${result.nutritionInfo.sodium}mg'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Ingredients Section
        Text(
          'Detected Ingredients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: result.ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ingredient.name),
                  Text('${ingredient.servings}g', 
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Warnings Section
        if (result.warnings.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Warnings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 8),
                ...result.warnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, 
                        color: Color(0xFFFF6B6B), size: 20),
                      SizedBox(width: 8),
                      Text(warning),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),

        const SizedBox(height: 24),
        
        // Correction Interface
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleCorrectionInterface,
                icon: Icon(_showCorrectionInterface 
                  ? Icons.close 
                  : Icons.edit, color: Colors.white),
                label: Text(_showCorrectionInterface 
                  ? 'Cancel' 
                  : 'Correct Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showCorrectionInterface 
                    ? Colors.grey 
                    : const Color(0xFF4ECDC4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (_showCorrectionInterface) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _correctionController,
            label: 'Enter your correction',
            maxLines: 3,
          ),
          ElevatedButton(
            onPressed: _isAnalyzing ? null : _correctAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isAnalyzing ? 'Processing...' : 'Apply Correction',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _showForm ? Form(
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
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save & Analyze Food',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ) : _buildSavedFoodEntryView(),
      ),
    );
  }
}