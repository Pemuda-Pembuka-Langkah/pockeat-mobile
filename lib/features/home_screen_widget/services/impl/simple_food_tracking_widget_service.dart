import 'dart:async';

import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_client.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_provider.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';

/// Implementasi WidgetDataService khusus untuk SimpleFoodTracking
///
/// Service ini menangani sinkronisasi data antara aplikasi dan home screen widget
/// dengan fokus pada data kalori harian yang dibutuhkan dan dikonsumsi
class SimpleFoodTrackingWidgetService
    implements WidgetDataService<SimpleFoodTracking> {
  /// Nama widget provider
  final String _widgetName;

  /// App group ID untuk berbagi data dengan widget
  final String _appGroupId;

  /// Client untuk berinteraksi dengan HomeWidget API
  /// Ini memungkinkan untuk di-mock saat testing
  final HomeWidgetInterface _homeWidget;

  /// Konstruktor dengan dependency injection untuk memudahkan testing
  SimpleFoodTrackingWidgetService({
    required String widgetName,
    required String appGroupId,
    HomeWidgetInterface? homeWidget,
  })  : _widgetName = widgetName,
        _appGroupId = appGroupId,
        _homeWidget = homeWidget ?? HomeWidgetProvider.getInstance();

  @override
  Future<void> initialize() async {
    // Set app group ID untuk berbagi data dengan widget
    await _homeWidget.setAppGroupId(_appGroupId);
  }

  @override
  Future<SimpleFoodTracking> getData() async {
    final data = await _getDataFromWidget();
    return SimpleFoodTracking.fromMap(data);
  }

  /// Mengambil data dari widget storage sebagai Map
  Future<Map<String, dynamic>> _getDataFromWidget() async {
    final map = <String, dynamic>{};

    // Gunakan FoodTrackingKey untuk konsistensi
    final caloriesNeeded = await _homeWidget
        .getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey());

    final currentCaloriesConsumed = await _homeWidget.getWidgetData<int?>(
        FoodTrackingKey.currentCaloriesConsumed.toStorageKey());

    // Dapatkan userId jika ada
    final userId = await _homeWidget
        .getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey());

    // Masukkan semua data ke map
    map[FoodTrackingKey.caloriesNeeded.toStorageKey()] = caloriesNeeded ?? 0;
    map[FoodTrackingKey.currentCaloriesConsumed.toStorageKey()] =
        currentCaloriesConsumed ?? 0;
    map[FoodTrackingKey.userId.toStorageKey()] = userId;

    return map;
  }

  @override
  Future<void> updateData(SimpleFoodTracking data) async {
    // Gunakan data langsung dari model
    final map = data.toMap();

    // Simpan semua field ke widget storage
    for (final entry in map.entries) {
      await _homeWidget.saveWidgetData(entry.key, entry.value);
    }

    // Update widget
    await updateWidget();
  }

  @override
  Future<void> updateWidget() async {
    await _homeWidget.updateWidget(
      name: _widgetName,
    );
  }
}
