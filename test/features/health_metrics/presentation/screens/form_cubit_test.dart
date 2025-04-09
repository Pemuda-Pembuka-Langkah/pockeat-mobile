import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository_impl.dart';

import 'form_cubit_test.mocks.dart';

@GenerateMocks([HealthMetricsRepositoryImpl])
void main() {
  late MockHealthMetricsRepositoryImpl mockRepo;
  late HealthMetricsFormCubit cubit;

  setUp(() {
    mockRepo = MockHealthMetricsRepositoryImpl();
    cubit = HealthMetricsFormCubit(repository: mockRepo, userId: 'user123');
  });

  test('initial state is correct', () {
    expect(cubit.state.selectedGoals, []);
    expect(cubit.state.height, isNull);
  });

  test('toggleGoal adds and removes correctly', () {
    cubit.toggleGoal("Lose Weight");
    expect(cubit.state.selectedGoals, ['Lose Weight']);

    cubit.toggleGoal("Lose Weight");
    expect(cubit.state.selectedGoals, []);
  });

  test('setHeightWeight updates height and weight', () {
    cubit.setHeightWeight(height: 175, weight: 70);
    expect(cubit.state.height, 175);
    expect(cubit.state.weight, 70);
  });

  test('setOtherGoalReason updates reason', () {
    cubit.setOtherGoalReason("Tone muscles");
    expect(cubit.state.otherGoalReason, "Tone muscles");
  });

  test('submit throws if data is incomplete', () async {
    expect(() => cubit.submit(), throwsException);
  });

  test('setGender updates gender', () {
  cubit.setGender("Male");
  expect(cubit.state.gender, "Male");

  cubit.setGender("Female");
  expect(cubit.state.gender, "Female");
});

test('setActivityLevel updates activity level', () {
  cubit.setActivityLevel("Moderately Active");
  expect(cubit.state.activityLevel, "Moderately Active");

  cubit.setActivityLevel("Sedentary");
  expect(cubit.state.activityLevel, "Sedentary");
});


  test('submit calls repository when all data is valid', () async {
    cubit
      ..setHeightWeight(height: 170, weight: 65)
      ..setBirthDate(DateTime(2000, 1, 1))
      ..setDesiredWeight(60)
      ..setWeeklyGoal(0.5)
      ..setGender("Male")
      ..setActivityLevel("Lightly Active")
      ..toggleGoal("Lose Weight");

    await cubit.submit();

    verify(mockRepo.saveHealthMetrics(any)).called(1);
  });

  test('submit throws if "Other" goal has no reason', () async {
    cubit
      ..setHeightWeight(height: 170, weight: 65)
      ..setBirthDate(DateTime(2000, 1, 1))
      ..setDesiredWeight(60)
      ..setWeeklyGoal(0.5)
      ..setGender("Male")
      ..setActivityLevel("Lightly Active")
      ..toggleGoal("Other");

    expect(() => cubit.submit(), throwsException);
  });

  test('submit includes otherGoalReason in model if provided', () async {
    cubit
      ..setHeightWeight(height: 180, weight: 75)
      ..setBirthDate(DateTime(1995, 5, 5))
      ..setDesiredWeight(70)
      ..setWeeklyGoal(1)
      ..setGender("Male")
      ..setActivityLevel("Lightly Active")
      ..toggleGoal("Other")
      ..setOtherGoalReason("Build muscle");

    await cubit.submit();

    verify(mockRepo.saveHealthMetrics(argThat(predicate((model) =>
    (model as HealthMetricsModel).fitnessGoal.contains("Other: Build muscle")
  )))).called(1);
  });
}