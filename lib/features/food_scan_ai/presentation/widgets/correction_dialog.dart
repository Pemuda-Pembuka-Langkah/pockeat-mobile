import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

class CorrectionDialog extends StatefulWidget {
  final Color primaryYellow;
  final Color primaryPink;
  final Color primaryGreen;
  final Function(String) onSubmit;
  final FoodAnalysisResult foodAnalysisResult;

  const CorrectionDialog({
    super.key,
    required this.primaryYellow,
    required this.primaryPink,
    required this.primaryGreen,
    required this.onSubmit,
    required this.foodAnalysisResult,
  });

  @override
  State<CorrectionDialog> createState() => _CorrectionDialogState();
}

class _CorrectionDialogState extends State<CorrectionDialog> {
  final TextEditingController _correctionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _correctionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.pencil_ellipsis_rectangle,
                color: widget.primaryGreen,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Correct Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCurrentAnalysisSummary(),
          const SizedBox(height: 20),
          const Text(
            'Enter your correction:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _correctionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Example: "This is brown rice, not white rice"',
              fillColor: Colors.grey[100],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCorrections(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_correctionController.text.trim().isEmpty) return;
                        
                        setState(() {
                          _isSubmitting = true;
                        });
                        
                        await widget.onSubmit(_correctionController.text.trim());
                        
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Correction',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAnalysisSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.primaryYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: Colors.grey[700],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Current analysis:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Food: ${widget.foodAnalysisResult.foodName}',
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            'Calories: ${widget.foodAnalysisResult.nutritionInfo.calories.toInt()} kcal',
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            'Ingredients: ${_formatIngredients()}',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatIngredients() {
    if (widget.foodAnalysisResult.ingredients.isEmpty) {
      return "None";
    }
    
    if (widget.foodAnalysisResult.ingredients.length <= 2) {
      return widget.foodAnalysisResult.ingredients.map((i) => i.name).join(", ");
    }
    
    return "${widget.foodAnalysisResult.ingredients[0].name}, ${widget.foodAnalysisResult.ingredients[1].name}, +${widget.foodAnalysisResult.ingredients.length - 2} more";
  }

  Widget _buildExampleCorrections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Example corrections:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '• "This is grilled chicken, not fried chicken"',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          '• "Add cheese and hot sauce"',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          '• "The portion is half of what is shown"',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}