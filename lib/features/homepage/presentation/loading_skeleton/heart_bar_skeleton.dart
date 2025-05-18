// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'skeleton_loading.dart';

class HeartBarSkeleton extends StatelessWidget {
  const HeartBarSkeleton({super.key});

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
      child: Column(
        children: [
          // Title skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SkeletonLoading(height: 16, width: 100),
              const SizedBox(width: 8),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Hearts row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: const SkeletonLoading(height: 32, width: 32),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Skeleton for status text
          const SkeletonLoading(height: 16, width: 160),
        ],
      ),
    );
  }
}
