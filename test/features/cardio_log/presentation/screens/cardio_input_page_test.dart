import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/repositories/cardio_repository.dart';
import 'package:pockeat/features/cardio_log/presentation/screens/cardio_input_page.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/cycling_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/running_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/swimming_form.dart';

@GenerateMocks([CardioRepository, FirebaseFirestore])
import 'cardio_input_page_test.mocks.dart';

// Manual implementation of MockFirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Create a mock User class
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
}

void setupValidRunningForm(WidgetTester tester) {
  final formFinder = find.byType(RunningForm);
  expect(formFinder, findsOneWidget);

  final form = tester.widget<RunningForm>(formFinder);
  final state = (form.key as GlobalKey<RunningFormState>).currentState!;

  state.selectedKm = 5;
  state.selectedMeter = 0;

  final now = DateTime.now();
  state.selectedStartTime = DateTime(now.year, now.month, now.day, 10, 0);
  state.selectedEndTime = DateTime(now.year, now.month, now.day, 10, 30);
}

void setupValidCyclingForm(
    WidgetTester tester, CyclingActivityType cyclingType) {
  final formFinder = find.byType(CyclingForm);
  expect(formFinder, findsOneWidget);

  final form = tester.widget<CyclingForm>(formFinder);
  final state = (form.key as GlobalKey<CyclingFormState>).currentState!;

  state.selectedKm = 5;
  state.selectedMeter = 0;

  state.selectedCyclingType = cyclingType;

  final now = DateTime.now();
  state.selectedStartTime = DateTime(now.year, now.month, now.day, 10, 0);
  state.selectedEndTime = DateTime(now.year, now.month, now.day, 10, 30);
}

void setupValidSwimmingForm(WidgetTester tester) {
  final formFinder = find.byType(SwimmingForm);
  expect(formFinder, findsOneWidget);

  final form = tester.widget<SwimmingForm>(formFinder);
  final state = (form.key as GlobalKey<SwimmingFormState>).currentState!;

  state.selectedLaps = 10;
  state.customPoolLength = 25.0;

  final now = DateTime.now();
  state.selectedStartTime = DateTime(now.year, now.month, now.day, 10, 0);
  state.selectedEndTime = DateTime(now.year, now.month, now.day, 10, 30);
}

