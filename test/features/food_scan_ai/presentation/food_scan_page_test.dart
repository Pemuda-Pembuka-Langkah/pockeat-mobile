import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/food_scan_ai/presentation/pages/food_scan_page.dart';
import 'package:pockeat/features/food_scan_ai/presentation/pages/nutrition_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'dart:io';


class MockCameraController extends Mock implements CameraController {}

class MockXFile extends Mock implements XFile {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoute extends Mock implements Route<dynamic> {}

class MockFoodScanPhotoService extends Mock implements FoodScanPhotoService {}

class MockFile extends Mock implements File {}

void main() {
  late Widget scanFoodPage;
  late MockCameraController mockCameraController;
  late MockNavigatorObserver mockNavigatorObserver;
  late MockFoodScanPhotoService mockFoodScanPhotoService;

  setUpAll(() {
    mockCameraController = MockCameraController();
    mockNavigatorObserver = MockNavigatorObserver();
    mockFoodScanPhotoService = MockFoodScanPhotoService();
    registerFallbackValue(MockCameraController());
    registerFallbackValue(MockRoute());
    registerFallbackValue(MockXFile());
    registerFallbackValue(MockFile());
    registerFallbackValue(File(''));

    // Daftarkan mock service ke GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<FoodScanPhotoService>()) {
      getIt.unregister<FoodScanPhotoService>();
    }
    getIt.registerSingleton<FoodScanPhotoService>(mockFoodScanPhotoService);

    // Berikan mock controller ke ScanFoodPage
    scanFoodPage = MaterialApp(
      home: ScanFoodPage(
        cameraController: mockCameraController,
      ),
      navigatorObservers: [mockNavigatorObserver],
    );
  });

  tearDownAll(() {
    // Bersihkan GetIt setelah semua test selesai
    final getIt = GetIt.instance;
    if (getIt.isRegistered<FoodScanPhotoService>()) {
      getIt.unregister<FoodScanPhotoService>();
    }
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
    
    // Mock FoodScanPhotoService response
    when(() => mockFoodScanPhotoService.analyzeFoodPhoto(any())).thenAnswer(
      (_) async => FoodAnalysisResult(
        foodName: 'Test Food',
        nutritionInfo: NutritionInfo(
          calories: 100,
          protein: 10,
          carbs: 20,
          fat: 5,
          fiber: 3,
          sugar: 2,
          sodium: 100,
        ),
        warnings: [],
        ingredients: [],
      ),
    );

    await tester.pumpWidget(scanFoodPage);

    clearInteractions(mockNavigatorObserver);

    // Act - Tap the capture button
    await tester.tap(find.byKey(const Key('camera_button')));
    await tester.pumpAndSettle();

    // Assert
    // Verify that takePicture was called
    verify(() => mockCameraController.takePicture()).called(1);

    // Verifikasi navigasi
    verify(() => mockNavigatorObserver.didReplace(
          oldRoute: any(named: 'oldRoute'),
          newRoute: any(named: 'newRoute'),
        )).called(1);

    // Verify we're on NutritionPage with correct image path
    final nutritionPageFinder = find.byType(NutritionPage);
    expect(nutritionPageFinder, findsOneWidget);

    final NutritionPage nutritionPage = tester.widget(nutritionPageFinder);
    expect(nutritionPage.imagePath, 'test/path/image.jpg');
  });
  
