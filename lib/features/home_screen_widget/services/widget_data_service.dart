
import 'dart:async';

import 'package:pockeat/features/home_screen_widget/domain/constants/widget_event_type.dart';

/// Interface generic untuk layanan data widget home screen
/// 
/// `T` adalah tipe model data yang akan digunakan untuk berinteraksi dengan widget
abstract class WidgetDataService<T> {
  /// Inisialisasi service
  Future<void> initialize();

  /// Mengambil data widget dalam bentuk model T
  Future<T> getData();
  
  /// Memperbarui data widget dari model T
  Future<void> updateData(T data);
  
  /// Mengirim pembaruan ke widget home screen
  Future<void> updateWidget();
  
  /// Menangani callback dari widget ketika ditekan
  Future<void> handleWidgetClicked(Uri? uri);
  
  /// Mendaftarkan callback yang akan dipanggil ketika widget ditekan
  Future<void> registerWidgetClickCallback();
  
  /// Stream untuk berlangganan event dari widget
  Stream<FoodWidgetEventType> get widgetEvents;
}