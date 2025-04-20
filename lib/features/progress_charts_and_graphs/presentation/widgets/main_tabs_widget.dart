import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';

class MainTabsWidget extends StatelessWidget {
  final TabController tabController;
  final AppColors colors;

  const MainTabsWidget({
    super.key,
    required this.tabController,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: Colors.white,
      toolbarHeight: 0,
      bottom: TabBar(
        controller: tabController,
        labelColor: colors.primaryPink,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        indicatorColor: colors.primaryPink,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        tabs: const [
          Text('Progress'),
          Text('Log History'),
        ],
      ),
    );
  }
}