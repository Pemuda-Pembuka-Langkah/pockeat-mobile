import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository_impl.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';

import 'form_cubit_test.mocks.dart';

@GenerateMocks([HealthMetricsRepositoryImpl, CaloricRequirementRepository, CaloricRequirementService])
void main() {
  late MockHealthMetricsRepositoryImpl mockRepo;
  late MockCaloricRequirementRepository mockCaloricRepo;
  late MockCaloricRequirementService mockCaloricService;
  late HealthMetricsFormCubit cubit;

  setUp(() {
    mockRepo = MockHealthMetricsRepositoryImpl();
    mockCaloricRepo = MockCaloricRequirementRepository();
    mockCaloricService = MockCaloricRequirementService();
    cubit = HealthMetricsFormCubit(
      repository: mockRepo,
      caloricRequirementRepository: mockCaloricRepo,
      caloricRequirementService: mockCaloricService,
    );
    cubit.setUserId('user123');
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

    // Mock analyze call
    when(mockCaloricService.analyze(
        userId: anyNamed('userId'),
        model: anyNamed('model'),
      )).thenReturn(
      CaloricRequirementModel(
        userId: 'user123',
        bmr: 1500,
        tdee: 2000,
        timestamp: DateTime.now(),
      ),
    );

    await cubit.submit();

    // Verify saveHealthMetrics call
    verify(mockRepo.saveHealthMetrics(any)).called(1);
    // Verify saveCaloricRequirement call
    verify(mockCaloricRepo.saveCaloricRequirement(
      userId: 'user123',
      result: anyNamed('result'),
    )).called(1);
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

    when(mockCaloricService.analyze(
          userId: anyNamed('userId'),
          model: anyNamed('model'),
        )).thenReturn(
      CaloricRequirementModel(
        userId: 'user123',
        bmr: 1500,
        tdee: 2000,
        timestamp: DateTime.now(),
      ),
    );

    await cubit.submit();

    verify(mockRepo.saveHealthMetrics(argThat(predicate((model) {
      final goal = (model as HealthMetricsModel).fitnessGoal;
      return goal.contains("Other: Build muscle");
    })))).called(1);
  });

  test('submit calculates and saves caloric requirement', () async {
    when(mockCaloricService.analyze(
          userId: anyNamed('userId'),
          model: anyNamed('model'),
        )).thenReturn(
      CaloricRequirementModel(
        userId: 'user123',
        bmr: 1600,
        tdee: 2100,
        timestamp: DateTime.now(),
      ),
    );

    cubit
      ..setHeightWeight(height: 180, weight: 75)
      ..setBirthDate(DateTime(1995, 5, 5))
      ..setDesiredWeight(70)
      ..setWeeklyGoal(1)
      ..setGender("Male")
      ..setActivityLevel("moderate")
      ..toggleGoal("Build Muscle");

    await cubit.submit();

    verify(mockCaloricRepo.saveCaloricRequirement(
      userId: 'user123',
      result: anyNamed('result'),
    )).called(1);
  });

  test('submit computes correct BMR and TDEE for Male with moderate activity', () async {
    final now = DateTime.now();
    int age = now.year - 2000;
    if (now.month < 1 || (now.month == 1 && now.day < 1)) {
      age--;
    }
    final expectedBMR = 10 * 75 + 6.25 * 180 - 5 * age + 5;
    final expectedTDEE = expectedBMR * 1.55;

    final fakeResult = CaloricRequirementModel(
      userId: 'user123',
      bmr: expectedBMR,
      tdee: expectedTDEE,
      timestamp: DateTime.now(),
    );

    when(mockCaloricService.analyze(
        userId: anyNamed('userId'),
        model: anyNamed('model'),
      )).thenReturn(fakeResult);

    cubit
      ..setHeightWeight(height: 180, weight: 75)
      ..setBirthDate(DateTime(2000, 1, 1))
      ..setDesiredWeight(70)
      ..setWeeklyGoal(0.5)
      ..setGender("Male")
      ..setActivityLevel("moderate")
      ..toggleGoal("Lose Weight");

    await cubit.submit();

    verify(mockCaloricRepo.saveCaloricRequirement(
      userId: 'user123',
      result: argThat(
        predicate((model) =>
          model is CaloricRequirementModel &&
          (model.bmr - expectedBMR).abs() < 0.01 &&
          (model.tdee - expectedTDEE).abs() < 0.01,
        ),
        named: 'result',
      ),
    )).called(1);
  });
}