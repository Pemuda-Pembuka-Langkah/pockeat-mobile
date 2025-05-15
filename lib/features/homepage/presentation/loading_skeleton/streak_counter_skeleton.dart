import 'package:flutter/material.dart';
import 'skeleton_loading.dart';

class StreakCounterSkeleton extends StatelessWidget {
  const StreakCounterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SkeletonLoading(width: 24, height: 24),
          SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonLoading(width: 150, height: 15),
              SizedBox(height: 10),
              SkeletonLoading(width: 150, height: 15),
            ],
          ),
        ],
      ),
    );
  }
}