import 'package:flutter/material.dart';
import 'skeleton_loading.dart';

class CaloriesTodaySkeleton extends StatelessWidget {
  const CaloriesTodaySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonLoading(
        width: double.infinity, height: 350, borderRadius: 15);
  }
}
