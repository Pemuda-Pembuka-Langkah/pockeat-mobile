// // Dart imports:
// import 'dart:io';

// // Flutter imports:
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// // Package imports:
// import 'package:camera/camera.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get_it/get_it.dart';
// import 'package:mocktail/mocktail.dart';

// // Project imports:
// import 'package:pockeat/features/api_scan/models/food_analysis.dart';
// import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
// import 'package:pockeat/features/food_scan_ai/presentation/screens/food_scan_page.dart';
// import 'package:pockeat/features/food_scan_ai/presentation/screens/nutrition_page.dart';
// import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_photo_help_widget.dart';

// class MockCameraController extends Mock implements CameraController {
//   final _cameraValue = CameraValue(
//     isInitialized: true,
//     previewSize: const Size(1280, 720),
//     exposureMode: ExposureMode.auto,
//     focusMode: FocusMode.auto,
//     flashMode: FlashMode.off,
//     exposurePointSupported: false,
//     focusPointSupported: false,
//     deviceOrientation: DeviceOrientation.portraitUp,
//     isRecordingVideo: false,
//     isTakingPicture: false,
//     isStreamingImages: false,
//     isRecordingPaused: false,
//     description: const CameraDescription(
//       name: 'test',
//       lensDirection: CameraLensDirection.back,
//       sensorOrientation: 0,
//     ),
//   );

//   @override
//   Widget buildPreview() => const SizedBox(width: 1280, height: 720);

//   @override
//   CameraValue get value => _cameraValue;
// }

// class MockXFile extends Mock implements XFile {}

// class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// class MockRoute extends Mock implements Route<dynamic> {}

// class MockFoodScanPhotoService extends Mock implements FoodScanPhotoService {}

// class MockFile extends Mock implements File {}

// void main() {
//   late Widget scanFoodPage;
//   late MockCameraController mockCameraController;
//   late MockNavigatorObserver mockNavigatorObserver;
//   late MockFoodScanPhotoService mockFoodScanPhotoService;

//   setUpAll(() {
//     final getIt = GetIt.instance;

//     mockCameraController = MockCameraController();
//     mockNavigatorObserver = MockNavigatorObserver();
//     mockFoodScanPhotoService = MockFoodScanPhotoService();

//     // mockFoodScanPhotoService to getIt
//     getIt.registerSingleton<FoodScanPhotoService>(mockFoodScanPhotoService);

//     // Register fallback values
//     registerFallbackValue(const CameraDescription(
//       name: 'test',
//       lensDirection: CameraLensDirection.back,
//       sensorOrientation: 0,
//     ));
//     registerFallbackValue(FlashMode.off);
//     registerFallbackValue(MockXFile());
//     registerFallbackValue(File(''));
//     registerFallbackValue(MockRoute());
//   });

//   setUp(() {
//     // Reset mocks before each test
//     reset(mockCameraController);
//     reset(mockNavigatorObserver);
//     reset(mockFoodScanPhotoService);

//     // Setup basic mock behaviors
//     when(() => mockCameraController.initialize()).thenAnswer((_) async => {});
//     when(() => mockCameraController.setFlashMode(any()))
//         .thenAnswer((_) async => {});
//     when(() => mockCameraController.takePicture())
//         .thenAnswer((_) async => MockXFile());
//     when(() => mockCameraController.dispose()).thenAnswer((_) async => {});

//     // Create test widget
//     scanFoodPage = MaterialApp(
//       home: ScanFoodPage(
//         cameraController: mockCameraController,
//       ),
//       navigatorObservers: [mockNavigatorObserver],
//     );
//   });

//   testWidgets('Initial state variables are set correctly',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(scanFoodPage);

//     // Get the state
//     final state = tester.state<ScanFoodPageState>(find.byType(ScanFoodPage));

//     // Test initial values
//     expect(state.scanProgress, 0.0);
//     expect(state.statusMessage, 'Make sure your food is clearly visible');
//     expect(state.currentMode, 0);
//     expect(state.isCameraReady, true);
//   });

//   testWidgets('Color constants are defined correctly',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(scanFoodPage);

//     final state = tester.state<ScanFoodPageState>(find.byType(ScanFoodPage));

//     // Test color values
//     expect(state.primaryYellow, const Color(0xFFFFE893));
//     expect(state.primaryPink, const Color(0xFFFF6B6B));
//     expect(state.primaryGreen, const Color(0xFF4ECDC4));
//     expect(state.warningYellow, const Color(0xFFFFB946));
//     expect(state.alertRed, const Color(0xFFFF4949));
//     expect(state.successGreen, const Color(0xFF4CD964));
//     expect(state.progressColor, const Color(0xFFFF4949));
//   });

