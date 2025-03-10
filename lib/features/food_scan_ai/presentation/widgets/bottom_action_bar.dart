import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

class BottomActionBar extends StatelessWidget {
  final bool isLoading;
  final FoodAnalysisResult? food;
  final FoodScanPhotoService foodScanPhotoService;
  final Color primaryYellow;
  final Color primaryPink;

  const BottomActionBar({
    Key? key,
    required this.isLoading,
    required this.food,
    required this.foodScanPhotoService,
    required this.primaryYellow,
    required this.primaryPink,
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
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: primaryYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                key: const Key('fix_button'),
                borderRadius: BorderRadius.circular(8),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.wand_stars, size: 20, color: primaryPink),
                      const SizedBox(width: 6),
                      const Text(
                        'Fix',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                    try {
                      final message = await foodScanPhotoService
                          .saveFoodAnalysis(food!);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
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
    );
  }
} 