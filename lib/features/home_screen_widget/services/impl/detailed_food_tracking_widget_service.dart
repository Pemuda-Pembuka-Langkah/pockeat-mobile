import 'dart:async';

import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_client.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_provider.dart';
import 'package:pockeat/features/home_screen_widget/services/widget_data_service.dart';

/// Implementasi WidgetDataService khusus untuk DetailedFoodTracking
///
/// Service ini menangani sinkronisasi data antara aplikasi dan home screen widget
/// dengan fokus pada data kalori dan makronutrien
class DetailedFoodTrackingWidgetService
    implements WidgetDataService<DetailedFoodTracking> {
  /// Nama widget provider
  final String _widgetName;

  /// App group ID untuk berbagi data dengan widget
  final String _appGroupId;

  /// Client untuk berinteraksi dengan HomeWidget API
  /// Ini memungkinkan untuk di-mock saat testing
  final HomeWidgetInterface _homeWidget;

  /// Konstruktor dengan dependency injection untuk memudahkan testing
  DetailedFoodTrackingWidgetService({
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
  Future<DetailedFoodTracking> getData() async {
    final data = await _getDataFromWidget();
    return DetailedFoodTracking.fromMap(data);
  }

  /// Mengambil data dari widget storage sebagai Map
  Future<Map<String, dynamic>> _getDataFromWidget() async {
    final map = <String, dynamic>{};

    // Gunakan FoodTrackingKey untuk konsistensi
    final dataToFetch = {
      FoodTrackingKey.caloriesNeeded: (dynamic value) =>
          value is double ? value.toInt() : (value is int ? value : 0),
      FoodTrackingKey.currentCaloriesConsumed: (dynamic value) =>
          value is double ? value.toInt() : (value is int ? value : 0),
      FoodTrackingKey.currentProtein: (dynamic value) =>
          value is double ? value : (value is int ? value.toDouble() : 0.0),
      FoodTrackingKey.currentCarb: (dynamic value) =>
          value is double ? value : (value is int ? value.toDouble() : 0.0),
      FoodTrackingKey.currentFat: (dynamic value) =>
          value is double ? value : (value is int ? value.toDouble() : 0.0),
      // Tambahkan userId handler
      FoodTrackingKey.userId: (dynamic value) => value?.toString(),
    };

    // Ambil semua data dari widget storage
    for (final entry in dataToFetch.entries) {
      final key = entry.key.toStorageKey();
      final converter = entry.value;

      final value = await _homeWidget.getWidgetData<dynamic>(key);
      // Tambahkan nilai ke map bahkan jika null, converter akan menangani default value
      map[key] = converter(value);
    }

    return map;
  }

  @override
  Future<void> updateData(DetailedFoodTracking data) async {
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