//   testWidgets('Initial UI elements render correctly',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(scanFoodPage);

//     expect(find.text('Food'), findsOneWidget);
//     expect(find.text('Label'), findsOneWidget);
//   });

//   testWidgets('Camera initialization works correctly',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(scanFoodPage);

//     // Tunggu frame berikutnya
//     await tester.pump();

//     // Verifikasi initialize dipanggil
//     verify(() => mockCameraController.initialize()).called(1);
//   });

//   testWidgets('Take picture and navigate to NutritionPage',
//       (WidgetTester tester) async {
//     // Arrange
//     final mockImage = MockXFile();
//     when(() => mockImage.path).thenReturn('test/path/image.jpg');
//     when(() => mockCameraController.takePicture())
//         .thenAnswer((_) async => mockImage);

//     // Mock FoodScanPhotoService response
//     when(() => mockFoodScanPhotoService.analyzeFoodPhoto(any())).thenAnswer(
//       (_) async => FoodAnalysisResult(
//         foodName: 'Test Food',
//         nutritionInfo: NutritionInfo(
//           calories: 100,
//           protein: 10,
//           carbs: 20,
//           fat: 5,
//           fiber: 3,
//           sugar: 2,
//           sodium: 100,
//         ),
//         warnings: [],
//         ingredients: [],
//       ),
//     );

//     await tester.pumpWidget(scanFoodPage);

//     clearInteractions(mockNavigatorObserver);

//     // Act - Tap the capture button
//     await tester.tap(find.byKey(const Key('camera_button')));
//     await tester.pumpAndSettle();

//     // Assert
//     // Verify that takePicture was called
//     verify(() => mockCameraController.takePicture()).called(1);

//     // Verifikasi navigasi
//     verify(() => mockNavigatorObserver.didReplace(
//           oldRoute: any(named: 'oldRoute'),
//           newRoute: any(named: 'newRoute'),
//         )).called(1);

//     // Verify we're on NutritionPage with correct image path
//     final nutritionPageFinder = find.byType(NutritionPage);
//     expect(nutritionPageFinder, findsOneWidget);

//     final NutritionPage nutritionPage = tester.widget(nutritionPageFinder);
//     expect(nutritionPage.imagePath, 'test/path/image.jpg');
//   });

//   testWidgets('Mode buttons should render correctly with initial state',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(scanFoodPage);

//     // Find mode buttons
//     final scanButton = find.byKey(const Key('mode_button_0'));

//     // Verify all buttons exist
//     expect(scanButton, findsOneWidget);

//     // Verify initial selected state (Scan mode should be selected by default)
//     final scanContainer = tester.widget<Container>(
//       find.descendant(
//         of: scanButton,
//         matching: find.byType(Container),
//       ),
//     );

//     // Check decoration of selected button (Scan)
//     final scanDecoration = scanContainer.decoration as BoxDecoration;
//     expect(scanDecoration.color, const Color(0xFF4ECDC4)); // primaryGreen
//     // Verify text styles
//     final scanText = tester.widget<Text>(find.text('Food'));

//     expect(scanText.style?.color, Colors.white);
//     expect(scanText.style?.fontWeight, FontWeight.w600);
//   });

//   testWidgets('Mode buttons should have correct layout and styling',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(scanFoodPage);

//     // Test container padding
//     final container = tester.widget<Container>(
//       find.descendant(
//         of: find.byKey(const Key('mode_button_0')),
//         matching: find.byType(Container),
//       ),
//     );

//     expect(
//       container.padding,
//       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     );

//     // Test border radius
//     final decoration = container.decoration as BoxDecoration;
//     expect(decoration.borderRadius, BorderRadius.circular(20));

//     // Test text style consistency for Scan button
//     final text = tester.widget<Text>(find.text('Food'));
//     expect(text.style?.color, Colors.white);
//     expect(text.style?.fontWeight, FontWeight.w600);
//   });

//   testWidgets('Close button should pop navigation when tapped',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(scanFoodPage);

//     // Tap the close button
//     await tester.tap(find.byIcon(CupertinoIcons.xmark));
//     await tester.pumpAndSettle();

//     // Verify navigation pop was called
//     verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
//   });

