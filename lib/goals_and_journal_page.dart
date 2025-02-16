import 'package:pockeat/achievement_tab.dart';
import 'package:pockeat/goal_tabs.dart';
import 'package:pockeat/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class ProgressTrackingPage extends StatefulWidget {
  const ProgressTrackingPage({super.key});

  @override
  _ProgressTrackingPageState createState() => _ProgressTrackingPageState();
}

class _ProgressTrackingPageState extends State<ProgressTrackingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NavigationProvider>(context, listen: false).setIndex(3);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // App Bar
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: primaryYellow,
              elevation: 0,
              toolbarHeight: 60,
              title: const Row(
                children: [
                  Text(
                    'My Goals',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(CupertinoIcons.calendar, color: Colors.black87),
                  onPressed: () {},
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Tab Bar
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Colors.white,
              toolbarHeight: 0,
              bottom: TabBar(
                controller: _tabController,
                labelColor: primaryPink,
                unselectedLabelColor: Colors.black38,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                indicatorColor: primaryPink,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                tabs: const [
                  Text('Goals'),
                  Text('Achievements'),
                ],
              ),
            ),
          ],
          body: Container(
            color: Colors.white,
            child: TabBarView(
              controller: _tabController,
              children: const [
                GoalsTab(),
                AchievementTab(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
