import 'package:flutter/material.dart';
import 'package:pockeat/features/food_text_input/domain/models/food_entry.dart';
import 'package:pockeat/features/api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_loading.dart';

class FoodEntryForm extends StatefulWidget {
  final Function(FoodEntry)? onSaved;
  final bool isAnalyzing;
  final FoodEntry? existingEntry;
  final bool isCorrection;

  const FoodEntryForm({
    this.onSaved,
    this.isAnalyzing = false,
    this.existingEntry,
    this.isCorrection = false,
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
    if (widget.existingEntry != null) {
      _descriptionController.text = widget.existingEntry!.foodDescription;
    }
  }

  void _validateAndSubmit({bool isCorrection = false}) {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodAnalysisLoading(
          primaryYellow: const Color(0xFFFFE893),
          primaryPink: const Color(0xFFFF6B6B),
          message: isCorrection ? 'Updating Analysis' : 'Analyzing Food',
        ),
      ),
    );

    FoodEntry foodEntry = FoodEntry(foodDescription: input);
    widget.onSaved?.call(foodEntry);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                      hintText: 'Example: "Grilled chicken salad with lettuce, tomatoes, and olive oil dressing" or "Bowl of oatmeal with blueberries"',
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                    onChanged: (_) {
                      if (_descriptionError != null) {
                        setState(() {
                          _descriptionError = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isAnalyzing
                    ? null
                    : () => _validateAndSubmit(isCorrection: widget.isCorrection),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
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
                    : Text(
                        widget.existingEntry != null
                            ? 'Update & Analyze Food'
                            : 'Save & Analyze Food',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}