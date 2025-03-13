import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/correction_dialog.dart';

class BottomActionBar extends StatelessWidget {
  final bool isLoading;
  final FoodAnalysisResult? food;
  final FoodScanPhotoService foodScanPhotoService;
  final Color primaryYellow;
  final Color primaryPink;
  final Color primaryGreen;
  final Function(FoodAnalysisResult)? onAnalysisCorrected;

  const BottomActionBar({
    Key? key,
    required this.isLoading,
    required this.food,
    required this.foodScanPhotoService,
    required this.primaryYellow,
    required this.primaryPink,
    this.primaryGreen = const Color(0xFF4ECDC4),
    this.onAnalysisCorrected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Correction button
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
                    Icon(
                      CupertinoIcons.pencil,
                      color: primaryPink.withOpacity(0.8),
                      size: 18,
                    ),
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
          // Add to Log button
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
                        // Tampilkan indikator loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        
                        try {
                          final message = await foodScanPhotoService
                              .saveFoodAnalysis(food!);

                          if (!context.mounted) return;
                          
                          // Tutup dialog loading
                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: primaryGreen, // Warna hijau
                            ),
                          );

                          Navigator.pop(context);

                        } catch (e) {
                          if (!context.mounted) return;
                          
                          // Tutup dialog loading
                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: ${e.toString()}')),
                          );
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
                          Text(
                            'Add to Log',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
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
              // The dialog will close itself before this code executes
              
              // Show a loading indicator
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Processing correction...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
              
              final correctedResult = await foodScanPhotoService.correctFoodAnalysis(
                food!,
                userComment,
              );
              
              if (onAnalysisCorrected != null) {
                onAnalysisCorrected!(correctedResult);
              }
              
              return true;
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to correct analysis: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return false;
            }
          },
        );
      },
    );
  }
}