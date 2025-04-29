// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';

class AppBarWidget extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onCalendarPressed;

  const AppBarWidget({
    super.key,
    required this.colors,
    required this.onCalendarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      backgroundColor: colors.primaryYellow,
      elevation: 0,
      toolbarHeight: 60,
      title: const Text(
        'Progress',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
