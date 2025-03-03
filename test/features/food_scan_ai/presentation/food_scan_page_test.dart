import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/food_scan_ai/presentation/food_scan_page.dart';
import 'package:pockeat/features/food_scan_ai/presentation/nutrition_page.dart';
import 'package:camera/camera.dart';

class MockCameraController extends Mock implements CameraController {}

class MockXFile extends Mock implements XFile {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoute extends Mock implements Route<dynamic> {}

void main() {
  late Widget scanFoodPage;
  late MockCameraController mockCameraController;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    mockCameraController = MockCameraController();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(MockCameraController());
    registerFallbackValue(MockRoute());

    // Berikan mock controller ke ScanFoodPage
    scanFoodPage = MaterialApp(
      home: ScanFoodPage(
        cameraController: mockCameraController,
      ),
      navigatorObservers: [mockNavigatorObserver],
    );
  });

  testWidgets('Initial state variables are set correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(scanFoodPage);

    // Get the state
    final state = tester.state<ScanFoodPageState>(find.byType(ScanFoodPage));

    // Test initial values
    expect(state.scanProgress, 0.0);
    expect(state.statusMessage, 'Make sure your food is clearly visible');
    expect(state.currentMode, 0);
    expect(state.isCameraReady, false);
    expect(state.isFoodPositioned, false);
  });

  testWidgets('Color constants are defined correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(scanFoodPage);

    final state = tester.state<ScanFoodPageState>(find.byType(ScanFoodPage));

    // Test color values
    expect(state.primaryYellow, const Color(0xFFFFE893));
    expect(state.primaryPink, const Color(0xFFFF6B6B));
    expect(state.primaryGreen, const Color(0xFF4ECDC4));
    expect(state.warningYellow, const Color(0xFFFFB946));
    expect(state.alertRed, const Color(0xFFFF4949));
    expect(state.successGreen, const Color(0xFF4CD964));
    expect(state.progressColor, const Color(0xFFFF4949));
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
    verify(() => mockCameraController.initialize()).called(4);

    // Verifikasi loading indicator tidak ada karena kamera sudah terinisialisasi
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Take picture and navigate to NutritionPage',
      (WidgetTester tester) async {
    // Arrange
    final mockImage = MockXFile();
    when(() => mockImage.path).thenReturn('test/path/image.jpg');
    when(() => mockCameraController.takePicture())
        .thenAnswer((_) async => mockImage);

    await tester.pumpWidget(scanFoodPage);

    // Act - Tap the capture button
    await tester.tap(find.byKey(const Key('camera_button')));
    await tester.pumpAndSettle();

    // Assert
    // Verify that takePicture was called
    verify(() => mockCameraController.takePicture()).called(1);

    // Verify navigation to NutritionPage
    verify(() => mockNavigatorObserver.didPush(any(), any())).called(5);

    // Verify we're on NutritionPage with correct image path
    final nutritionPageFinder = find.byType(NutritionPage);
    expect(nutritionPageFinder, findsOneWidget);

    final NutritionPage nutritionPage = tester.widget(nutritionPageFinder);
    expect(nutritionPage.imagePath, 'test/path/image.jpg');
  });
}
