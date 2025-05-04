// speed_selection_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/speed_selection_page.dart';
import 'speed_selection_page_test.mocks.dart';

// Project imports

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    when(mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockCubit.state).thenReturn(HealthMetricsFormState());
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/thank-you': (_) => const Scaffold(body: Text('Thank You Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const SpeedSelectionPage(),
      ),
    );
  }

  testWidgets('renders title, slider, kg/week label, and Next button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump(); // <-- Important extra pump to finish the frame updates

    expect(find.text("How fast do you want to reach your goal?"), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.textContaining("kg/week"), findsOneWidget); // label like "0.5 kg/week"
    expect(find.text("Next"), findsOneWidget);
  });

  testWidgets('displays motivational text based on slider value', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // complete initial frame

      // Initially at 0.5 => "Balanced & consistent 🧘"
      expect(find.text('Balanced & consistent 🧘'), findsOneWidget);

      // Drag slider right to >1.2
      final sliderFinder = find.byType(Slider);
      await tester.drag(sliderFinder, const Offset(300, 0)); // Big drag to the right
      await tester.pumpAndSettle();

      // Now expect "Aggressive ⚡️"
      expect(find.text('Aggressive ⚡️'), findsOneWidget);

      // Drag slider back to very left (<0.5)
      await tester.drag(sliderFinder, const Offset(-600, 0)); // Big drag to the left
      await tester.pumpAndSettle();

      // Now expect "Slow & steady 🐢"
      expect(find.text('Slow & steady 🐢'), findsOneWidget);
    });

  testWidgets('calls cubit and navigates to thank you page on Next', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump(); // extra pump

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    verify(mockCubit.setWeeklyGoal(any)).called(1);
    expect(find.text('Thank You Page'), findsOneWidget);
  });
}
