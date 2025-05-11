// lib/features/home_screen_widget/domain/models/widget_preview_info.dart

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';

/// Model yang membungkus informasi preview widget
class WidgetPreviewInfo {
  /// Tipe widget
  final WidgetType widgetType;

  /// Path ke asset gambar preview
  final String imagePath;

  /// Judul widget
  final String title;

  /// Status instalasi widget
  final bool isInstalled;

  /// Membuat instance WidgetPreviewInfo
  const WidgetPreviewInfo({
    required this.widgetType,
    required this.imagePath,
    required this.title,
    required this.isInstalled,
  });
}
