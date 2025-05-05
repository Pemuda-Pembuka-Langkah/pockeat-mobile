// lib/features/home_screen_widget/presentation/widgets/widget_preview_card_factory.dart

import 'package:flutter/material.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_preview_constants.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_preview_info.dart';
import 'package:pockeat/features/home_screen_widget/presentation/widgets/widget_preview_card.dart';

/// Factory untuk membuat widget preview card
class WidgetPreviewCardFactory {
  /// Membuat Widget Preview Info berdasarkan type dan status instalasi
  static WidgetPreviewInfo createWidgetPreviewInfo(WidgetType type, bool isInstalled) {
    // Gunakan switch dengan exhaustive case
    // untuk memastikan semua tipe widget ditangani
    switch (type) {
      case WidgetType.simple:
        return WidgetPreviewInfo(
          widgetType: WidgetType.simple,
          imagePath: WidgetPreviewConstants.simpleWidgetPreviewPath,
          title: WidgetPreviewConstants.simpleWidgetTitle,
          isInstalled: isInstalled,
        );
      case WidgetType.detailed:
        return WidgetPreviewInfo(
          widgetType: WidgetType.detailed,
          imagePath: WidgetPreviewConstants.detailedWidgetPreviewPath,
          title: WidgetPreviewConstants.detailedWidgetTitle,
          isInstalled: isInstalled,
        );
    }
  }

  /// Membuat WidgetPreviewCard berdasarkan type dan status instalasi
  static Widget createWidgetPreviewCard(
    WidgetType type,
    bool isInstalled,
    Future<bool> Function(WidgetType) onInstall,
  ) {
    final widgetInfo = createWidgetPreviewInfo(type, isInstalled);
    return WidgetPreviewCard(
      widgetInfo: widgetInfo,
      onInstall: onInstall,
    );
  }

  /// Membuat semua widget card berdasarkan status instalasi
  static List<Widget> createAllWidgetCards(
    bool isSimpleWidgetInstalled,
    bool isDetailedWidgetInstalled,
    Future<bool> Function(WidgetType) onInstall,
  ) {
    return [
      createWidgetPreviewCard(WidgetType.simple, isSimpleWidgetInstalled, onInstall),
      const SizedBox(height: 16.0),
      createWidgetPreviewCard(WidgetType.detailed, isDetailedWidgetInstalled, onInstall),
    ];
  }
}
