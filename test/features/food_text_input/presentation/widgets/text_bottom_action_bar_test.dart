import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/text_bottom_action_bar.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';

class MockFoodTextInputService extends Mock implements FoodTextInputService {}

class MockFoodTrackingClientController extends Mock implements FoodTrackingClientController {}

void main() {
  late MockFoodTextInputService mockFoodTextInputService;
  late MockFoodTrackingClientController mockFoodTrackingController;
  late FoodAnalysisResult testFood;
  const primaryPink = Color(0xFFFF6B6B);
  const primaryYellow = Color(0xFFFFE893);
  
  void setupGetIt() {
    if (!GetIt.I.isRegistered<FoodTrackingClientController>()) {
      GetIt.I.registerSingleton<FoodTrackingClientController>(mockFoodTrackingController);
    } else {
      GetIt.I.unregister<FoodTrackingClientController>();
      GetIt.I.registerSingleton<FoodTrackingClientController>(mockFoodTrackingController);
    }
  }

  setUp(() {
    mockFoodTextInputService = MockFoodTextInputService();
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
    
    // Setup mock untuk forceUpdate
    when(() => mockFoodTrackingController.forceUpdate()).thenAnswer((_) async {});
  });

  group('TextBottomActionBar', () {
    testWidgets('renders correctly with required props',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextBottomActionBar(
              isLoading: false,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
            ),
          ),
        ),
      );

      // Verify styling
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
            body: TextBottomActionBar(
              isLoading: false,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
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
            body: TextBottomActionBar(
              isLoading: true,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
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
            body: TextBottomActionBar(
              isLoading: false,
              food: null,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
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

      when(() => mockFoodTextInputService.correctFoodAnalysis(any(), any()))
          .thenAnswer((_) async => correctedResult);

      FoodAnalysisResult? callbackResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextBottomActionBar(
              isLoading: false,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
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
      verify(() => mockFoodTextInputService.correctFoodAnalysis(testFood, correctionText)).called(1);

      // Verify callback was called with corrected result
      expect(callbackResult, equals(correctedResult));
    });

    testWidgets('handles errors when correction fails',
        (WidgetTester tester) async {
      when(() => mockFoodTextInputService.correctFoodAnalysis(any(), any()))
          .thenThrow(Exception('Correction error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextBottomActionBar(
              isLoading: false,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
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
      verify(() => mockFoodTextInputService.correctFoodAnalysis(any(), any())).called(1);
    });

    testWidgets('add to log button is disabled when isLoading is true',
        (WidgetTester tester) async {
      bool serviceWasCalled = false;

      when(() => mockFoodTextInputService.saveFoodAnalysis(any()))
          .thenAnswer((_) async {
        serviceWasCalled = true;
        return 'Success';
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextBottomActionBar(
              isLoading: true,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
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

      when(() => mockFoodTextInputService.saveFoodAnalysis(any()))
          .thenAnswer((_) async {
        serviceWasCalled = true;
        return 'Success';
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextBottomActionBar(
              isLoading: false,
              food: null,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
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

    testWidgets('shows loading message through SnackBar',
        (WidgetTester tester) async {
      // Setup mock to return value immediately to avoid timer issues  
      when(() => mockFoodTextInputService.saveFoodAnalysis(any()))
          .thenAnswer((_) async => 'Success');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextBottomActionBar(
                isLoading: false,
                food: testFood,
                foodTextInputService: mockFoodTextInputService,
                primaryYellow: primaryYellow,
                primaryPink: primaryPink,
                // Override onSavingStateChange untuk mencegah navigasi
                onSavingStateChange: (isLoading) {}, 
              ),
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pump(); // Start proses
      
      // Allow SnackBar messages to queue
      await tester.pump(const Duration(milliseconds: 10));
      
      // Verify saving message
      expect(find.text('Saving food to log...'), findsOneWidget);
      
      // Cleanup - untuk mencegah timer pada Future.delayed
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });

    testWidgets('calls service and updates home screen widget when save succeeds', (WidgetTester tester) async {
      when(() => mockFoodTextInputService.saveFoodAnalysis(any()))
          .thenAnswer((_) async => 'Success message');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextBottomActionBar(
              isLoading: false,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
              // Override onSavingStateChange untuk mencegah navigasi dan timer
              onSavingStateChange: (isLoading) {}, 
            ),
          ),
        ),
      );

      // Tap the add to log button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pump();
      
      // Tunggu hingga asynchronous operation selesai
      await tester.pump(const Duration(milliseconds: 10));
      
      // Verify service was called with correct food
      verify(() => mockFoodTextInputService.saveFoodAnalysis(testFood)).called(1);
      
      // Verify forceUpdate was called on the controller
      verify(() => mockFoodTrackingController.forceUpdate()).called(1);
      
      // Cleanup - untuk mencegah timer pada Future.delayed
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });

    testWidgets('handles forceUpdate exception gracefully', (WidgetTester tester) async {
      // Setup mocks
      when(() => mockFoodTextInputService.saveFoodAnalysis(any()))
          .thenAnswer((_) async => 'Success');
      
      // Setup forceUpdate to throw exception
      when(() => mockFoodTrackingController.forceUpdate())
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextBottomActionBar(
              isLoading: false,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
              // Override navigasi dan timer
              onSavingStateChange: (isLoading) {}, 
            ),
          ),
        ),
      );

      // Tap the add to log button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10)); // Tunggu sedikit
      
      // Verify service was still called despite exception
      verify(() => mockFoodTextInputService.saveFoodAnalysis(testFood)).called(1);
      verify(() => mockFoodTrackingController.forceUpdate()).called(1);
      
      // Test bahwa tidak ada crash meskipun forceUpdate melempar exception
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });

    testWidgets('calls onSavingStateChange with true when saving starts and false when completed',
        (WidgetTester tester) async {
      List<bool> savingStates = [];
      
      // Setup mock dengan delay minimal untuk mengurangi risiko timer
      when(() => mockFoodTextInputService.saveFoodAnalysis(any()))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return 'Success';
          });

      bool navigated = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextBottomActionBar(
              isLoading: false,
              food: testFood,
              foodTextInputService: mockFoodTextInputService,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
              primaryGreen: const Color(0xFF4ECDC4),
              onSavingStateChange: (isLoading) {
                savingStates.add(isLoading);
                // Jika isLoading = false, berarti proses telah selesai
                if (!isLoading) {
                  navigated = true;
                }
              },
            ),
          ),
        ),
      );

      // Tap the add to log button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      
      // Berikan waktu untuk menyelesaikan operasi asinkron tanpa menunggu Future.delayed internal
      for (int i = 0; i < 10 && !navigated; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      
      // Bersihkan timers yang tersisa
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify onSavingStateChange was called correctly
      expect(savingStates, equals([true, false]));
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
