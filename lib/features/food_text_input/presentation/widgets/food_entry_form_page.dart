import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

class FoodEntryForm extends StatefulWidget {
  final Function(FoodEntry)? onSaved;

  const FoodEntryForm({
    this.onSaved,
    super.key,
  });

  @override
  _FoodEntryFormState createState() => _FoodEntryFormState();
}

class _FoodEntryFormState extends State<FoodEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _correctionController = TextEditingController();

  String? _descriptionError;
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
    _analysisService = FoodTextAnalysisService.fromEnv();
  }

  Future<void> _performAnalysis() async {
    if (_savedFoodEntry == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    try {
      final textToAnalyze = _savedFoodEntry!.foodDescription;
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

  void _saveForm() {
    setState(() {
      _descriptionError = null;
      _successMessage = null;
      _analysisError = null;
    });

    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _descriptionError = 'Please insert food description';
      });
      return;
    }

    FoodEntry foodEntry = FoodEntry(
      foodDescription: _descriptionController.text,
    );

    widget.onSaved?.call(foodEntry);

    setState(() {
      _successMessage = 'Food entry saved successfully!';
      _showForm = false;
      _savedFoodEntry = foodEntry;
    });

    _performAnalysis();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _correctionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _showForm
            ? Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: const ValueKey('descriptionField'),
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        errorText: _descriptionError,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
              )
            : Container(),
      ),
    );
  }
}