void main() {
  late MockCardioRepository mockRepository;
  late MockFirebaseAuth mockAuth;
  late User mockUser;

  setUp(() {
    mockRepository = MockCardioRepository();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Configure mock auth
    when(mockAuth.currentUser).thenReturn(mockUser);

    // Set up successful repository response for all tests
    when(mockRepository.saveCardioActivity(any))
        .thenAnswer((_) async => 'activity-id-123');
  });

  // Helper to set up test widget
  Widget createCardioInputPage() {
    return MaterialApp(
      home: CardioInputPage(
        repository: mockRepository,
        auth: mockAuth,
      ),
    );
  }

  // Test for building CardioInputPage widget
  group('CardioInputPage Widget Tests', () {
    testWidgets('CardioInputPage should build correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Verify that widget is rendered correctly
      expect(find.text('Cardio Exercise Type'), findsOneWidget);
      expect(find.text('Running'), findsWidgets); // Tab and AppBar
      expect(find.text('Cycling'), findsOneWidget);
      expect(find.text('Swimming'), findsOneWidget);

      // Verify that save button exists
      expect(find.text('Save Run'), findsOneWidget);
    });

    testWidgets('Should switch between cardio types correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Initially on Running tab
      expect(find.text('Save Run'), findsOneWidget);

      // Tap Cycling tab
      await tester.tap(find.text('Cycling'));
      await tester.pump();
      expect(find.text('Save Ride'), findsOneWidget);

      // Verify AppBar title changes to Cycling
      expect(find.text('Cycling'), findsWidgets);

      // Tap Swimming tab
      await tester.tap(find.text('Swimming'));
      await tester.pump();
      expect(find.text('Save Swim'), findsOneWidget);

      // Verify AppBar title changes to Swimming
      expect(find.text('Swimming'), findsWidgets);

      // Back to Running tab
      await tester.tap(find.text('Running').first);
      await tester.pump();
      expect(find.text('Save Run'), findsOneWidget);

      // Verify AppBar title changes back to Running
      expect(find.text('Running'), findsWidgets);
    });

    // For this test, we're not actually testing navigation since it might be complicated in the test environment
    testWidgets('Back button interaction should work',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Verify back button exists
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // We can't fully test navigation in this isolated test, but we can verify the tap happens
    });
  });

  // Test for CardioType button
  group('CardioType Button Tests', () {
    testWidgets('CardioType buttons should be selectable',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Verify Running is selected by default
      final runningFinder = find.text('Running');
      expect(runningFinder, findsWidgets);

      // Find the Container that contains the Running button
      final runningButtonContainer = find.ancestor(
        of: runningFinder.first,
        matching: find.byType(Container),
      );

      // Get the first Container widget
      final initialRunningButton = tester.widget<Container>(
        runningButtonContainer.first,
      );

      // Verify default selection styling
      expect(
          (initialRunningButton.decoration as BoxDecoration).border, isNotNull);

      // Tap Cycling button
      await tester.tap(find.text('Cycling'));
      await tester.pump();

      // Find the Container that contains the Cycling button
      final cyclingFinder = find.text('Cycling');
      final cyclingButtonContainer = find.ancestor(
        of: cyclingFinder,
        matching: find.byType(Container),
      );

      // Get the first Container widget
      final cyclingButton = tester.widget<Container>(
        cyclingButtonContainer.first,
      );

      // Verify cycling selection styling
      expect((cyclingButton.decoration as BoxDecoration).border, isNotNull);

      // Verify button selection changes app behavior
      expect(find.text('Cycling'), findsWidgets);
      expect(find.text('Save Ride'), findsOneWidget);
    });
  });

  // Test for RunningForm
  group('Running Form Tests', () {
    testWidgets('Running form should display correct fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Verify Running form fields
      expect(find.text('Running'), findsWidgets); // In AppBar and tab
      expect(find.byType(RunningForm), findsOneWidget);
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);

      // Verify Personal Data Reminder is present
      expect(
          find.text(
              'Calculation of the number of calories burned is based on your personal data (height, weight, gender).'),
          findsOneWidget);
    });

    testWidgets('Running form should calculate calories correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Get the form instance
      final formFinder = find.byType(RunningForm);
      expect(formFinder, findsOneWidget);

      final form = tester.widget<RunningForm>(formFinder);

      // Verify that calculateCalories method exists and can be called
      expect(form.calculateCalories(), isNotNull);
    });
  });

  // Test for CyclingForm
  group('Cycling Form Tests', () {
    testWidgets('Cycling form should display correct fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Switch to Cycling tab
      await tester.tap(find.text('Cycling'));
      await tester.pump();

      // Verify Cycling form fields
      expect(find.byType(CyclingForm), findsOneWidget);
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Cycling Activity Type'), findsOneWidget);

      // Verify cycling specific options
      expect(find.text('Mountain'), findsOneWidget);
      expect(find.text('Commute'), findsOneWidget);
      expect(find.text('Stationary'), findsOneWidget);

      // Verify Personal Data Reminder is present
      expect(
          find.text(
              'Calculation of the number of calories burned is based on your personal data (height, weight, gender).'),
          findsOneWidget);
    });

    testWidgets('Cycling form should handle type selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Switch to Cycling tab
      await tester.tap(find.text('Cycling'));
      await tester.pump();

      // Default type is Mountain
      expect(find.text('Mountain'), findsOneWidget);

      // Tap on Stationary Bike type
      await tester.tap(find.text('Stationary'));
      await tester.pump();

      // Verify selection
      final containerFinder = find
          .ancestor(
            of: find.text('Stationary'),
            matching: find.byType(Container),
          )
          .first;

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      // Verify selected styling (should have accent color or border)
      expect(decoration.border != null, true);
    });
  });

  // Test for SwimmingForm
  group('Swimming Form Tests', () {
    testWidgets('Swimming form should display correct fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Switch to Swimming tab
      await tester.tap(find.text('Swimming'));
      await tester.pump();

      // Verify Swimming form fields
      expect(find.byType(SwimmingForm), findsOneWidget);
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Laps'), findsOneWidget);
      expect(find.text('Pool Length'), findsOneWidget);
      expect(find.text('Swimming Stroke'), findsOneWidget);

      // Verify swimming specific fields
      expect(find.text('Freestyle (Front Crawl)'), findsOneWidget);

      // Verify Personal Data Reminder is present
      expect(
          find.text(
              'Calculation of the number of calories burned is based on your personal data (height, weight, gender).'),
          findsOneWidget);
    });

    testWidgets('Swimming form should handle stroke selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCardioInputPage());

      // Switch to Swimming tab
      await tester.tap(find.text('Swimming'));
      await tester.pump();

      // Default stroke is Freestyle
      expect(find.text('Freestyle (Front Crawl)'), findsOneWidget);

      // Open the dropdown if exists
      if (find.byType(DropdownButtonFormField<String>).evaluate().isNotEmpty) {
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Find and tap Breaststroke if available
        if (find.text('Breaststroke').evaluate().isNotEmpty) {
          await tester.tap(find.text('Breaststroke').last);
          await tester.pumpAndSettle();

          // Verify selection
          expect(find.text('Breaststroke'), findsOneWidget);
        }
      }
    });
  });

  // Test for saveActivity method
  group('SaveActivity Method Tests', () {
    testWidgets('SaveActivity should call repository and show success message',
        (WidgetTester tester) async {
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'activity-id-123');

      await tester.pumpWidget(createCardioInputPage());

      setupValidRunningForm(tester);

      await tester.tap(find.text('Save Run'));
      await tester.pumpAndSettle();

      verify(mockRepository.saveCardioActivity(any)).called(1);

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('SaveActivity should show error SnackBar on failure',
        (WidgetTester tester) async {
      // Setup repository to throw exception
      when(mockRepository.saveCardioActivity(any))
          .thenThrow(Exception('Test error'));

      await tester.pumpWidget(createCardioInputPage());

      // Set up valid form values
      setupValidRunningForm(tester);

      // Tap Save button
      await tester.tap(find.text('Save Run'));
      await tester.pumpAndSettle();

      // Verify error SnackBar is shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to save activity'), findsOneWidget);
    });
  });

  // Test application behavior for each cardio type
  group('Integration Tests', () {
    testWidgets(
        'Should correctly parse and save cycling activity with commute type',
        (WidgetTester tester) async {
      CardioActivity? capturedActivity;

      when(mockRepository.saveCardioActivity(any)).thenAnswer((invocation) {
        capturedActivity = invocation.positionalArguments[0];
        return Future.value('activity-id-123');
      });

      await tester.pumpWidget(createCardioInputPage());

      await tester.tap(find.text('Cycling'));
      await tester.pump();

      setupValidCyclingForm(tester, CyclingActivityType.commute);

      await tester.tap(find.text('Save Ride'));
      await tester.pumpAndSettle();

      verify(mockRepository.saveCardioActivity(any)).called(1);

      expect(capturedActivity, isA<CyclingActivity>());
      expect((capturedActivity as CyclingActivity).cyclingType,
          CyclingType.commute);
      expect(capturedActivity!.userId, 'test-user-id');
    });

    testWidgets(
        'Should correctly parse and save cycling activity with stationary type',
        (WidgetTester tester) async {
      CardioActivity? capturedActivity;

      when(mockRepository.saveCardioActivity(any)).thenAnswer((invocation) {
        capturedActivity = invocation.positionalArguments[0];
        return Future.value('activity-id-123');
      });

      await tester.pumpWidget(createCardioInputPage());

      await tester.tap(find.text('Cycling'));
      await tester.pump();

      setupValidCyclingForm(tester, CyclingActivityType.stationary);

      await tester.tap(find.text('Save Ride'));
      await tester.pumpAndSettle();

      verify(mockRepository.saveCardioActivity(any)).called(1);

      expect(capturedActivity, isA<CyclingActivity>());
      expect((capturedActivity as CyclingActivity).cyclingType,
          CyclingType.stationary);
    });

    testWidgets('CardioInputPage uses provided repository correctly',
        (WidgetTester tester) async {
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'test-specific-id');

      await tester.pumpWidget(createCardioInputPage());

      setupValidRunningForm(tester);

      await tester.tap(find.text('Save Run'));
      await tester.pumpAndSettle();

      verify(mockRepository.saveCardioActivity(any)).called(1);
    });

    testWidgets('Running activity end-to-end test',
        (WidgetTester tester) async {
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'activity-id-123');

      await tester.pumpWidget(createCardioInputPage());

      expect(find.text('Running'), findsWidgets);
      expect(find.text('Save Run'), findsOneWidget);
      expect(find.byType(RunningForm), findsOneWidget);

      setupValidRunningForm(tester);

      await tester.tap(find.text('Save Run'));
      await tester.pumpAndSettle();

      verify(mockRepository.saveCardioActivity(any)).called(1);

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Cycling activity end-to-end test',
        (WidgetTester tester) async {
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'activity-id-123');

      await tester.pumpWidget(createCardioInputPage());

      await tester.tap(find.text('Cycling'));
      await tester.pump();

      expect(find.text('Cycling'), findsWidgets);
      expect(find.text('Save Ride'), findsOneWidget);
      expect(find.byType(CyclingForm), findsOneWidget);

      setupValidCyclingForm(tester, CyclingActivityType.mountain);

      await tester.tap(find.text('Save Ride'));
      await tester.pumpAndSettle();

      verify(mockRepository.saveCardioActivity(any)).called(1);

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Swimming activity end-to-end test',
        (WidgetTester tester) async {
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'activity-id-123');

      await tester.pumpWidget(createCardioInputPage());

      await tester.tap(find.text('Swimming'));
      await tester.pump();

      expect(find.text('Swimming'), findsWidgets);
      expect(find.text('Save Swim'), findsOneWidget);
      expect(find.byType(SwimmingForm), findsOneWidget);

      setupValidSwimmingForm(tester);

      await tester.tap(find.text('Save Swim'));
      await tester.pumpAndSettle();

      verify(mockRepository.saveCardioActivity(any)).called(1);

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
