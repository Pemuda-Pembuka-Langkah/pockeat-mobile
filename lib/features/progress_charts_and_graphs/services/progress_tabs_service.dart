import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/repositories/progress_tabs_repository.dart';

class ProgressTabsService {
  final ProgressTabsRepository _repository;

  ProgressTabsService(this._repository);

  Future<AppColors> getAppColors() async {
    return await _repository.getAppColors();
  }

  Future<TabConfiguration> getTabConfiguration() async {
    return await _repository.getTabConfiguration();
  }
}