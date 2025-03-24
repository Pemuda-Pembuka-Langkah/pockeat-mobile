import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/correction_dialog.dart';

class TextBottomActionBar extends StatelessWidget {
  final bool isLoading;
  final FoodAnalysisResult? food;
  final FoodTextInputService foodTextInputService;
  final Color primaryYellow;
  final Color primaryPink;
  final Color primaryGreen;
  final Function(FoodAnalysisResult)? onAnalysisCorrected;
  final Function(bool)? onSavingStateChange;

  const TextBottomActionBar({
    super.key,
    required this.isLoading,
    required this.food,
    required this.foodTextInputService,
    required this.primaryYellow,
    required this.primaryPink,
    this.primaryGreen = const Color(0xFF4ECDC4),
    this.onAnalysisCorrected,
    this.onSavingStateChange,
  }) : super(key: key);

  void showSnackBarMessage(BuildContext context, String message, {Color? backgroundColor}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isLoading ? null : () => _showCorrectionDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.pencil, color: primaryPink.withOpacity(0.8), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Correct Analysis',
                      style: TextStyle(
                        color: primaryPink.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Material(
                  color: primaryPink,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    key: const Key('add_to_log_button'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      if (!isLoading && food != null) {
                        onSavingStateChange?.call(true); 
                        
                        try {
                          showSnackBarMessage(context, 'Saving food to log...', backgroundColor: Colors.blue);
                          
                          final message = await foodTextInputService.saveFoodAnalysis(food!);
                          
                          if (!context.mounted) return;
                          
                          showSnackBarMessage(context, message, backgroundColor: primaryGreen);
                          
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (context.mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          });
                          
                        } catch (e) {
                          if (!context.mounted) return;
                          showSnackBarMessage(context, 'Failed to save: ${e.toString()}', backgroundColor: Colors.red);
                        } finally {
                          onSavingStateChange?.call(false); 
                        }
                      }
                    },                    
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.plus, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text('Add to Log', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCorrectionDialog(BuildContext context) {
    if (food == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CorrectionDialog(
          primaryYellow: primaryYellow,
          primaryPink: primaryPink,
          primaryGreen: primaryGreen,
          foodAnalysisResult: food!,
          onSubmit: (String userComment) async {
            try {
              Navigator.of(context).pop();
              showSnackBarMessage(context, 'Processing correction...', backgroundColor: Colors.blue);
              final correctedResult = await foodTextInputService.correctFoodAnalysis(food!, userComment);
              if (onAnalysisCorrected != null) {
                onAnalysisCorrected!(correctedResult);
              }
              return true;
            } catch (e) {
              showSnackBarMessage(context, 'Failed to correct analysis: ${e.toString()}', backgroundColor: Colors.red);
              return false;
            }
          },
        );
      },
    );
  }
}