import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/presentation/screens/weightlifting_page.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/exercise_card.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/body_part_chip.dart';

// Import the generated mock file
import 'weightlifting_page_test.mocks.dart';

@GenerateMocks([WeightLiftingRepository])
void main() {
  late MockWeightLiftingRepository mockRepository;

  setUp(() {
    mockRepository = MockWeightLiftingRepository();
    when(mockRepository.saveExercise(any)).thenAnswer((_) async => 'mock-id');
  });

  group('WeightliftingPage Tests', () {
    testWidgets('should render basic UI elements', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Basic assertions
      expect(find.text('Weightlifting'), findsOneWidget);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('should select a body part', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Initial state has body part chips
      expect(find.byType(BodyPartChip), findsWidgets);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('should add exercise to the list', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Find exercise item (this will depend on your actual UI structure)
      final exerciseItem = find.text('Bench Press');
      expect(exerciseItem, findsWidgets);
      
      // Add exercise
      await tester.tap(exerciseItem.first);
      await tester.pumpAndSettle();
      
      // Exercise card should be added
      expect(find.byType(ExerciseCard), findsWidgets);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('should save workout', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Add exercise
      final exerciseItem = find.text('Bench Press');
      expect(exerciseItem, findsWidgets);
      await tester.tap(exerciseItem.first);
      await tester.pumpAndSettle();
      
      // Verify exercise card exists
      expect(find.byType(ExerciseCard), findsOneWidget);
      
      // Find add set button
      final addSetButton = find.descendant(
        of: find.byType(ExerciseCard),
        matching: find.byType(OutlinedButton)
      );
      
      expect(addSetButton, findsWidgets, reason: "Could not find the 'Add Set' button in the ExerciseCard");
      await tester.tap(addSetButton.first);
      await tester.pumpAndSettle();
      
      // Fill dialog form - check for TextField widgets first
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
      expect(textFields.evaluate().length >= 3, isTrue, 
          reason: "Expected at least 3 text fields in add set dialog");
          
      await tester.enterText(textFields.at(0), '50');  // Weight field
      await tester.enterText(textFields.at(1), '10');  // Reps field
      await tester.enterText(textFields.at(2), '1.5'); // Duration field
      
      // Add the set - find add button
      final addButton = find.text('Add');
      expect(addButton, findsWidgets);
      await tester.tap(addButton.last); // Use last in case there are multiple 'Add' texts
      await tester.pumpAndSettle();
      
      // Find save button - check if it exists in the app bar or elsewhere
      Finder saveButton = find.byIcon(Icons.save);
      
      if (saveButton.evaluate().isEmpty) {
        // If not found by icon, try looking for a button with 'SAVE' text
        saveButton = find.textContaining('SAVE', findRichText: true);
      }
      
      expect(saveButton, findsWidgets, reason: "No save button found in the UI");
      await tester.tap(saveButton.first);
      await tester.pumpAndSettle();
      
      // Verify repository interaction
      verify(mockRepository.saveExercise(any)).called(1);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    
    // New test: Error handling when saving workout
    testWidgets('should show error when saving workout fails', (WidgetTester tester) async {
      // Set up repository to throw error
      when(mockRepository.saveExercise(any)).thenThrow(Exception('Failed to save'));
      
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Add exercise and set (same steps as save test)
      final exerciseItem = find.text('Bench Press');
      await tester.tap(exerciseItem.first);
      await tester.pumpAndSettle();
      
      final addSetButton = find.descendant(
        of: find.byType(ExerciseCard),
        matching: find.byType(OutlinedButton)
      );
      await tester.tap(addSetButton.first);
      await tester.pumpAndSettle();
      
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '50');
      await tester.enterText(textFields.at(1), '10');
      await tester.enterText(textFields.at(2), '1.5');
      
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
      
      // Try to save and it should fail
      Finder saveButton = find.byIcon(Icons.save);
      if (saveButton.evaluate().isEmpty) {
        saveButton = find.textContaining('SAVE', findRichText: true);
      }
      
      await tester.tap(saveButton.first);
      await tester.pumpAndSettle();
      
      // Verify error snackbar appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to save'), findsOneWidget);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    
    // New test: Form validation
    testWidgets('should validate form inputs when adding set', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Add exercise
      final exerciseItem = find.text('Bench Press');
      await tester.tap(exerciseItem.first);
      await tester.pumpAndSettle();
      
      // Open add set dialog
      final addSetButton = find.descendant(
        of: find.byType(ExerciseCard),
        matching: find.byType(OutlinedButton)
      );
      await tester.tap(addSetButton.first);
      await tester.pumpAndSettle();
      
      // Try to add set with empty values
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.textContaining('valid'), findsWidgets);
      
      // Try to add set with invalid values
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '0'); // Invalid weight
      await tester.enterText(textFields.at(1), '0'); // Invalid reps
      await tester.enterText(textFields.at(2), '0'); // Invalid duration
      
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
      
      // Should still show validation error
      expect(find.textContaining('valid'), findsWidgets);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    
    testWidgets('should validate set inputs correctly', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Add exercise
      final exerciseItem = find.text('Bench Press');
      expect(exerciseItem, findsWidgets);
      await tester.tap(exerciseItem.first);
      await tester.pumpAndSettle();
      
      // Open add set dialog
      final addSetButton = find.descendant(
        of: find.byType(ExerciseCard),
        matching: find.byType(OutlinedButton)
      );
      expect(addSetButton, findsWidgets);
      await tester.tap(addSetButton.first);
      await tester.pumpAndSettle();
      
      // Enter valid values
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
      
      await tester.enterText(textFields.at(0), '50');  // Weight field
      await tester.enterText(textFields.at(1), '10');  // Reps field
      await tester.enterText(textFields.at(2), '1.5'); // Duration field
      
      // Try adding the set with correct values
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
      
      // Verify set was added (dialog closed)
      expect(find.text('Cancel'), findsNothing);
      
      // Verify the exercise card contains updated information
      // Note: The exact format may vary based on implementation, so we'll check for components
      expect(find.textContaining('50'), findsWidgets);
      expect(find.textContaining('10'), findsWidgets);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    
    testWidgets('should not add set with invalid inputs', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Add exercise
      final exerciseItem = find.text('Bench Press');
      await tester.tap(exerciseItem.first);
      await tester.pumpAndSettle();
      
      // Open add set dialog
      final addSetButton = find.descendant(
        of: find.byType(ExerciseCard),
        matching: find.byType(OutlinedButton)
      );
      await tester.tap(addSetButton.first);
      await tester.pumpAndSettle();
      
      // Enter invalid values (zero weight)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '0');   // Invalid weight
      await tester.enterText(textFields.at(1), '10');  // Reps field
      await tester.enterText(textFields.at(2), '1.5'); // Duration field
      
      // Try adding the set
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
      
      // Dialog should still be open (set not added)
      expect(find.text('Cancel'), findsOneWidget);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    
    testWidgets('should switch between body parts', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Find all body part chips
      final bodyPartChips = find.byType(BodyPartChip);
      expect(bodyPartChips, findsWidgets);
      
      // Initial state - select first body part
      await tester.tap(bodyPartChips.first);
      await tester.pumpAndSettle();
      
      // Now select a different body part
      if (bodyPartChips.evaluate().length > 1) {
        await tester.tap(bodyPartChips.at(1));
        await tester.pumpAndSettle();
      }
      
      // Simple verification that app doesn't crash
      expect(find.text('Weightlifting'), findsOneWidget);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    
    testWidgets('should not add set with zero reps', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Add exercise
      final exerciseItem = find.text('Bench Press');
      await tester.tap(exerciseItem.first);
      await tester.pumpAndSettle();
      
      // Open add set dialog
      final addSetButton = find.descendant(
        of: find.byType(ExerciseCard),
        matching: find.byType(OutlinedButton)
      );
      await tester.tap(addSetButton.first);
      await tester.pumpAndSettle();
      
      // Enter invalid values (zero reps)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '50');  // Weight field
      await tester.enterText(textFields.at(1), '0');   // Invalid reps
      await tester.enterText(textFields.at(2), '1.5'); // Duration field
      
      // Try adding the set
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
      
      // Dialog should still be open (set not added)
      expect(find.text('Cancel'), findsOneWidget);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    
    testWidgets('should not add set with zero duration', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: WeightliftingPage(repository: mockRepository),
      ));

      // Add exercise
      final exerciseItem = find.text('Bench Press');
      await tester.tap(exerciseItem.first);
      await tester.pumpAndSettle();
      
      // Open add set dialog
      final addSetButton = find.descendant(
        of: find.byType(ExerciseCard),
        matching: find.byType(OutlinedButton)
      );
      await tester.tap(addSetButton.first);
      await tester.pumpAndSettle();
      
      // Enter invalid values (zero duration)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '50');  // Weight field
      await tester.enterText(textFields.at(1), '10');  // Reps field
      await tester.enterText(textFields.at(2), '0');   // Invalid duration
      
      // Try adding the set
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
      
      // Dialog should still be open (set not added)
      expect(find.text('Cancel'), findsOneWidget);
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}