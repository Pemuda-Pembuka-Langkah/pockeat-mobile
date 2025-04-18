import 'package:home_widget/home_widget.dart';

/// Interface untuk HomeWidget yang memudahkan mocking di unit tests
abstract class HomeWidgetInterface {
  Future<void> setAppGroupId(String groupId);
  Future<T?> getWidgetData<T>(String key);
  Future<void> saveWidgetData(String key, dynamic value);
  Future<void> updateWidget({required String name, String? androidName, String? iOSName});
  Future<void> registerBackgroundCallback(Future<void> Function(Uri? uri) callback);
}

/// Implementasi default dari HomeWidgetInterface menggunakan package home_widget
class HomeWidgetClient implements HomeWidgetInterface {
  @override
  Future<void> setAppGroupId(String groupId) async {
    await HomeWidget.setAppGroupId(groupId);
  }
  
  @override
  Future<T?> getWidgetData<T>(String key) async {
    return await HomeWidget.getWidgetData<T>(key);
  }
  
  @override
  Future<void> saveWidgetData(String key, dynamic value) async {
    await HomeWidget.saveWidgetData(key, value);
  }
  
  @override
  Future<void> updateWidget({required String name, String? androidName, String? iOSName}) async {
    await HomeWidget.updateWidget(
      name: name,
      androidName: androidName,
      iOSName: iOSName,
    );
  }
  
  @override
  Future<void> registerBackgroundCallback(Future<void> Function(Uri? uri) callback) async {
    await HomeWidget.registerBackgroundCallback(callback);
  }
}
