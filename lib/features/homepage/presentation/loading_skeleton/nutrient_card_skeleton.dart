// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'skeleton_loading.dart';

class NutrientCardSkeleton extends StatelessWidget {
  const NutrientCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoading(width: 24, height: 24),
              SizedBox(width: 8),
              Expanded(
                child: SkeletonLoading(width: 32, height: 16),
              ),
            ],
          ),
          SizedBox(height: 12),
          SkeletonLoading(width: 80, height: 24),
        ],
      ),
    );
  }
}
