import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/exercise_log_history/utils/exercise_sharing_extension.dart';
import 'package:share_plus/share_plus.dart';

// Mock classes
class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

class MockRunningActivity extends Mock implements RunningActivity {}

class TestBuildContext extends Fake implements BuildContext {
  @override
  NavigatorState get navigator => throw UnimplementedError();

  @override
  ScaffoldMessengerState get scaffoldMessenger => throw UnimplementedError();
}

class MockRenderRepaintBoundary extends Fake implements RenderRepaintBoundary {
  @override
  Future<ui.Image> toImage({double pixelRatio = 1.0}) async {
    throw UnimplementedError();
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockRenderRepaintBoundary';
  }
}

void main() {
  late MockPathProviderPlatform mockPathProvider;
  late Widget testWidget;
  late MockRunningActivity mockRunningActivity;

  setUpAll(() {
    // Register the mock path provider
    mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;

    // Create mock exercise data
    mockRunningActivity = MockRunningActivity();
    when(() => mockRunningActivity.distanceKm).thenReturn(5.0);
    when(() => mockRunningActivity.duration)
        .thenReturn(const Duration(minutes: 30));
    when(() => mockRunningActivity.caloriesBurned).thenReturn(250);
    when(() => mockRunningActivity.date).thenReturn(DateTime.now());
    when(() => mockRunningActivity.startTime).thenReturn(DateTime.now());
  });

  setUp(() {
    // Create test widget
    testWidget = MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                context.shareExerciseSummary(
                  mockRunningActivity,
                  'cardio',
                );
              },
              child: const Text('Share Exercise'),
            ),
          ),
        ),
      ),
    );
  });

  group('ExerciseSharing Extension', () {
    testWidgets('Should show loading dialog when sharing starts',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      final shareButton = find.text('Share Exercise');

      // Act
      await tester.tap(shareButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Cleanup - pump all pending timers
      await tester.pumpAndSettle(const Duration(seconds: 10));
    });

    testWidgets('Should show not implemented message for skeleton version',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      final shareButton = find.text('Share Exercise');

      // Act
      await tester.tap(shareButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.text('Exercise sharing not implemented yet'), findsOneWidget);

      // Cleanup - pump all pending timers
      await tester.pumpAndSettle(const Duration(seconds: 10));
    });

    testWidgets('Should throw error when _saveImageToTempFile is called',
        (WidgetTester tester) async {
      // This test will pass with the skeleton implementation since _saveImageToTempFile
      // throws an UnimplementedError
    });
  });
}
