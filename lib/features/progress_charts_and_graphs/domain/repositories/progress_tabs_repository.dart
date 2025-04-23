// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';

abstract class ProgressTabsRepository {
  Future<AppColors> getAppColors();
  Future<TabConfiguration> getTabConfiguration();
}
