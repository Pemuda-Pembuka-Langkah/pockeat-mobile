// File: form_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

class HealthMetricsFormState {
  final List<String> selectedGoals;
  final String? otherGoalReason;
  final double? height;
  final double? weight;
  final DateTime? birthDate;
  final String? gender;
  final String? activityLevel;
  final String? dietType;
  final double? desiredWeight;
  final double? weeklyGoal;

  HealthMetricsFormState({
    this.selectedGoals = const [],
    this.otherGoalReason,
    this.height,
    this.weight,
    this.birthDate,
    this.gender,
    this.activityLevel,
    this.dietType,
    this.desiredWeight,
    this.weeklyGoal,
  });

  HealthMetricsFormState copyWith({
    List<String>? selectedGoals,
    String? otherGoalReason,
    double? height,
    double? weight,
    DateTime? birthDate,
    String? gender,
    String? activityLevel,
    String? dietType,
    double? desiredWeight,
    double? weeklyGoal,
  }) {
    return HealthMetricsFormState(
      selectedGoals: selectedGoals ?? this.selectedGoals,
      otherGoalReason: otherGoalReason ?? this.otherGoalReason,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      dietType: dietType ?? this.dietType,
      desiredWeight: desiredWeight ?? this.desiredWeight,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    );
  }
}

class HealthMetricsFormCubit extends Cubit<HealthMetricsFormState> {
  final HealthMetricsRepository repository;
  final String userId;

  HealthMetricsFormCubit({
    required this.repository,
    required this.userId,
  }) : super(HealthMetricsFormState());

  void toggleGoal(String goal) {
    final updatedGoals = List<String>.from(state.selectedGoals);
    if (updatedGoals.contains(goal)) {
      updatedGoals.remove(goal);
    } else {
      updatedGoals.add(goal);
    }
    emit(state.copyWith(selectedGoals: updatedGoals));
  }

  void setOtherGoalReason(String reason) {
    emit(state.copyWith(otherGoalReason: reason));
  }

  void setHeightWeight({required double height, required double weight}) {
    emit(state.copyWith(height: height, weight: weight));
  }

  void setBirthDate(DateTime date) => emit(state.copyWith(birthDate: date));

  void setGender(String gender) => emit(state.copyWith(gender: gender));

  void setActivityLevel(String level) => emit(state.copyWith(activityLevel: level));

  void setDietType(String type) => emit(state.copyWith(dietType: type));

  void setDesiredWeight(double weight) =>
      emit(state.copyWith(desiredWeight: weight));

  void setWeeklyGoal(double weeklyGoal) =>
      emit(state.copyWith(weeklyGoal: weeklyGoal));

  Future<void> submit() async {
    if (state.height == null ||
        state.weight == null ||
        state.birthDate == null ||
        state.desiredWeight == null ||
        state.weeklyGoal == null ||
        state.gender == null ||
        state.activityLevel == null ||
        state.selectedGoals.isEmpty ||
        (state.selectedGoals.contains("Other") &&
            (state.otherGoalReason == null ||
                state.otherGoalReason!.trim().isEmpty))) {
      throw Exception("Incomplete data");
    }

    final age = DateTime.now().year - state.birthDate!.year;

    // Combine selected goals + other
    final allGoals = List<String>.from(state.selectedGoals);
    if (allGoals.contains("Other") && state.otherGoalReason != null) {
      allGoals[allGoals.indexOf("Other")] = "Other: ${state.otherGoalReason}";
    }

    final model = HealthMetricsModel(
      userId: userId,
      height: state.height!,
      weight: state.weight!,
      age: age,
      fitnessGoal: allGoals.join(", "),
      gender: state.gender!,
      activityLevel: state.activityLevel!,
    );

    await repository.saveHealthMetrics(model);
  }
}