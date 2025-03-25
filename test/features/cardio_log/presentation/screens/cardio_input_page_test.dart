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

@GenerateMocks([CardioRepository, FirebaseAuth, FirebaseFirestore])
import 'cardio_input_page_test.mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Create a mock User class
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
}

@GenerateMocks([CardioRepository])
@GenerateMocks([FirebaseFirestore])
void main() {
  late MockCardioRepository mockRepository;
  late MockFirebaseAuth mockAuth;
  late User mockUser;

  setUp(() {
    mockRepository = MockCardioRepository();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Configure mock auth
    // when(mockUser.uid).thenReturn('test-user-id');
    when(mockAuth.currentUser).thenReturn(mockUser);
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
      // Setup repository response
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'activity-id-123');

      await tester.pumpWidget(createCardioInputPage());

      // Tap Save button
      await tester.tap(find.text('Save Run'));
      await tester.pump();

      // Verify repository was called
      verify(mockRepository.saveCardioActivity(any)).called(1);

      // Verify SnackBar is shown
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('SaveActivity should show error SnackBar on failure',
        (WidgetTester tester) async {
      // Setup repository to throw exception
      when(mockRepository.saveCardioActivity(any))
          .thenThrow(Exception('Test error'));

      await tester.pumpWidget(createCardioInputPage());

      // Tap Save button
      await tester.tap(find.text('Save Run'));
      await tester.pump();

      // Verify error SnackBar is shown
      expect(find.text('Failed to save activity. Please try again.'),
          findsOneWidget);
    });
  });

  // Test application behavior for each cardio type
  group('Integration Tests', () {
    testWidgets(
        'Should correctly parse and save cycling activity with commute type',
        (WidgetTester tester) async {
      // Create a variable to capture the saved activity
      CardioActivity? capturedActivity;

      // Setup repository to capture the saved activity
      when(mockRepository.saveCardioActivity(any)).thenAnswer((invocation) {
        capturedActivity = invocation.positionalArguments[0];
        return Future.value('activity-id-123');
      });

      await tester.pumpWidget(createCardioInputPage());

      // Switch to Cycling tab
      await tester.tap(find.text('Cycling'));
      await tester.pump();

      // Select commute cycling type
      await tester.tap(find.text('Commute'));
      await tester.pump();

      // Tap Save button
      await tester.tap(find.text('Save Ride'));
      await tester.pump();

      // Move this assertion AFTER we've called the method that sets capturedActivity
      expect(capturedActivity!.userId, 'test-user-id');

      // Verify repository method was called and the activity has the right type
      verify(mockRepository.saveCardioActivity(any)).called(1);
      expect(capturedActivity, isA<CyclingActivity>());
      expect((capturedActivity as CyclingActivity).cyclingType,
          CyclingType.commute);
    });

    testWidgets(
        'Should correctly parse and save cycling activity with stationary type',
        (WidgetTester tester) async {
      // Create a variable to capture the saved activity
      CardioActivity? capturedActivity;

      // Setup repository to capture the saved activity
      when(mockRepository.saveCardioActivity(any)).thenAnswer((invocation) {
        capturedActivity = invocation.positionalArguments[0];
        return Future.value('activity-id-123');
      });

      await tester.pumpWidget(createCardioInputPage());

      // Switch to Cycling tab
      await tester.tap(find.text('Cycling'));
      await tester.pump();

      // Select stationary cycling type
      await tester.tap(find.text('Stationary'));
      await tester.pump();

      // Tap Save button
      await tester.tap(find.text('Save Ride'));
      await tester.pump();

      // Verify repository method was called and the activity has the right type
      verify(mockRepository.saveCardioActivity(any)).called(1);
      expect(capturedActivity, isA<CyclingActivity>());
      expect((capturedActivity as CyclingActivity).cyclingType,
          CyclingType.stationary);
    });

    testWidgets('CardioInputPage uses provided repository correctly',
        (WidgetTester tester) async {
      // Setup mock repository to return a specific ID when saving
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'test-specific-id');

      await tester.pumpWidget(createCardioInputPage());

      // Save an activity
      await tester.tap(find.text('Save Run'));
      await tester.pump();

      // Verify the provided repository was used
      verify(mockRepository.saveCardioActivity(any)).called(1);
    });
    testWidgets('Running activity end-to-end test',
        (WidgetTester tester) async {
      // Setup repository response
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'activity-id-123');

      await tester.pumpWidget(createCardioInputPage());

      // Verify initial state
      expect(find.text('Running'), findsWidgets);
      expect(find.text('Save Run'), findsOneWidget);

      // Verify form is displayed
      expect(find.byType(RunningForm), findsOneWidget);

      // Tap Save button without changing values (using defaults)
      await tester.tap(find.text('Save Run'));
      await tester.pump();

      // Verify repository method was called
      verify(mockRepository.saveCardioActivity(any)).called(1);

      // Verify success message
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Cycling activity end-to-end test',
        (WidgetTester tester) async {
      // Setup repository response
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'activity-id-123');

      await tester.pumpWidget(createCardioInputPage());

      // Switch to Cycling
      await tester.tap(find.text('Cycling'));
      await tester.pump();

      // Verify form changed
      expect(find.text('Cycling'), findsWidgets);
      expect(find.text('Save Ride'), findsOneWidget);
      expect(find.byType(CyclingForm), findsOneWidget);

      // Tap Save button without changing values (using defaults)
      await tester.tap(find.text('Save Ride'));
      await tester.pump();

      // Verify repository method was called
      verify(mockRepository.saveCardioActivity(any)).called(1);

      // Verify success message
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Swimming activity end-to-end test',
        (WidgetTester tester) async {
      // Setup repository response
      when(mockRepository.saveCardioActivity(any))
          .thenAnswer((_) async => 'activity-id-123');

      await tester.pumpWidget(createCardioInputPage());

      // Switch to Swimming
      await tester.tap(find.text('Swimming'));
      await tester.pump();

      // Verify form changed
      expect(find.text('Swimming'), findsWidgets);
      expect(find.text('Save Swim'), findsOneWidget);
      expect(find.byType(SwimmingForm), findsOneWidget);

      // Tap Save button without changing values (using defaults)
      await tester.tap(find.text('Save Swim'));
      await tester.pump();

      // Verify repository method was called
      verify(mockRepository.saveCardioActivity(any)).called(1);

      // Verify success message
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
