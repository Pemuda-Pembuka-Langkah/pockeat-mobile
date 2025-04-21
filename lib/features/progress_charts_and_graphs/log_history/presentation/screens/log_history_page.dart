import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/recently_exercise_section.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_recent_section.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/log_history/presentation/widgets/log_history_tab_widget.dart';

// coverage:ignore-start
class LogHistoryPage extends StatefulWidget {
  
  // ignore: use_super_parameters
  const LogHistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LogHistoryPage> createState() => _LogHistoryPageState();
}

class _LogHistoryPageState extends State<LogHistoryPage> with SingleTickerProviderStateMixin {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _shouldRefreshExerciseSection = false;
  final List<String> _tabLabels = ['Food', 'Exercise'];
  late AppColors _appColors;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _appColors = AppColors(
      primaryPink: primaryPink,
      primaryGreen: primaryGreen,
      primaryYellow: primaryYellow
    );
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // If switching to the exercises tab (index 1), trigger a rebuild
        if (_tabController.index == 1) {
          setState(() {
            _shouldRefreshExerciseSection = true;
          });
        } else {
          setState(() {
            _shouldRefreshExerciseSection = false;
          });
        }
      }
      
      // Reset scroll position when tab changes
      if (!_tabController.indexIsChanging) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final exerciseLogHistoryService = Provider.of<ExerciseLogHistoryService>(context);
    final foodLogHistoryService = Provider.of<FoodLogHistoryService>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        
        // Custom Tab Bar for selecting between Food and Exercise logs
        SizedBox(
          height: 60, // Match the height from ProgressSubtabsWidget
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: _tabLabels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = _tabController.index == index;
                  
                  return LogHistoryTabWidget(
                    label: label,
                    index: index,
                    isSelected: isSelected,
                    onTap: () => _onTabTapped(index),
                    colors: _appColors,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Food Log Tab (first tab)
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FoodRecentSection(
                      service: foodLogHistoryService,
                    ),
                    const SizedBox(height: 75), // Add padding at bottom to avoid overlap with navbar
                  ],
                ),
              ),
              
              // Exercise Log Tab (second tab)
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shouldRefreshExerciseSection
                      ? RecentlyExerciseSection(
                          repository: exerciseLogHistoryService,
                          key: UniqueKey(),
                        )
                      : RecentlyExerciseSection(
                          repository: exerciseLogHistoryService,
                        ),
                    const SizedBox(height: 75), // Add padding at bottom to avoid overlap with navbar
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end