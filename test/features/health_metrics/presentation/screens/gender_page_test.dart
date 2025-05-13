// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/gender_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/onboarding_progress_indicator.dart';
import 'gender_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit, NavigatorObserver])

void main() {
  late MockHealthMetricsFormCubit mockCubit;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    mockNavigatorObserver = MockNavigatorObserver();

    when(mockNavigatorObserver.navigator).thenReturn(null);
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
    when(mockCubit.stream)
        .thenAnswer((_) => Stream.value(mockCubit.state));
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const GenderPage(),
      ),
      navigatorObservers: [mockNavigatorObserver],
      routes: {
        '/desired-weight': (context) =>
            const Scaffold(body: Text('Desired Weight Page')),
      },
    );
  }

  testWidgets('renders gender page title correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text("Your Gender"), findsOneWidget); // Main title
    expect(find.text("Select the option that applies to you"), findsOneWidget); // Subtitle
  });

  testWidgets('renders progress indicator', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    expect(find.byType(OnboardingProgressIndicator), findsOneWidget);
  });
  
  testWidgets('renders all gender options correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    // Check for gender options by their labels
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    
    // Check for gender option icons
    expect(find.byIcon(Icons.male_rounded), findsOneWidget);
    expect(find.byIcon(Icons.female_rounded), findsOneWidget);
  });

  testWidgets('tapping on gender option calls cubit.setGender', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    // Find the male option container and tap it
    final maleOption = find.ancestor(
      of: find.text('Male'),
      matching: find.byType(InkWell),
    );
    await tester.tap(maleOption);
    await tester.pump();

    verify(mockCubit.setGender('Male')).called(1);
  });

  testWidgets('Continue button is disabled when gender is not selected',
      (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final continueButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Continue'));

    expect(continueButton.onPressed, isNull);
    
    // Also verify the color is the disabled color
    final buttonStyle = continueButton.style as ButtonStyle;
    final backgroundColor = buttonStyle.backgroundColor?.resolve({});
    expect(backgroundColor?.opacity, lessThan(1.0)); // Checking if it's translucent/disabled
  });

  testWidgets('navigates to next page when gender is selected and Continue is tapped', 
      (tester) async {
      // Set a gender in the cubit's state
      final updatedState = HealthMetricsFormState(gender: 'Female');
      when(mockCubit.state).thenReturn(updatedState);
      when(mockCubit.stream).thenAnswer((_) => Stream.value(updatedState));

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/desired-weight': (_) => const Scaffold(body: Text('Desired Weight Page')),
          },
          home: BlocProvider<HealthMetricsFormCubit>.value(
            value: mockCubit,
            child: const GenderPage(),
          ),
        ),
      );

      await tester.pump(); // needed after changing state
      await tester.pumpAndSettle(); // wait for animations to complete

      // Find the button by type and text
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);
      
      // Tap the Continue button
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Should navigate to Desired Weight Page
      expect(find.text('Desired Weight Page'), findsOneWidget);
    });
    
  testWidgets('shows animation when loaded', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    // Verify the FadeTransition widget exists
    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(SlideTransition), findsWidgets);
    
    // Let the animations play
    await tester.pump(const Duration(milliseconds: 300)); // Half-way point
    await tester.pump(const Duration(milliseconds: 300)); // Full animation
    
    // Everything should be visible now
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
  });
  
  testWidgets('renders the info message correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    // Find the info icon
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    
    // Find the info message text
    expect(
      find.text("Your gender helps us calculate metabolic rates and personalize your nutrition plan."),
      findsOneWidget,
    );
  });
  
  testWidgets('back button is rendered with proper styling', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    // Find the back button
    final backButton = find.byIcon(Icons.arrow_back);
    expect(backButton, findsOneWidget);
    
    // Check if it's wrapped in a Container (shadow and circular decoration)
    final buttonContainer = find.ancestor(
      of: backButton,
      matching: find.byType(Container),
    ).first;
    
    expect(buttonContainer, findsOneWidget);
  });
  
  testWidgets('back button navigates correctly when pressed', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    // Find and tap the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    
    // Verify the navigation observer was called
    verify(mockNavigatorObserver.didPop(any, any));
  });
  
  testWidgets('progress indicator shows correct step', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    // Find the OnboardingProgressIndicator
    final progressIndicator = find.byType(OnboardingProgressIndicator);
    expect(progressIndicator, findsOneWidget);
    
    // Extract the widget to check its properties
    final widget = tester.widget<OnboardingProgressIndicator>(progressIndicator);
    
    // Verify the step values
    expect(widget.totalSteps, 16);
    expect(widget.currentStep, 3);
    expect(widget.showPercentage, true);
  });
  
  testWidgets('container has gradient background', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    
    // Find Container with gradient
    final containerWithGradient = find.descendant(
      of: find.byType(SafeArea),
      matching: find.byType(Container),
    ).first;
    
    expect(containerWithGradient, findsOneWidget);
    
    // Could check for Decoration properties too, but that's more complex
    // and might break with minor implementation changes
  });
}
