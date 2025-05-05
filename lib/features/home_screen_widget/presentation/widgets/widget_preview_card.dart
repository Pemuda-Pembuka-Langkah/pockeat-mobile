// lib/features/home_screen_widget/presentation/widgets/widget_preview_card.dart

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_preview_info.dart';

/// Widget card that displays a preview of a home screen widget,
/// its installation status, and a button to install/update it
class WidgetPreviewCard extends StatelessWidget {
  /// Informasi preview widget
  final WidgetPreviewInfo widgetInfo;

  /// Callback when install button is pressed
  final Future<bool> Function(WidgetType) onInstall;

  /// Creates a widget preview card
  const WidgetPreviewCard({
    super.key,
    required this.widgetInfo,
    required this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get widget info properties
    final bool isInstalled = widgetInfo.isInstalled;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget title and status indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    widgetInfo.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusIndicator(isInstalled, theme),
              ],
            ),
            
            const SizedBox(height: 12.0),
            
            // Widget preview image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                widgetInfo.imagePath,
                fit: BoxFit.cover,
                height: 180.0,
                width: double.infinity,
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // Install/Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleInstallTap(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  isInstalled ? 'Update Widget' : 'Add to Home Screen',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a status indicator showing if the widget is installed
  Widget _buildStatusIndicator(bool isInstalled, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0, 
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: isInstalled 
            ? Colors.green.withOpacity(0.2) 
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInstalled ? Icons.check_circle : Icons.info_outline,
            size: 16.0,
            color: isInstalled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4.0),
          Text(
            isInstalled ? 'Installed' : 'Not Installed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isInstalled ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }



  /// Handles tap on install button
  Future<void> _handleInstallTap(BuildContext context) async {
    try {
      final result = await onInstall(widgetInfo.widgetType);
      
      if (!result) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add widget. Please try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
