// Project imports:
import 'package:pockeat/features/home_screen_widget/services/utils/custom_home_widget_client.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_client.dart';

// coverage:ignore-start

/// Factory untuk menyediakan instance HomeWidgetInterface
///
/// Ini memudahkan kita untuk mengubah implementasi tanpa mengubah kode client
class HomeWidgetProvider {
  /// Flag untuk menggunakan implementasi custom
  static const bool _useCustomImplementation = true;

  /// Singleton instance
  static HomeWidgetInterface? _instance;

  /// Dapatkan instance HomeWidgetInterface
  ///
  /// Ini akan mengembalikan CustomHomeWidgetClient jika _useCustomImplementation true
  /// atau HomeWidgetClient jika false
  static HomeWidgetInterface getInstance() {
    _instance ??= _useCustomImplementation
        ? CustomHomeWidgetClient()
        : HomeWidgetClient();

    return _instance!;
  }
}
// coverage:ignore-end
