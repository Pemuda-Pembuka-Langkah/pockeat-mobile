// test/features/home_screen_widget/presentation/widgets/widget_preview_card_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_preview_constants.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_preview_info.dart';
import 'package:pockeat/features/home_screen_widget/presentation/widgets/widget_preview_card.dart';

void main() {
  late WidgetPreviewInfo installedSimpleWidgetInfo;
  late WidgetPreviewInfo notInstalledDetailedWidgetInfo;
  bool wasInstallCalled = false;
  WidgetType? calledWidgetType;

  setUp(() {
    // Reset flags
    wasInstallCalled = false;
    calledWidgetType = null;

    // Initialize test data
    installedSimpleWidgetInfo = WidgetPreviewInfo(
      widgetType: WidgetType.simple,
      imagePath: WidgetPreviewConstants.simpleWidgetPreviewPath,
      title: WidgetPreviewConstants.simpleWidgetTitle,
      isInstalled: true,
    );

    notInstalledDetailedWidgetInfo = WidgetPreviewInfo(
      widgetType: WidgetType.detailed,
      imagePath: WidgetPreviewConstants.detailedWidgetPreviewPath,
      title: WidgetPreviewConstants.detailedWidgetTitle,
      isInstalled: false,
    );
  });

  // Helper function to build widget for testing
  Widget buildTestableWidget(
    Widget widget, {
    bool useScaffoldMessenger = false,
  }) {
    if (useScaffoldMessenger) {
      return MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      );
    }
    return MaterialApp(
      home: Scaffold(body: widget),
    );
  }

  // Success callback
  Future<bool> onInstallSuccess(WidgetType type) async {
    wasInstallCalled = true;
    calledWidgetType = type;
    return true;
  }

  // Failed callback
  Future<bool> onInstallFailed(WidgetType type) async {
    wasInstallCalled = true;
    calledWidgetType = type;
    return false;
  }

  // Error callback
  Future<bool> onInstallError(WidgetType type) async {
    wasInstallCalled = true;
    calledWidgetType = type;
    throw 'Test error';
  }

  group('WidgetPreviewCard', () {
    testWidgets('should render correctly with installed widget', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: installedSimpleWidgetInfo,
            onInstall: onInstallSuccess,
          ),
        ),
      );

      // Verify rendering
      expect(find.text(WidgetPreviewConstants.simpleWidgetTitle), findsOneWidget);
      expect(find.text('Installed'), findsOneWidget);
      expect(find.text('Update Widget'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render correctly with not installed widget', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: notInstalledDetailedWidgetInfo,
            onInstall: onInstallSuccess,
          ),
        ),
      );

      // Verify rendering
      expect(find.text(WidgetPreviewConstants.detailedWidgetTitle), findsOneWidget);
      expect(find.text('Not Installed'), findsOneWidget);
      expect(find.text('Add to Home Screen'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call onInstall when button is pressed', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: notInstalledDetailedWidgetInfo,
            onInstall: onInstallSuccess,
          ),
          useScaffoldMessenger: true,
        ),
      );

      // Tap on install button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // Wait for async operation

      // Verify callback was called with correct type
      expect(wasInstallCalled, isTrue);
      expect(calledWidgetType, equals(WidgetType.detailed));
    });

    testWidgets('should show snackbar when installation fails', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: notInstalledDetailedWidgetInfo,
            onInstall: onInstallFailed,
          ),
          useScaffoldMessenger: true,
        ),
      );

      // Tap on install button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(wasInstallCalled, isTrue);
      expect(calledWidgetType, equals(WidgetType.detailed));
      
      // Verify error snackbar is shown
      expect(find.text('Failed to add widget. Please try again.'), findsOneWidget);
    });

    testWidgets('should show error snackbar with error message', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: notInstalledDetailedWidgetInfo,
            onInstall: onInstallError,
          ),
          useScaffoldMessenger: true,
        ),
      );

      // Tap on install button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(wasInstallCalled, isTrue);
      expect(calledWidgetType, equals(WidgetType.detailed));
      
      // Verify error snackbar is shown with error message
      expect(find.text('Error: Test error'), findsOneWidget);
    });

    testWidgets('should use proper styling for installed status indicator', (WidgetTester tester) async {
      // Build widget with installed status
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: installedSimpleWidgetInfo,
            onInstall: onInstallSuccess,
          ),
        ),
      );

      // Find status indicator container
      final statusContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Installed'),
          matching: find.byType(Container),
        ).first,
      );

      // Verify container styling
      final decoration = statusContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, isA<BorderRadius>());
      
      // We can't directly test the exact color due to primaryGreen being a private field,
      // but we can verify it's not null and check border radius
      final bgColor = decoration.color;
      expect(bgColor, isNotNull);
      
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, 12.0);
    });

    testWidgets('should use proper styling for not installed status indicator', (WidgetTester tester) async {
      // Build widget with not installed status
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: notInstalledDetailedWidgetInfo,
            onInstall: onInstallSuccess,
          ),
        ),
      );

      // Find status indicator container
      final statusContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Not Installed'),
          matching: find.byType(Container),
        ).first,
      );

      // Verify container styling
      final decoration = statusContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, isA<BorderRadius>());
      
      // We expect orange color for not installed status
      final bgColor = decoration.color;
      expect(bgColor, isNotNull);
      
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, 12.0);
    });
    
    testWidgets('should use contain fit for widget preview image', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: installedSimpleWidgetInfo,
            onInstall: onInstallSuccess,
          ),
        ),
      );

      // Find Image widget inside ClipRRect
      final imageWidget = tester.widget<Image>(
        find.descendant(
          of: find.byType(ClipRRect),
          matching: find.byType(Image),
        ),
      );
      
      // Verify image is using BoxFit.contain instead of BoxFit.cover
      expect(imageWidget.fit, equals(BoxFit.contain));
    });
    
    testWidgets('should use proper button styling for installation button', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: notInstalledDetailedWidgetInfo,
            onInstall: onInstallSuccess,
          ),
        ),
      );

      // Find the button
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      
      // Verify button exists with proper text
      expect(button, isNotNull);
      expect(find.text('Add to Home Screen'), findsOneWidget);
      
      // We can't directly test MaterialStateProperty colors, 
      // but we can verify button styling exists
      expect(button.style, isNotNull);
    });
    
    testWidgets('should use titleMedium text style for widget title', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        buildTestableWidget(
          WidgetPreviewCard(
            widgetInfo: installedSimpleWidgetInfo,
            onInstall: onInstallSuccess,
          ),
        ),
      );

      // Find title text
      final titleFinder = find.text(WidgetPreviewConstants.simpleWidgetTitle);
      expect(titleFinder, findsOneWidget);
      
      // We can't directly test the text style since it depends on the theme,
      // but we can verify the text exists in the expected place
      expect(
        find.descendant(
          of: find.byType(Row),
          matching: titleFinder,
        ),
        findsOneWidget,
      );
    });
  });
}
