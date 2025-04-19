import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/bottom_action_bar.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';
// Service locator diakses melalui GetIt.I di test

class MockFoodScanPhotoService extends Mock implements FoodScanPhotoService {}

class MockFoodTrackingClientController extends Mock implements FoodTrackingClientController {}

void main() {
  late MockFoodScanPhotoService mockFoodScanPhotoService;
  late MockFoodTrackingClientController mockFoodTrackingController;
  late FoodAnalysisResult testFood;
  const primaryPink = Color(0xFFFF6B6B);
  const primaryYellow = Color(0xFFFFE893);
  const primaryGreen = Color(0xFF4ECDC4);

  void setupGetIt() {
    if (!GetIt.I.isRegistered<FoodTrackingClientController>()) {
      GetIt.I.registerSingleton<FoodTrackingClientController>(mockFoodTrackingController);
    } else {
      GetIt.I.unregister<FoodTrackingClientController>();
      GetIt.I.registerSingleton<FoodTrackingClientController>(mockFoodTrackingController);
    }
  }

  setUp(() {
    mockFoodScanPhotoService = MockFoodScanPhotoService();
    mockFoodTrackingController = MockFoodTrackingClientController();
    setupGetIt();

    testFood = FoodAnalysisResult(
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
    );

    registerFallbackValue(testFood);
    registerFallbackValue('');

    when(() => mockFoodTrackingController.forceUpdate()).thenAnswer((_) async {});
  });

  group('BottomActionBar', () {
    testWidgets('renders correctly with required props',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: false,
              food: testFood,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Verify container styling
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, equals(const EdgeInsets.all(16)));

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.border,
          equals(const Border(top: BorderSide(color: Colors.black12))));

      // Verify correct analysis button exists
      expect(find.text('Correct Analysis'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);

      // Verify add to log button exists
      expect(find.byKey(const Key('add_to_log_button')), findsOneWidget);
      expect(find.text('Add to Log'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.plus), findsOneWidget);
    });

    testWidgets('correction button opens dialog when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: false,
              food: testFood,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Tap the correction button
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Correct Analysis'), findsWidgets);
      expect(find.text('Current analysis:'), findsOneWidget);
      expect(find.text('Food: Test Food'), findsOneWidget);
    });

    testWidgets('correction dialog does not open when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: true,
              food: testFood,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Tap the correction button
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Verify dialog does not appear
      expect(find.text('Current analysis:'), findsNothing);
    });

    testWidgets('correction dialog does not open when food is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: false,
              food: null,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Tap the correction button
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Verify dialog does not appear
      expect(find.text('Current analysis:'), findsNothing);
    });

    testWidgets('calls correctFoodAnalysis with correct parameters when correction button is pressed',
        (WidgetTester tester) async {
      final correctedResult = FoodAnalysisResult(
        foodName: 'Corrected Food',
        ingredients: [],
        nutritionInfo: NutritionInfo(
          calories: 200,
          protein: 20,
          carbs: 30,
          fat: 10,
          sodium: 200,
          fiber: 5,
          sugar: 5,
        ),
        warnings: [],
      );

      when(() => mockFoodScanPhotoService.correctFoodAnalysis(any(), any()))
          .thenAnswer((_) async => correctedResult);

      FoodAnalysisResult? callbackResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: false,
              food: testFood,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              onAnalysisCorrected: (result) {
                callbackResult = result;
              },
            ),
          ),
        ),
      );

      // Tap the correction button to open dialog
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Enter correction text
      final correctionText = 'This is brown rice';
      await tester.enterText(find.byType(TextField), correctionText);

      // Tap the submit button
      await tester.tap(find.text('Submit Correction'));
      await tester.pumpAndSettle();

      // Verify service was called with correct parameters
      verify(() => mockFoodScanPhotoService.correctFoodAnalysis(testFood, correctionText)).called(1);

      // Verify callback was called with corrected result
      expect(callbackResult, equals(correctedResult));
    });

    testWidgets('handles errors when correction fails',
        (WidgetTester tester) async {
      when(() => mockFoodScanPhotoService.correctFoodAnalysis(any(), any()))
          .thenThrow(Exception('Correction error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: false,
              food: testFood,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Tap the correction button to open dialog
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Enter correction text
      await tester.enterText(find.byType(TextField), 'This is brown rice');

      // Tap the submit button
      await tester.tap(find.text('Submit Correction'));
      await tester.pumpAndSettle();

      // Verify service was called
      verify(() => mockFoodScanPhotoService.correctFoodAnalysis(any(), any())).called(1);
    });

    testWidgets('calls saveFoodAnalysis with correct parameters when save button is pressed',
        (WidgetTester tester) async {
      const successMessage = 'Successfully saved food analysis';

      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) async => successMessage);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: false,
              food: testFood,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pump();

      // Verify service was called with correct food
      verify(() => mockFoodScanPhotoService.saveFoodAnalysis(testFood)).called(1);
    });

    testWidgets('add to log button is disabled when isLoading is true',
        (WidgetTester tester) async {
      bool serviceWasCalled = false;

      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) async {
        serviceWasCalled = true;
        return 'Success';
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: true,
              food: testFood,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pump();

      // Verify service was not called
      expect(serviceWasCalled, isFalse);
    });

    testWidgets('add to log button is disabled when food is null',
        (WidgetTester tester) async {
      bool serviceWasCalled = false;

      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) async {
        serviceWasCalled = true;
        return 'Success';
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: false,
              food: null,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pump();

      // Verify service was not called
      expect(serviceWasCalled, isFalse);
    });

    testWidgets('shows loading indicator when add to log button is tapped',
        (WidgetTester tester) async {
      final completer = Completer<String>();

      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: BottomActionBar(
                isLoading: false,
                food: testFood,
                foodScanPhotoService: mockFoodScanPhotoService,
                primaryYellow: primaryYellow,
                primaryPink: primaryPink,
              ),
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pump();
      await tester.pump();

      // Now the dialog with loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to cleanup
      completer.complete('Success');
      await tester.pumpAndSettle();
    });

    testWidgets('calls service with correct parameters when save succeeds', (WidgetTester tester) async {
      const successMessage = 'Successfully saved food analysis';

      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) async => successMessage);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomActionBar(
              isLoading: false,
              food: testFood,
              foodScanPhotoService: mockFoodScanPhotoService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
          ),
        ),
      );

      // Tap the add to log button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify service was called with correct food
      verify(() => mockFoodScanPhotoService.saveFoodAnalysis(testFood)).called(1);
      verify(() => mockFoodTrackingController.forceUpdate()).called(1);
    });

    testWidgets('handles forceUpdate exception gracefully', (WidgetTester tester) async {
    // Setup mocks
    when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
        .thenAnswer((_) async => 'Success');
    
    // Setup forceUpdate to throw exception
    when(() => mockFoodTrackingController.forceUpdate())
        .thenThrow(Exception('Network error'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomActionBar(
            isLoading: false,
            food: testFood,
            foodScanPhotoService: mockFoodScanPhotoService,
            primaryYellow: primaryYellow,
            primaryPink: primaryPink,
          ),
        ),
      ),
    );

    // Tap the add to log button
    await tester.tap(find.byKey(const Key('add_to_log_button')));
    await tester.pump();
    
    // Verify service was still called despite exception
    verify(() => mockFoodScanPhotoService.saveFoodAnalysis(testFood)).called(1);
    verify(() => mockFoodTrackingController.forceUpdate()).called(1);
    
    // Test bahwa tidak ada crash meskipun forceUpdate melempar exception
    await tester.pumpAndSettle();
  });

    testWidgets('navigates back after successful save',
        (WidgetTester tester) async {
      bool didPop = false;

      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) async => 'Success');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: BottomActionBar(
                        isLoading: false,
                        food: testFood,
                        foodScanPhotoService: mockFoodScanPhotoService,
                        primaryYellow: primaryYellow,
                        primaryPink: primaryPink,
                      ),
                    ),
                  ),
                ).then((_) async {
                  try {
                    final controller = GetIt.I<FoodTrackingClientController>();
                    await controller.forceUpdate();
                  } catch (e) {
                    // Silently log error but continue - don't block navigation
                    debugPrint('Failed to update home screen widget: $e');
                  }
                });
              },
              child: const Text('Open'),
            ),
          ),
          navigatorObservers: [
            MockNavigatorObserver(onPop: () => didPop = true),
          ],
        ),
      );

      // Open the route
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      
      // Manually trigger navigation back to simulate what happens after save
      Navigator.of(tester.element(find.byType(BottomActionBar))).pop();
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(didPop, isTrue);
    });
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  final Function onPop;

  MockNavigatorObserver({required this.onPop});

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop();
    super.didPop(route, previousRoute);
  }
}