  testWidgets('Mode buttons should render correctly with initial state',
      (WidgetTester tester) async {
    scanFoodPage = MaterialApp(
      home: ScanFoodPage(
        cameraController: mockCameraController,
      ),
      navigatorObservers: [mockNavigatorObserver],
    );

    await tester.pumpWidget(scanFoodPage);

    // Find mode buttons
    final scanButton = find.byKey(const Key('mode_button_0'));
    final tagFoodButton = find.byKey(const Key('mode_button_1'));
    final helpButton = find.byKey(const Key('mode_button_2'));

    // Verify all buttons exist
    expect(scanButton, findsOneWidget);
    expect(tagFoodButton, findsOneWidget);
    expect(helpButton, findsOneWidget);

    // Verify initial selected state (Scan mode should be selected by default)
    final scanContainer = tester.widget<Container>(
      find.descendant(
        of: scanButton,
        matching: find.byType(Container),
      ),
    );
    final tagFoodContainer = tester.widget<Container>(
      find.descendant(
        of: tagFoodButton,
        matching: find.byType(Container),
      ),
    );

    // Check decoration of selected button (Scan)
    final scanDecoration = scanContainer.decoration as BoxDecoration;
    expect(scanDecoration.color, const Color(0xFF4ECDC4)); // primaryGreen

    // Check decoration of unselected button (Tag Food)
    final tagDecoration = tagFoodContainer.decoration as BoxDecoration;
    expect(tagDecoration.color, Colors.black.withOpacity(0.5));

    // Verify text styles
    final scanText = tester.widget<Text>(find.text('Scan'));
    final tagFoodText = tester.widget<Text>(find.text('Tag Food'));

    expect(scanText.style?.color, Colors.white);
    expect(scanText.style?.fontWeight, FontWeight.w600);
    expect(tagFoodText.style?.color, Colors.white);
    expect(tagFoodText.style?.fontWeight, FontWeight.w600);
  });

  testWidgets('Mode buttons should change state when tapped',
      (WidgetTester tester) async {
    scanFoodPage = MaterialApp(
      home: ScanFoodPage(
        cameraController: mockCameraController,
      ),
      navigatorObservers: [mockNavigatorObserver],
    );

    await tester.pumpWidget(scanFoodPage);

    // Initial state check
    Container getButtonContainer(String text) {
      return tester.widget<Container>(
        find.ancestor(
          of: find.text(text),
          matching: find.byType(Container),
        ),
      );
    }

    // Verify initial state (Scan selected)
    expect(
      (getButtonContainer('Scan').decoration as BoxDecoration).color,
      const Color(0xFF4ECDC4),
    );

    // Tap Tag Food button
    await tester.tap(find.text('Tag Food'));
    await tester.pump();

    // Verify Tag Food is now selected
    expect(
      (getButtonContainer('Tag Food').decoration as BoxDecoration).color,
      const Color(0xFF4ECDC4),
    );
    expect(
      (getButtonContainer('Scan').decoration as BoxDecoration).color,
      Colors.black.withOpacity(0.5),
    );

    // Tap Help button
    await tester.tap(find.text('Help'));
    await tester.pump();

    // Verify Help is now selected
    expect(
      (getButtonContainer('Help').decoration as BoxDecoration).color,
      const Color(0xFF4ECDC4),
    );
    expect(
      (getButtonContainer('Tag Food').decoration as BoxDecoration).color,
      Colors.black.withOpacity(0.5),
    );
  });

  testWidgets('Mode buttons should have correct layout and styling',
      (WidgetTester tester) async {
    scanFoodPage = MaterialApp(
      home: ScanFoodPage(
        cameraController: mockCameraController,
      ),
      navigatorObservers: [mockNavigatorObserver],
    );

    await tester.pumpWidget(scanFoodPage);

    // Test container padding
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const Key('mode_button_0')),
        matching: find.byType(Container),
      ),
    );

    expect(
      container.padding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );

    // Test border radius
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(20));

    // Test text style consistency across all buttons
    for (final buttonText in ['Scan', 'Tag Food', 'Help']) {
      final text = tester.widget<Text>(find.text(buttonText));
      expect(text.style?.color, Colors.white);
      expect(text.style?.fontWeight, FontWeight.w600);
    }
  });


    testWidgets('Close button should pop navigation when tapped', 
      (WidgetTester tester) async {
    scanFoodPage = MaterialApp(
      home: ScanFoodPage(
        cameraController: mockCameraController,
      ),
      navigatorObservers: [mockNavigatorObserver],
    );

    await tester.pumpWidget(scanFoodPage);

    // Tap the close button
    await tester.tap(find.byIcon(CupertinoIcons.xmark));
    await tester.pumpAndSettle();
    // Verify navigation pop was called
    verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
  });
}
