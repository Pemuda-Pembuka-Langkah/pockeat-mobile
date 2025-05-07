// test/features/home_screen_widget/presentation/screens/widget_manager_screen_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/home_screen_widget/controllers/widget_installation_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/presentation/screens/widget_manager_screen.dart';
import 'package:pockeat/features/home_screen_widget/presentation/widgets/widget_preview_card.dart';

// Generate mocks
@GenerateMocks([WidgetInstallationController])
import 'widget_manager_screen_test.mocks.dart';

void main() {
  late MockWidgetInstallationController mockController;
  late StreamController<WidgetInstallationStatus> statusStreamController;
  final getIt = GetIt.instance;

  const initialStatus = WidgetInstallationStatus(
    isSimpleWidgetInstalled: false,
    isDetailedWidgetInstalled: false,
  );
  
  const bothInstalledStatus = WidgetInstallationStatus(
    isSimpleWidgetInstalled: true,
    isDetailedWidgetInstalled: true,
  );
  
  const mixedStatus = WidgetInstallationStatus(
    isSimpleWidgetInstalled: true,
    isDetailedWidgetInstalled: false,
  );

  setUp(() {
    mockController = MockWidgetInstallationController();
    statusStreamController = StreamController<WidgetInstallationStatus>.broadcast();
    
    // Setup mock controller behavior
    when(mockController.widgetStatusStream).thenAnswer(
      (_) => statusStreamController.stream,
    );
    when(mockController.getWidgetStatus()).thenAnswer(
      (_) async => initialStatus,
    );
    
    // Register the mock controller with GetIt
    if (getIt.isRegistered<WidgetInstallationController>()) {
      getIt.unregister<WidgetInstallationController>();
    }
    getIt.registerSingleton<WidgetInstallationController>(mockController);
  });

  tearDown(() {
    // Clean up
    statusStreamController.close();
    if (getIt.isRegistered<WidgetInstallationController>()) {
      getIt.unregister<WidgetInstallationController>();
    }
  });

  group('WidgetManagerScreen', () {
    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      // Setup a delayed response but don't actually delay in test
      when(mockController.getWidgetStatus()).thenAnswer((_) => Future.value(initialStatus));
      
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: WidgetManagerScreen(),
        ),
      );
      
      // Verify loading indicator is shown before response completes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('App Widget Settings'), findsOneWidget);
      expect(find.byType(WidgetPreviewCard), findsNothing);
      
      // Complete the future and rebuild
      await tester.pumpAndSettle();
    });

    testWidgets('should show widget cards when status is loaded', (WidgetTester tester) async {
      // Setup mixed status response
      when(mockController.getWidgetStatus()).thenAnswer(
        (_) async => mixedStatus,
      );
      
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: WidgetManagerScreen(),
        ),
      );
      
      // Allow widget to build
      await tester.pumpAndSettle();
      
      // Verify UI
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('App Widget Settings'), findsOneWidget);
      expect(find.text('Add these widgets to your home screen for quick access to your nutrition tracking data.'), findsOneWidget);
      expect(find.byType(WidgetPreviewCard), findsNWidgets(2));
    });

    testWidgets('should show error state when loading fails', (WidgetTester tester) async {
      // Setup error response
      when(mockController.getWidgetStatus()).thenThrow(
        Exception('Test error on getWidgetStatus'),
      );
      
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: WidgetManagerScreen(),
        ),
      );
      
      // Allow widget to build
      await tester.pumpAndSettle();
      
      // Verify error UI
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load widget status: Exception: Test error on getWidgetStatus'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(WidgetPreviewCard), findsNothing);
    });

    testWidgets('should retry loading when retry button is pressed', (WidgetTester tester) async {
      // Setup initial error
      when(mockController.getWidgetStatus())
          .thenThrow(Exception('Test error on getWidgetStatus'));
      
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: WidgetManagerScreen(),
        ),
      );
      
      // Allow widget to build and show error
      await tester.pumpAndSettle();
      
      // Verify error UI
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // Change mock to return success on next call with a Completer for control
      final completer = Completer<WidgetInstallationStatus>();
      when(mockController.getWidgetStatus()).thenAnswer((_) => completer.future);
      
      // Press retry button
      await tester.tap(find.text('Retry'));
      
      // Rebuild widget to start loading
      await tester.pump();
      
      // Verify we're in loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Complete the future with a value
      completer.complete(initialStatus);
      
      // Allow loading to complete
      await tester.pumpAndSettle();
      
      // Verify UI is now showing widgets
      expect(find.byType(WidgetPreviewCard), findsAtLeastNWidgets(1));
      expect(find.text('Failed to load widget status'), findsNothing);
    });

    testWidgets('should refresh when pull-to-refresh is triggered', (WidgetTester tester) async {
      // Setup initial state
      when(mockController.getWidgetStatus()).thenAnswer((_) async => initialStatus);
      
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: WidgetManagerScreen(),
        ),
      );
      
      // Allow initial load to complete
      await tester.pumpAndSettle();
      
      // Change status for next refresh
      when(mockController.getWidgetStatus()).thenAnswer((_) async => bothInstalledStatus);
      
      // Trigger pull-to-refresh
      await tester.drag(find.text('Add these widgets to your home screen for quick access to your nutrition tracking data.'), const Offset(0, 300));
      await tester.pump(); // Start the refresh
      
      // Allow refresh to complete
      await tester.pumpAndSettle();
      
      // Verify getWidgetStatus was called again
      verify(mockController.getWidgetStatus()).called(2);
    });

    testWidgets('should update UI when status stream emits new status', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: WidgetManagerScreen(),
        ),
      );
      
      // Allow initial load to complete
      await tester.pumpAndSettle();
      
      // Emit new status through stream
      statusStreamController.add(bothInstalledStatus);
      
      // Allow UI to update
      await tester.pumpAndSettle();
      
      // Verify UI updated with new status
      expect(find.byType(WidgetPreviewCard), findsNWidgets(2));
    });

    testWidgets('should refresh when refresh button is pressed', (WidgetTester tester) async {
      // Setup initial state
      when(mockController.getWidgetStatus()).thenAnswer((_) async => initialStatus);
      
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: WidgetManagerScreen(),
        ),
      );
      
      // Allow initial load to complete
      await tester.pumpAndSettle();
      
      // Change status for next refresh
      when(mockController.getWidgetStatus()).thenAnswer((_) async => bothInstalledStatus);
      
      // Press refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump(); // Start the refresh
      
      // Allow refresh to complete
      await tester.pumpAndSettle();
      
      // Verify getWidgetStatus was called again
      verify(mockController.getWidgetStatus()).called(2);
    });

    testWidgets('should show snackbar when install throws error', (WidgetTester tester) async {
      // Setup initial state
      when(mockController.getWidgetStatus()).thenAnswer((_) async => initialStatus);
      
      // Setup error on install
      when(mockController.installWidget(any)).thenThrow(
        Exception('Test error on installWidget'),
      );
      
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WidgetManagerScreen(),
          ),
        ),
      );
      
      // Allow initial load to complete
      await tester.pumpAndSettle();
      
      // Find and tap install button on first card
      await tester.tap(find.byType(ElevatedButton).first);
      
      // Allow UI to update
      await tester.pumpAndSettle();
      
      // Verify error snackbar
      expect(find.text('Error installing widget: Exception: Test error on installWidget'), findsOneWidget);
    });
  });
}
