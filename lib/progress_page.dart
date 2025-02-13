import 'package:pockeat/analytics_insight_section.dart';
import 'package:pockeat/calories_nutries_section.dart';
import 'package:pockeat/exercise_progress_section.dart';
import 'package:pockeat/weight_progress_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'navigation.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _progressTabController;
  final ScrollController _scrollController = ScrollController();

  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _progressTabController = TabController(length: 3, vsync: this);

    // Reset scroll pada pergantian tab
    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    _progressTabController.addListener(() {
      if (!_progressTabController.indexIsChanging) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _progressTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // App Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: primaryYellow,
            elevation: 0,
            toolbarHeight: 60,
            title: const Text(
              'Analytics',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.calendar, color: Colors.black87),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
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
              ),
            ],
          ),

          // Main Tabs (Progress & Insights)
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Colors.white,
            toolbarHeight: 0,
            bottom: TabBar(
              controller: _mainTabController,
              labelColor: primaryPink,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              indicatorColor: primaryPink,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              tabs: const [
                Text('Progress'),
                Text('Insights'),
              ],
            ),
          ),

          // Progress Sub-tabs (only shown when Progress tab is selected)
          SliverVisibility(
            visible: _mainTabController.index == 0,
            sliver: SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Colors.white,
              toolbarHeight: 64,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildProgressTab('Weight', 0),
                        _buildProgressTab('Nutrition', 1),
                        _buildProgressTab('Exercise', 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _mainTabController,
          children: [
            // Progress Tab Content
            TabBarView(
              controller: _progressTabController,
              children: const [
                WeightProgressSection(),
                NutritionProgressSection(),
                ExerciseProgressSection(),
              ],
            ),
            // Insights Tab Content
            const InsightsAnalyticsSection(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildProgressTab(String label, int index) {
    bool isSelected = _progressTabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _progressTabController.animateTo(index);
            // Reset scroll position ketika tab berubah
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? primaryPink : Colors.black54,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
