import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/progress_tab_item_widget.dart';

class ProgressSubtabsWidget extends StatefulWidget {
  final TabController mainTabController;
  final TabController progressTabController;
  final ScrollController scrollController;
  final AppColors colors;
  final TabConfiguration tabConfiguration;
  
  const ProgressSubtabsWidget({
    Key? key,
    required this.mainTabController,
    required this.progressTabController,
    required this.scrollController,
    required this.colors,
    required this.tabConfiguration,
  }) : super(key: key);

  @override
  State<ProgressSubtabsWidget> createState() => _ProgressSubtabsWidgetState();
}

class _ProgressSubtabsWidgetState extends State<ProgressSubtabsWidget> {
  @override
  void initState() {
    super.initState();
    // Add a listener to rebuild when tab selection changes
    widget.progressTabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    // Remove the listener when widget is disposed
    widget.progressTabController.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    // Force rebuild when tab selection changes
    if (mounted) setState(() {});
  }

  void _onTabTapped(int index) {
    widget.progressTabController.animateTo(index);
    // Reset scroll position when tab changes
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverVisibility(
      visible: widget.mainTabController.index == 0,
      sliver: SliverAppBar(
        // Set pinned to false so it can hide when scrolling down
        pinned: false,
        // Set floating to true so it appears when scrolling up
        floating: true,
        // Set snap to true for immediate appearance when scrolling up starts
        snap: true,
        backgroundColor: Colors.white,
        toolbarHeight: 64,
        // Add elevation for better visual separation when it reappears
        elevation: 2,
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
                children: widget.tabConfiguration.progressTabLabels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  // This will now update correctly when the controller's index changes
                  final isSelected = widget.progressTabController.index == index;
                  
                  return ProgressTabItemWidget(
                    label: label,
                    index: index,
                    isSelected: isSelected,
                    onTap: () => _onTabTapped(index),
                    colors: widget.colors,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}