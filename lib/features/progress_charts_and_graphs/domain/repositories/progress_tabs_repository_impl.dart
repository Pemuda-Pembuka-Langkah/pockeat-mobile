import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/repositories/progress_tabs_repository.dart';

class ProgressTabsRepositoryImpl implements ProgressTabsRepository {
  @override
  Future<AppColors> getAppColors() async {
    // Return default colors, this could be loaded from preferences in the future
    return AppColors.defaultColors();
  }

  @override
  Future<TabConfiguration> getTabConfiguration() async {
    return TabConfiguration(
      mainTabCount: 2,
      logHistoryTabCount: 2,
      logHistoryTabLabels: ['Food', 'Exercise'],
    );
  }
}