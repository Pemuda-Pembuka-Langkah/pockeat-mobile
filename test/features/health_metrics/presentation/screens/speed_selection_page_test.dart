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
        '/review': (_) => const Scaffold(body: Text('Review Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>.value(
        value: mockCubit,
        child: const SpeedSelectionPage(),
      ),
    );
  }

  testWidgets('renders title, slider and button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text("How fast do you want to reach your goal?"), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
  });

  testWidgets('slider can be adjusted and label updates', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final sliderFinder = find.byType(Slider);
    Slider slider = tester.widget(sliderFinder);
    expect(slider.value, 0.5); // initial value

    await tester.drag(sliderFinder, const Offset(200, 0)); // drag right
    await tester.pump();

    // New slider should have different value
    slider = tester.widget(sliderFinder);
    expect(slider.value, greaterThan(0.5));
  });

  testWidgets('calls cubit and navigates on Next', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Tap the "Next" button
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();

    verify(mockCubit.setWeeklyGoal(any)).called(1);
    expect(find.text("Review Page"), findsOneWidget);
  });
}
