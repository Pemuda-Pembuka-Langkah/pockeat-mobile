// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'skeleton_loading.dart';

class PetCompanionSkeleton extends StatelessWidget {
  const PetCompanionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      SkeletonLoading(
        width: double.infinity,
        height: 350,
        borderRadius: 45,
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        height: 30,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonLoading(width: 100, height: 30),
          ],
        ),
      ),
    ]);
  }
}
