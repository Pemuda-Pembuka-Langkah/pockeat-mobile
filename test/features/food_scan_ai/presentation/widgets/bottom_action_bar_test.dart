import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/bottom_action_bar.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/correction_dialog.dart';

class MockFoodScanPhotoService extends Mock implements FoodScanPhotoService {}

void main() {
  late MockFoodScanPhotoService mockFoodScanPhotoService;
  late FoodAnalysisResult testFood;
  const primaryPink = Color(0xFFFF6B6B);
  const primaryYellow = Color(0xFFFFE893);
  const primaryGreen = Color(0xFF4ECDC4);

  setUp(() {
    mockFoodScanPhotoService = MockFoodScanPhotoService();
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
      expect(find.byType(CorrectionDialog), findsOneWidget);
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
      expect(find.byType(CorrectionDialog), findsNothing);
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
      expect(find.byType(CorrectionDialog), findsNothing);
    });

    testWidgets('correction dialog calls correctFoodAnalysis when submitted',
        (WidgetTester tester) async {
      final correctedFood = FoodAnalysisResult(
        foodName: 'Corrected Food',
        nutritionInfo: NutritionInfo(
          calories: 150,
          protein: 15,
          carbs: 25,
          fat: 5,
          fiber: 3,
          sugar: 2,
          sodium: 100,
        ),
        warnings: [],
        ingredients: [],
      );
      
      bool correctionCallbackCalled = false;

      // Setup mock response
      when(() => mockFoodScanPhotoService.correctFoodAnalysis(any(), any()))
          .thenAnswer((_) async => correctedFood);

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
                correctionCallbackCalled = true;
                expect(result, equals(correctedFood));
              },
            ),
          ),
        ),
      );

      // Tap the correction button to open dialog
      await tester.tap(find.text('Correct Analysis'));
      await tester.pumpAndSettle();

      // Enter correction text
      await tester.enterText(find.byType(TextField), 'This is brown rice');
      
      // Close keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tap the submit button
      await tester.tap(find.text('Submit Correction'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(CorrectionDialog), findsNothing);

      // Verify service was called with correct parameters
      verify(() => mockFoodScanPhotoService.correctFoodAnalysis(testFood, 'This is brown rice')).called(1);
      
      // Verify callback was called
      expect(correctionCallbackCalled, isTrue);
      
      // Verify processing message was shown
      expect(find.text('Processing correction...'), findsOneWidget);
    });

    testWidgets('shows error when correction fails',
        (WidgetTester tester) async {
      // Setup mock to throw error
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
      
      // Close keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tap the submit button
      await tester.tap(find.text('Submit Correction'));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Failed to correct analysis: Exception: Correction error'), findsOneWidget);
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
      // Setup mock to delay response
      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 'Food saved successfully';
      });

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

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows success snackbar when save is successful',
        (WidgetTester tester) async {
      const successMessage = 'Successfully saved food analysis';

      // Setup mock to return success
      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) async {
        return successMessage;
      });

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
      await tester.pumpAndSettle();

      // Verify snackbar with success message is shown
      expect(find.widgetWithText(SnackBar, successMessage), findsOneWidget);

      // Verify service was called with correct food
      verify(() => mockFoodScanPhotoService.saveFoodAnalysis(testFood))
          .called(1);
    });

    testWidgets('shows error snackbar when save fails',
        (WidgetTester tester) async {
      // Setup mock to throw error
      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
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

      // Tap the button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
      await tester.pumpAndSettle();

      // Verify error snackbar is shown
      expect(find.textContaining('Failed to save:'), findsOneWidget);
      expect(find.textContaining('Exception: Network error'), findsOneWidget);
    });

    testWidgets('navigates back after successful save',
        (WidgetTester tester) async {
      bool didPop = false;

      // Setup mock to return success
      when(() => mockFoodScanPhotoService.saveFoodAnalysis(any()))
          .thenAnswer((_) async {
        return 'Food saved successfully';
      });

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
          navigatorObservers: [
            MockNavigatorObserver(onPop: () => didPop = true),
          ],
        ),
      );

      // Tap the button
      await tester.tap(find.byKey(const Key('add_to_log_button')));
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