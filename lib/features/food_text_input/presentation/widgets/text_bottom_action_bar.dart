// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/correction_dialog.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';

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
  });

  void showSnackBarMessage(BuildContext context, String message,
      {Color? backgroundColor}) {
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isLoading ? null : () => _showCorrectionDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryPink.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.pencil,
                        color: primaryPink.withOpacity(0.8), size: 18),
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
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    key: const Key('add_to_log_button'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      if (!isLoading && food != null) {
                        onSavingStateChange?.call(true);

                        try {
                          showSnackBarMessage(context, 'Saving food to log...',
                              backgroundColor: const Color(0xFF9B6BFF));

                          final message = await foodTextInputService
                              .saveFoodAnalysis(food!);

                          if (!context.mounted) return;

                          showSnackBarMessage(context, message,
                              backgroundColor: primaryGreen);

                          // Force update home screen widget
                          try {
                            final controller =
                                GetIt.I<FoodTrackingClientController>();
                            await controller.forceUpdate();
                            debugPrint(
                                'Home screen widget updated successfully');
                          } catch (e) {
                            // Silently log error but continue - don't block navigation
                            debugPrint(
                                'Failed to update home screen widget: $e');
                          }

                          // Navigate to food history page after successful save
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (context.mounted) {
                              // Pop to the root route first
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                              // Then navigate to analytics page with food history tab (index 1) open
                              Navigator.of(context).pushNamed('/analytic',
                                  arguments: {'initialTabIndex': 1});
                            }
                          });
                        } catch (e) {
                          if (!context.mounted) return;
                          showSnackBarMessage(
                              context, 'Failed to save: ${e.toString()}',
                              backgroundColor: Colors.red);
                        } finally {
                          onSavingStateChange?.call(false);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.plus,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Add to Log',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
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
          primaryYellow: Colors.grey[100]!,
          primaryPink: primaryPink,
          primaryGreen: primaryGreen,
          foodAnalysisResult: food!,
          onSubmit: (String userComment) async {
            try {
              Navigator.of(context).pop();
              showSnackBarMessage(context, 'Processing correction...',
                  backgroundColor: Colors.amber.shade700);
              final correctedResult = await foodTextInputService
                  .correctFoodAnalysis(food!, userComment);
              if (onAnalysisCorrected != null) {
                onAnalysisCorrected!(correctedResult);
              }
              return true;
            } catch (e) {
              if (!context.mounted) return false;
              showSnackBarMessage(
                  context, 'Failed to correct analysis: ${e.toString()}',
                  backgroundColor: Colors.red);
              return false;
            }
          },
        );
      },
    );
  }
}
