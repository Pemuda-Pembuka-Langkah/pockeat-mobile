import 'package:flutter/services.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_config.dart';
import 'home_widget_client.dart';

// coverage:ignore-file
/// Implementasi custom HomeWidgetInterface menggunakan MethodChannel langsung
/// Ini memberikan kontrol lebih dan memudahkan debugging
class CustomHomeWidgetClient implements HomeWidgetInterface {
  /// Method channel untuk komunikasi dengan kode native
  final MethodChannel _channel = const MethodChannel('com.pockeat/custom_home_widget');
  
  // Catatan: Gunakan HomeWidgetConfig.customChannelName.value saat nilai konstanta dibutuhkan
  
  /// App group ID untuk berbagi data dengan widget
  String? _appGroupId = HomeWidgetConfig.appGroupId.value;
  
  @override
  Future<void> setAppGroupId(String groupId) async {
    _appGroupId = groupId;
    try {
      await _channel.invokeMethod('setAppGroupId', {
        'groupId': groupId,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<T?> getWidgetData<T>(String key) async {
    if (_appGroupId == null) {
      return null;
    }
    
    try {
      final result = await _channel.invokeMethod('getWidgetData', {
        'key': key,
        'appGroupId': _appGroupId,
      });
      
      // Handle type conversion - ini penting untuk menghindari masalah casting
      if (result == null) {
        return null;
      }
      
      // Konversi berdasarkan tipe yang diminta
      if (T == int) {
        return (result is int ? result : int.tryParse(result.toString()) ?? 0) as T?;
      } else if (T == double) {
        return (result is double ? result : double.tryParse(result.toString()) ?? 0.0) as T?;
      } else if (T == bool) {
        return (result is bool ? result : (result.toString() == 'true')) as T?;
      } else if (T == String) {
        return result.toString() as T?;
      }
      
      return result as T?;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> saveWidgetData(String id, dynamic data) async {
    if (_appGroupId == null) {
      throw Exception('App group ID not set');
    }
    
    try {
      await _channel.invokeMethod('saveWidgetData', {
        'key': id,
        'value': data,
        'appGroupId': _appGroupId,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> updateWidget({
    required String name, 
    String? androidName, 
    String? iOSName
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'name': name,
        'androidName': androidName ?? name,
        'iOSName': iOSName,
      });
    } catch (e) {
      rethrow;
    }
  }
}
