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
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
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
          tabs: const [
            Tab(text: 'Insights'),
            Tab(text: 'Log History'),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      pinned: true,
    );
  }
}

// coverage:ignore-start
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this._tabBar, {this.backgroundColor = Colors.white});

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return true;
  }
}
// coverage:ignore-end