//   testWidgets('Dialog should appear when taking picture in label scan mode',
//       (WidgetTester tester) async {
//     // Arrange
//     final mockImage = MockXFile();
//     when(() => mockImage.path).thenReturn('test/path/image.jpg');
//     when(() => mockCameraController.takePicture())
//         .thenAnswer((_) async => mockImage);

//     await tester.pumpWidget(scanFoodPage);
//     // Tunggu inisialisasi kamera
//     await tester.pump(const Duration(milliseconds: 100));

//     // Ubah ke mode label scan
//     await tester.tap(find.byKey(const Key('mode_button_1')));
//     // Tunggu state update
//     await tester.pump();

//     // Ambil gambar
//     await tester.tap(find.byKey(const Key('camera_button')));
//     // Tunggu dialog muncul
//     await tester.pump(const Duration(milliseconds: 300));

//     // Assert
//     expect(find.text('Serving Size'), findsOneWidget);
//     expect(find.text('Berapa serving size yang Anda makan?'), findsOneWidget);
//   });

//   // Tambahkan test untuk interaksi dengan dialog
//   testWidgets('Dialog should handle serving size input correctly',
//       (WidgetTester tester) async {
//     // Arrange
//     final mockImage = MockXFile();
//     when(() => mockImage.path).thenReturn('test/path/image.jpg');
//     when(() => mockCameraController.takePicture())
//         .thenAnswer((_) async => mockImage);

//     await tester.pumpWidget(scanFoodPage);
//     await tester.pump(const Duration(milliseconds: 100));

//     // Ubah ke mode label scan
//     await tester.tap(find.byKey(const Key('mode_button_1')));
//     await tester.pump();

//     // Buka dialog
//     await tester.tap(find.byKey(const Key('camera_button')));
//     await tester.pump(const Duration(milliseconds: 300));

//     // Input serving size
//     await tester.enterText(find.byType(TextField), '2.5');
//     await tester.pump();

//     // Tekan tombol konfirmasi
//     await tester.tap(find.text('Konfirmasi'));
//     await tester.pumpAndSettle();

//     // Verify navigation to NutritionPage
//     final nutritionPageFinder = find.byType(NutritionPage);
//     expect(nutritionPageFinder, findsOneWidget);

//     final NutritionPage nutritionPage = tester.widget(nutritionPageFinder);
//     expect(nutritionPage.imagePath, 'test/path/image.jpg');
//     expect(nutritionPage.isLabelScan, isTrue);
//     expect(nutritionPage.servingSize, 2.5);
//   });

//   testWidgets('Dialog should handle invalid serving size input',
//       (WidgetTester tester) async {
//     // Arrange
//     final mockImage = MockXFile();
//     when(() => mockImage.path).thenReturn('test/path/image.jpg');
//     when(() => mockCameraController.takePicture())
//         .thenAnswer((_) async => mockImage);

//     await tester.pumpWidget(scanFoodPage);
//     await tester.pump(const Duration(milliseconds: 100));

//     // Ubah ke mode label scan
//     await tester.tap(find.byKey(const Key('mode_button_1')));
//     await tester.pump();

//     // Buka dialog
//     await tester.tap(find.byKey(const Key('camera_button')));
//     await tester.pump(const Duration(milliseconds: 300));

//     // Input invalid serving size
//     await tester.enterText(find.byType(TextField), '-1');
//     await tester.pump();

//     // Verify error message
//     expect(find.text('Mohon masukkan angka positif'), findsOneWidget);
//   });

//   testWidgets('FoodPhotoHelpWidget renders correctly',
//       (WidgetTester tester) async {
//     // Arrange
//     final widget = MaterialApp(
//       home: Scaffold(
//         body: Builder(
//           builder: (context) => TextButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => FoodPhotoHelpWidget(
//                   primaryColor: const Color(0xFF4ECDC4),
//                 ),
//               );
//             },
//             child: const Text('Show Help'),
//           ),
//         ),
//       ),
//     );

//     // Act
//     await tester.pumpWidget(widget);
//     await tester.tap(find.text('Show Help'));
//     await tester.pumpAndSettle();

//     // Assert
//     // Check dialog title
//     expect(find.text('How to Take a Good Food Photo'), findsOneWidget);

//     // Check all tip items are present
//     expect(find.text('Good Lighting'), findsOneWidget);
//     expect(find.text('Center Your Food'), findsOneWidget);
//     expect(find.text('Appropriate Distance'), findsOneWidget);
//     expect(find.text('Steady Hand'), findsOneWidget);
//     expect(find.text('Avoid Reflections'), findsOneWidget);

