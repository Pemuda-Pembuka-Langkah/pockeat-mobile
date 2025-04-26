// File: form_cubit.dart

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';

/// Represents the state of the health metrics onboarding form.
/// Holds all user-inputted health data needed for analysis and submission.
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

/// A Cubit that manages the state of the health metrics form.
/// This class handles user interactions, form updates, and final submission.
class HealthMetricsFormCubit extends Cubit<HealthMetricsFormState> {
  final HealthMetricsRepository repository;
  final CaloricRequirementRepository caloricRequirementRepository;
  final CaloricRequirementService caloricRequirementService;

  String? _userId;

  HealthMetricsFormCubit({
    required this.repository,
    required this.caloricRequirementRepository,
    required this.caloricRequirementService,
  }) : super(HealthMetricsFormState());

  /// Set user ID when available (after registration or login).
  void setUserId(String userId) {
    _userId = userId;
  }

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

  /// Sets the user's physical activity level.
  void setActivityLevel(String level) =>
      emit(state.copyWith(activityLevel: level));

  /// Sets the user's dietary preference/type.
  void setDietType(String type) => emit(state.copyWith(dietType: type));
  void setDesiredWeight(double weight) =>
      emit(state.copyWith(desiredWeight: weight));
  void setWeeklyGoal(double weeklyGoal) =>
      emit(state.copyWith(weeklyGoal: weeklyGoal));

  /// Submit final data to backend. Only call after user ID is set.
  Future<void> submit() async {
    if (_userId == null) {
      throw Exception("User ID not set. Cannot submit.");
    }

    // Validate required fields
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

    // Calculate age from birth date
    final now = DateTime.now();
    int age = now.year - state.birthDate!.year;
    if (now.month < state.birthDate!.month ||
        (now.month == state.birthDate!.month &&
            now.day < state.birthDate!.day)) {
      age--;
    }

    // Prepare goals, including custom reason
    final allGoals = List<String>.from(state.selectedGoals);
    if (allGoals.contains("Other") && state.otherGoalReason != null) {
      allGoals[allGoals.indexOf("Other")] = "Other: ${state.otherGoalReason}";
    }

    final model = HealthMetricsModel(
      userId: _userId!,
      height: state.height!,
      weight: state.weight!,
      age: age,
      gender: state.gender!,
      activityLevel: state.activityLevel!,
      fitnessGoal: allGoals.join(", "),
    );

    await repository.saveHealthMetrics(model);

    // Analyze and save caloric requirements
    try {
      final caloricResult = caloricRequirementService.analyze(
        userId: _userId!,
        model: model,
      );

      await caloricRequirementRepository.saveCaloricRequirement(
        userId: _userId!,
        result: caloricResult,
      );
    } catch (e) {
      throw Exception("Failed to save caloric requirement: $e");
    }
  }
}
