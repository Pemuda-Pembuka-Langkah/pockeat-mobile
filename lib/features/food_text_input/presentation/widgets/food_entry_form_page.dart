import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

class FoodEntryForm extends StatefulWidget {
  final Function(FoodEntry)? onSaved;
  final bool isAnalyzing;

  const FoodEntryForm({
    this.onSaved,
    this.isAnalyzing = false,
    super.key,
  });

  @override
  _FoodEntryFormState createState() => _FoodEntryFormState();
}

class _FoodEntryFormState extends State<FoodEntryForm> {
  final _descriptionController = TextEditingController();
  String? _descriptionError;
  
  late FoodTextAnalysisService _analysisService;

  @override
  void initState() {
    super.initState();
    _analysisService = FoodTextAnalysisService.fromEnv();
  }
  
  void _validateAndSubmit() {
    final input = _descriptionController.text.trim();
    
    if (input.isEmpty) {
      setState(() {
        _descriptionError = 'Food description cannot be empty';
      });
      return;
    }
    
    setState(() {
      _descriptionError = null;
    });
    
    FoodEntry foodEntry = FoodEntry(
      foodDescription: input,
    );

    widget.onSaved?.call(foodEntry);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Describe your food',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Provide details about what you ate, including ingredients and portion sizes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Example: "Grilled chicken salad with lettuce, tomatoes, and olive oil dressing" or "Bowl of oatmeal with blueberries"',
              hintStyle: const TextStyle(color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black26),
              ),
              errorText: _descriptionError,
            ),
            onChanged: (_) {
              if (_descriptionError != null) {
                setState(() {
                  _descriptionError = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isAnalyzing ? null : _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4), // Keeping your app's original color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
              child: widget.isAnalyzing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save & Analyze Food',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}