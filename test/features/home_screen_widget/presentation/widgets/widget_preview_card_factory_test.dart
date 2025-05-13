// test/features/home_screen_widget/presentation/widgets/widget_preview_card_factory_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_preview_constants.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/presentation/widgets/widget_preview_card.dart';
import 'package:pockeat/features/home_screen_widget/presentation/widgets/widget_preview_card_factory.dart';

void main() {
  group('WidgetPreviewCardFactory', () {
    // Test createWidgetPreviewInfo method
    group('createWidgetPreviewInfo', () {
      test('should create correct WidgetPreviewInfo for simple widget when installed', () {
        // Act
        final widgetInfo = WidgetPreviewCardFactory.createWidgetPreviewInfo(
          WidgetType.simple, 
          true,
        );
        
        // Assert
        expect(widgetInfo.widgetType, equals(WidgetType.simple));
        expect(widgetInfo.imagePath, equals(WidgetPreviewConstants.simpleWidgetPreviewPath));
        expect(widgetInfo.title, equals(WidgetPreviewConstants.simpleWidgetTitle));
        expect(widgetInfo.isInstalled, isTrue);
      });
      
      test('should create correct WidgetPreviewInfo for simple widget when not installed', () {
        // Act
        final widgetInfo = WidgetPreviewCardFactory.createWidgetPreviewInfo(
          WidgetType.simple, 
          false,
        );
        
        // Assert
        expect(widgetInfo.widgetType, equals(WidgetType.simple));
        expect(widgetInfo.imagePath, equals(WidgetPreviewConstants.simpleWidgetPreviewPath));
        expect(widgetInfo.title, equals(WidgetPreviewConstants.simpleWidgetTitle));
        expect(widgetInfo.isInstalled, isFalse);
      });
      
      test('should create correct WidgetPreviewInfo for detailed widget when installed', () {
        // Act
        final widgetInfo = WidgetPreviewCardFactory.createWidgetPreviewInfo(
          WidgetType.detailed, 
          true,
        );
        
        // Assert
        expect(widgetInfo.widgetType, equals(WidgetType.detailed));
        expect(widgetInfo.imagePath, equals(WidgetPreviewConstants.detailedWidgetPreviewPath));
        expect(widgetInfo.title, equals(WidgetPreviewConstants.detailedWidgetTitle));
        expect(widgetInfo.isInstalled, isTrue);
      });
      
      test('should create correct WidgetPreviewInfo for detailed widget when not installed', () {
        // Act
        final widgetInfo = WidgetPreviewCardFactory.createWidgetPreviewInfo(
          WidgetType.detailed, 
          false,
        );
        
        // Assert
        expect(widgetInfo.widgetType, equals(WidgetType.detailed));
        expect(widgetInfo.imagePath, equals(WidgetPreviewConstants.detailedWidgetPreviewPath));
        expect(widgetInfo.title, equals(WidgetPreviewConstants.detailedWidgetTitle));
        expect(widgetInfo.isInstalled, isFalse);
      });
    });
    
    // Test createWidgetPreviewCard method - only test the type, not rendering
    group('createWidgetPreviewCard', () {
      // Mock callback
      Future<bool> mockOnInstall(WidgetType type) async => true;
      
      test('should create a WidgetPreviewCard with correct type and info', () {
        // Act
        final widget = WidgetPreviewCardFactory.createWidgetPreviewCard(
          WidgetType.simple,
          true,
          mockOnInstall,
        );
        
        // Assert
        expect(widget, isA<WidgetPreviewCard>());
        
        // Get the actual WidgetPreviewCard
        final card = widget as WidgetPreviewCard;
        
        // Verify the widget info properties
        expect(card.widgetInfo.widgetType, equals(WidgetType.simple));
        expect(card.widgetInfo.isInstalled, isTrue);
        expect(card.widgetInfo.title, equals(WidgetPreviewConstants.simpleWidgetTitle));
      });
      
      test('should create a WidgetPreviewCard with correct detailed info', () {
        // Act
        final widget = WidgetPreviewCardFactory.createWidgetPreviewCard(
          WidgetType.detailed,
          false,
          mockOnInstall,
        );
        
        // Assert
        expect(widget, isA<WidgetPreviewCard>());
        
        // Get the actual WidgetPreviewCard
        final card = widget as WidgetPreviewCard;
        
        // Verify the widget info properties
        expect(card.widgetInfo.widgetType, equals(WidgetType.detailed));
        expect(card.widgetInfo.isInstalled, isFalse);
        expect(card.widgetInfo.title, equals(WidgetPreviewConstants.detailedWidgetTitle));
      });
    });
    
    // Test createAllWidgetCards method
    group('createAllWidgetCards', () {
      // Mock callback
      Future<bool> mockOnInstall(WidgetType type) async => true;
      
      test('should create list with both widget cards and spacing', () {
        // Act
        final widgets = WidgetPreviewCardFactory.createAllWidgetCards(
          true,  // simple installed
          false, // detailed not installed
          mockOnInstall,
        );
        
        // Assert - should have 3 items
        expect(widgets.length, equals(3));
        
        // First widget should be WidgetPreviewCard
        expect(widgets[0], isA<WidgetPreviewCard>());
        
        // Second widget should be SizedBox for spacing
        expect(widgets[1], isA<SizedBox>());
        
        // Third widget should be WidgetPreviewCard
        expect(widgets[2], isA<WidgetPreviewCard>());
        
        // Verify widget info for simple card
        final simpleCard = widgets[0] as WidgetPreviewCard;
        expect(simpleCard.widgetInfo.widgetType, equals(WidgetType.simple));
        expect(simpleCard.widgetInfo.isInstalled, isTrue);
        
        // Verify widget info for detailed card
        final detailedCard = widgets[2] as WidgetPreviewCard;
        expect(detailedCard.widgetInfo.widgetType, equals(WidgetType.detailed));
        expect(detailedCard.widgetInfo.isInstalled, isFalse);
      });
      
      test('should reflect correct installation status for each widget', () {
        // Test different combinations
        bool isSimpleInstalled = false;
        bool isDetailedInstalled = true;
        
        // Act
        final widgets = WidgetPreviewCardFactory.createAllWidgetCards(
          isSimpleInstalled,
          isDetailedInstalled,
          mockOnInstall,
        );
        
        // Assert - installation status is reflected correctly
        final simpleCard = widgets[0] as WidgetPreviewCard;
        expect(simpleCard.widgetInfo.isInstalled, isFalse);
        
        final detailedCard = widgets[2] as WidgetPreviewCard;
        expect(detailedCard.widgetInfo.isInstalled, isTrue);
      });
    });
  });
}
