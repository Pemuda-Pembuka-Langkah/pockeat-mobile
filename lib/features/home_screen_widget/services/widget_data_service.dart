
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
}