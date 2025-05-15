// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'skeleton_loading.dart';

class HealthConnectSkeleton extends StatelessWidget {
  const HealthConnectSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SkeletonLoading(width: double.infinity, height: 60, borderRadius: 15),
          SizedBox(height: 16),
          SkeletonLoading(width: double.infinity, height: 70, borderRadius: 15),
          SizedBox(height: 16),
          SkeletonLoading(width: double.infinity, height: 70, borderRadius: 15),
        ],
      ),
    );
  }
}