//     // Check descriptions
//     expect(
//         find.text('Try to take photos in natural light. Avoid harsh shadows.'),
//         findsOneWidget);
//     expect(
//         find.text('Keep the food inside the scanning frame.'), findsOneWidget);
//     expect(find.text('Not too close, not too far. 8-12 inches is ideal.'),
//         findsOneWidget);
//     expect(find.text('Hold your phone steady to avoid blur.'), findsOneWidget);
//     expect(find.text('Avoid glare from shiny surfaces or packaging.'),
//         findsOneWidget);

//     // Check button exists
//     expect(find.text('Got it!'), findsOneWidget);
//   });

//   testWidgets('FoodPhotoHelpWidget dismisses when button is tapped',
//       (WidgetTester tester) async {
//     // Arrange
//     when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);

//     final widget = MaterialApp(
//       home: Scaffold(
//         body: Builder(
//           builder: (context) => TextButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => FoodPhotoHelpWidget(
//                   primaryColor: const Color(0xFF4ECDC4),
//                 ),
//               );
//             },
//             child: const Text('Show Help'),
//           ),
//         ),
//       ),
//       navigatorObservers: [mockNavigatorObserver],
//     );

//     // Act
//     await tester.pumpWidget(widget);
//     await tester.tap(find.text('Show Help'));
//     await tester.pumpAndSettle();

//     // Reset observer to clear previous calls
//     clearInteractions(mockNavigatorObserver);

//     // Tap the "Got it!" button
//     await tester.tap(find.text('Got it!'));
//     await tester.pumpAndSettle();

//     // Assert
//     // Verify dialog is closed
//     expect(find.text('How to Take a Good Food Photo'), findsNothing);
//     verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
//   });

//   testWidgets('FoodPhotoHelpWidget displays with correct styling',
//       (WidgetTester tester) async {
//     // Arrange
//     const primaryColor = Color(0xFF4ECDC4);

//     final widget = MaterialApp(
//       home: Scaffold(
//         body: Builder(
//           builder: (context) => TextButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => const FoodPhotoHelpWidget(
//                   primaryColor: primaryColor,
//                 ),
//               );
//             },
//             child: const Text('Show Help'),
//           ),
//         ),
//       ),
//     );

//     // Act
//     await tester.pumpWidget(widget);
//     await tester.tap(find.text('Show Help'));
//     await tester.pumpAndSettle();

//     // Assert
//     // Check title has correct style
//     final titleText =
//         tester.widget<Text>(find.text('How to Take a Good Food Photo'));
//     expect(titleText.style?.color, primaryColor);
//     expect(titleText.style?.fontWeight, FontWeight.bold);
//     expect(titleText.style?.fontSize, 18.0);

//     // Check icons have correct color
//     final icons = tester.widgetList<Icon>(find.byType(Icon));
//     for (final icon in icons) {
//       expect(icon.color, primaryColor);
//     }

//     // Check button styling
//     final button = tester.widget<TextButton>(find.byType(TextButton).last);
//     final buttonStyle = button.style as ButtonStyle;

//     // Extract background color
//     final backgroundColor = buttonStyle.backgroundColor?.resolve({});
//     expect(backgroundColor, primaryColor);

//     // Check button text style
//     final buttonText = tester.widget<Text>(find.text('Got it!'));
//     expect(buttonText.style?.color, Colors.white);
//     expect(buttonText.style?.fontWeight, FontWeight.bold);
//   });

//   testWidgets('Help button shows FoodPhotoHelpWidget when tapped',
//       (WidgetTester tester) async {
//     // Arrange - Pump the widget to test
//     await tester.pumpWidget(scanFoodPage);

//     // Find the help button using the key you've defined
//     final helpButtonFinder = find.byKey(const Key('help_button'));
//     expect(helpButtonFinder, findsOneWidget);

//     // Act - Tap the help button
//     await tester.tap(helpButtonFinder);

//     // Pump a few frames to allow the dialog to start showing, but don't wait indefinitely
//     await tester.pump(); // Schedule the animation
//     await tester.pump(const Duration(milliseconds: 100)); // Pump one frame

//     // Assert - Check if the FoodPhotoHelpWidget is shown
//     expect(find.byType(FoodPhotoHelpWidget), findsOneWidget);

//     // Verify the title appears in the widget
//     expect(find.text('How to Take a Good Food Photo'), findsOneWidget);

