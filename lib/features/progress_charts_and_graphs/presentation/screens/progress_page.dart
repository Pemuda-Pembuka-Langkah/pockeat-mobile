// import 'package:flutter/material.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/log_history/presentation/screens/log_history_page.dart';
// import 'package:provider/provider.dart';
// import 'package:get_it/get_it.dart';
// import 'package:pockeat/component/navigation.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/services/progress_tabs_service.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/app_bar_widget.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/main_tabs_widget.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/weight_progress_widget.dart';
// import 'package:pockeat/core/services/analytics_service.dart';

// // coverage:ignore-start
// class ProgressPage extends StatefulWidget {
//   final ProgressTabsService service;
  
//   // ignore: use_super_parameters
//   const ProgressPage({
//     Key? key,
//     required this.service,
//   }) : super(key: key);

//   @override
//   State<ProgressPage> createState() => _ProgressPageState();
// }

// // Unified progress insights widget replaced with the WeightProgressWidget
// class UnifiedInsightsWidget extends StatelessWidget {
//   const UnifiedInsightsWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const WeightProgressWidget();
//   }
// }

// class _ProgressPageState extends State<ProgressPage> with TickerProviderStateMixin {
//   late TabController _mainTabController;
//   final ScrollController _scrollController = ScrollController();
  
//   late AppColors _appColors;
//   late TabConfiguration _tabConfiguration;
  
//   bool _isInitialized = false;
//   late AnalyticsService _googleAnalyticsService;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     _googleAnalyticsService = GetIt.instance<AnalyticsService>();
//     _googleAnalyticsService.logScreenView(screenName: 'progress_page', screenClass: 'ProgressPage');
//     _googleAnalyticsService.logProgressViewed(category: 'all');
//   }
  
//   Future<void> _initializeData() async {
//     try {
//       // Load configurations
//       final colors = await widget.service.getAppColors();
//       final tabConfig = await widget.service.getTabConfiguration();
      
//       // Initialize main tab controller - just 2 tabs: Progress Insights and Log History
//       final mainTabController = TabController(
//         length: 2, // Fixed at 2 tabs now
//         vsync: this
//       );
      
//       // Set up tab change listeners
//       mainTabController.addListener(() {
//         setState(() {}); // Rebuild to update visibility
        
//         if (!mainTabController.indexIsChanging) {
//           _scrollController.animateTo(
//             0,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
          
//           // Track main tab changes for analytics
//           final tabName = mainTabController.index == 0 ? 'insights' : 'log_history';
//           _googleAnalyticsService.logEvent(
//             name: 'main_tab_changed',
//             parameters: {
//               'tab_name': tabName,
//               'timestamp': DateTime.now().toIso8601String(),
//             },
//           );
//         }
//       });
      
//       // Set state with loaded data
//       if (mounted) {
//         setState(() {
//           _appColors = colors;
//           _tabConfiguration = tabConfig;
//           _mainTabController = mainTabController;
//           _isInitialized = true;
//         });
//       }
      
//       // Set navigation index
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
//         }
//       });
      
//     } catch (e) {
//       debugPrint('Error initializing progress page: $e');
//     }
//   }

//   @override
//   void dispose() {
//     if (_isInitialized) {
//       _mainTabController.dispose();
//     }
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: NestedScrollView(
//         controller: _scrollController,
//         headerSliverBuilder: (context, innerBoxIsScrolled) => [
//           // App Bar
//           AppBarWidget(
//             colors: _appColors,
//             onCalendarPressed: () {
//               // Calendar action - kept empty as in original
//             },
//           ),

//           // Main Tabs (Insights & Log History)
//           MainTabsWidget(
//             tabController: _mainTabController,
//             colors: _appColors,
//           ),
//         ],
//         body: TabBarView(
//           controller: _mainTabController,
//           children: const [
//             // Insights Tab - Now a single unified page without subtabs
//             UnifiedInsightsWidget(),
            
//             // Log History Tab - Keeping this functionality intact
//             LogHistoryPage(),
//           ],
//         ),
//       ),
//       bottomNavigationBar: const CustomBottomNavBar(),
//     );
//   }
// }
// // coverage:ignore-end