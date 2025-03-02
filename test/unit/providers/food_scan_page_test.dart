import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/food_scan_ai/presentation/food_scan_page.dart';
import 'package:camera/camera.dart';

class MockCameraController extends Mock implements CameraController {}

void main() {
  late Widget scanFoodPage;
  late MockCameraController mockCameraController;

  group('Food Scan Page', () {
    setUpAll(() {
      // Inisialisasi mock controller
      mockCameraController = MockCameraController();
      registerFallbackValue(MockCameraController());

      // Berikan mock controller ke ScanFoodPage
      scanFoodPage = MaterialApp(
        home: ScanFoodPage(
          cameraController: mockCameraController,
        ),
      );
    });

    testWidgets('Initial UI elements render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(scanFoodPage);

      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Tag Food'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
    });

    testWidgets('Camera initialization works correctly',
        (WidgetTester tester) async {
      when(() => mockCameraController.initialize()).thenAnswer((_) async => {});
      when(() => mockCameraController.value).thenReturn(CameraValue(
        isInitialized: false,
        previewSize: null,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        flashMode: FlashMode.auto,
        exposurePointSupported: false,
        focusPointSupported: false,
        deviceOrientation: DeviceOrientation.portraitUp,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        isRecordingPaused: false,
        description: CameraDescription(
          name: 'test',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
      ));

      await tester.pumpWidget(scanFoodPage);

      // Tunggu frame berikutnya
      await tester.pump();

      // Verifikasi initialize dipanggil
      verify(() => mockCameraController.initialize()).called(2);

      // Verifikasi loading indicator tidak ada karena kamera sudah terinisialisasi
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}