//     // Verify the dialog has the correct primary color
//     final helpWidget =
//         tester.widget<FoodPhotoHelpWidget>(find.byType(FoodPhotoHelpWidget));
//     final state = tester.state<ScanFoodPageState>(find.byType(ScanFoodPage));
//     expect(helpWidget.primaryColor, state.primaryGreen);
//   });

//   testWidgets('Help button has correct styling and icon',
//       (WidgetTester tester) async {
//     // Arrange
//     await tester.pumpWidget(scanFoodPage);

//     // Find the help button
//     final helpButtonFinder = find.byKey(const Key('help_button'));

//     // Find the Container that wraps the Icon
//     final containerFinder = find.descendant(
//       of: helpButtonFinder,
//       matching: find.byType(Container),
//     );

//     // Get the Container widget
//     final container = tester.widget<Container>(containerFinder);

//     // Verify container styling
//     final decoration = container.decoration as BoxDecoration;
//     expect(decoration.color, Colors.black.withOpacity(0.5));
//     expect(decoration.shape, BoxShape.circle);

//     // Find and verify the icon
//     final iconFinder = find.descendant(
//       of: helpButtonFinder,
//       matching: find.byType(Icon),
//     );

//     final icon = tester.widget<Icon>(iconFinder);
//     expect(icon.icon, Icons.help_outline);
//     expect(icon.color, Colors.white);
//     expect(icon.size, 20);
//   });

// // Add this test to directly test the _showHelpDialog method
//   testWidgets('_showHelpDialog method shows dialog with correct content',
//       (WidgetTester tester) async {
//     // Create a simple test widget that will call the showDialog method
//     final testWidget = MaterialApp(
//       home: Builder(
//         builder: (BuildContext context) {
//           return Scaffold(
//             body: Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return FoodPhotoHelpWidget(
//                           primaryColor: const Color(0xFF4ECDC4));
//                     },
//                   );
//                 },
//                 child: const Text('Show Dialog'),
//               ),
//             ),
//           );
//         },
//       ),
//     );

//     await tester.pumpWidget(testWidget);

//     // Tap the button to show the dialog
//     await tester.tap(find.text('Show Dialog'));
//     await tester.pump();
//     await tester.pump(const Duration(milliseconds: 100));

//     // Verify the dialog appears with correct content
//     expect(find.byType(FoodPhotoHelpWidget), findsOneWidget);
//     expect(find.text('How to Take a Good Food Photo'), findsOneWidget);

//     // Check for all tip items
//     expect(find.text('Good Lighting'), findsOneWidget);
//     expect(find.text('Center Your Food'), findsOneWidget);
//     expect(find.text('Appropriate Distance'), findsOneWidget);
//     expect(find.text('Steady Hand'), findsOneWidget);
//     expect(find.text('Avoid Reflections'), findsOneWidget);
//   });

//   testWidgets('FoodPhotoHelpWidget closes when "Got it!" button is tapped',
//       (WidgetTester tester) async {
//     // Create a simpler test that doesn't rely on navigation observers
//     final testWidget = MaterialApp(
//       home: Builder(
//         builder: (BuildContext context) {
//           return Scaffold(
//             body: Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext dialogContext) {
//                       return FoodPhotoHelpWidget(
//                         primaryColor: const Color(0xFF4ECDC4), // primaryGreen
//                       );
//                     },
//                   );
//                 },
//                 child: const Text('Show Help'),
//               ),
//             ),
//           );
//         },
//       ),
//     );

//     await tester.pumpWidget(testWidget);

//     // Act - Show the dialog
//     await tester.tap(find.text('Show Help'));
//     await tester.pump();
//     await tester.pump(const Duration(milliseconds: 100));

//     // Verify dialog is shown
//     expect(find.byType(FoodPhotoHelpWidget), findsOneWidget);
//     expect(find.text('Got it!'), findsOneWidget);

//     // Tap the "Got it!" button
//     await tester.tap(find.text('Got it!'));

//     // Need to pump multiple times to complete the dialog dismissal animation
//     await tester.pump(); // Start the dismiss animation
//     await tester
//         .pump(const Duration(milliseconds: 300)); // Animation in progress
//     await tester
//         .pump(const Duration(seconds: 1)); // Animation should be complete

//     // Assert - Dialog should be closed
//     expect(find.byType(Dialog), findsNothing);
//     // Instead of checking for FoodPhotoHelpWidget directly, check for Dialog
//     // or text that should be gone
//     expect(find.text('How to Take a Good Food Photo'), findsNothing);
//   });
// }
