import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/screens/weight_progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/services/weight_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/repositories/weight_repository_impl.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/screens/nutrition_progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/services/nutrition_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/repositories/nutrition_repository_impl.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/screens/exercise_progress_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/services/exercise_progress_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/presentation/screens/analytics_insight_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/services/analytics_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/repositories/analytics_repository_impl.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/progress_tabs_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/app_bar_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/main_tabs_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/progress_subtabs_widget.dart';

// coverage:ignore-start
class ProgressPage extends StatefulWidget {
  final ProgressTabsService service;
  
  const ProgressPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _progressTabController;
  final ScrollController _scrollController = ScrollController();
  
  late AppColors _appColors;
  late TabConfiguration _tabConfiguration;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    try {
      // Load configurations
      final colors = await widget.service.getAppColors();
      final tabConfig = await widget.service.getTabConfiguration();
      
      // Initialize controllers
      final mainTabController = TabController(
        length: tabConfig.mainTabCount, 
        vsync: this
      );
      
      final progressTabController = TabController(
        length: tabConfig.progressTabCount, 
        vsync: this
      );
      
      // Set up tab change listeners
      mainTabController.addListener(() {
        setState(() {}); // Rebuild to update visibility
        
        if (!mainTabController.indexIsChanging) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      progressTabController.addListener(() {
        if (!progressTabController.indexIsChanging) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
      // Set state with loaded data
      if (mounted) {
        setState(() {
          _appColors = colors;
          _tabConfiguration = tabConfig;
          _mainTabController = mainTabController;
          _progressTabController = progressTabController;
          _isInitialized = true;
        });
      }
      
      // Set navigation index
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
        }
      });
      
    } catch (e) {
      debugPrint('Error initializing progress page: $e');
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _mainTabController.dispose();
      _progressTabController.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // App Bar
          AppBarWidget(
            colors: _appColors,
            onCalendarPressed: () {
              // Calendar action - kept empty as in original
            },
          ),

          // Main Tabs (Progress & Insights)
          MainTabsWidget(
            tabController: _mainTabController,
            colors: _appColors,
          ),

          // Progress Sub-tabs (only shown when Progress tab is selected)
          ProgressSubtabsWidget(
            mainTabController: _mainTabController,
            progressTabController: _progressTabController,
            scrollController: _scrollController,
            colors: _appColors,
            tabConfiguration: _tabConfiguration,
          ),
        ],
        body: TabBarView(
          controller: _mainTabController,
          children: [
            // Progress Tab Content
            TabBarView(
              controller: _progressTabController,
              children: [
                WeightProgressPage(
                  service: WeightService(WeightRepositoryImpl()),
                ),
                NutritionProgressPage(
                  service: GetIt.instance<NutritionService>(),
                ),
                ExerciseProgressPage(
                  // Use the registered service from GetIt
                  service: GetIt.instance<ExerciseProgressService>(),
                ),
              ],
            ),
            // Insights Tab Content
            AnalyticsInsightPage(
              service: AnalyticsService(AnalyticsRepositoryImpl()),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
// coverage:ignore-end