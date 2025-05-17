// lib/features/homepage/presentation/screens/pet_homepage_section.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/heart_bar_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/pet_companion_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/streak_counter_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/heart_bar_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/pet_companion_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/loading_skeleton/streak_counter_skeleton.dart';
import 'package:pockeat/features/homepage/presentation/widgets/heart_bar_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/pet_companion_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/streak_counter_widget.dart';
import 'package:pockeat/features/pet_companion/domain/model/pet_information.dart';

class PetHomepageSection extends StatelessWidget {
  final String petName;
  final PetInformation? petInfo;
  final DailyCalorieStats? stats;
  final int? streakDays;
  final bool isLoading;
  final int? targetCalories;

  const PetHomepageSection({
    super.key,
    this.petName = 'Panda',
    this.petInfo,
    this.stats,
    this.streakDays,
    this.isLoading = false,
    this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTargetCalories =
        (targetCalories != null && targetCalories! > 0)
            ? targetCalories!
            : 2000;

    // Calculate calorie progress
    final calorieProgress =
        ((stats?.caloriesConsumed ?? 0) / effectiveTargetCalories)
            .clamp(0.0, 1.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          // Heart Bar
          isLoading
              ? const HeartBarSkeleton()
              : HeartBarWidget(
                  heart: petInfo?.heart ?? 0,
                  isCalorieOverTarget: petInfo?.isCalorieOverTarget ?? false,
                ),
          const SizedBox(height: 24),

          // Pet Companion Widget
          Center(
            child: isLoading
                ? const PetCompanionSkeleton()
                : PetCompanionWidget(
                    petName: petName,
                    petImagePath: petInfo?.mood == 'happy'
                        ? 'assets/images/panda_happy.json'
                        : 'assets/images/panda_sad.json',
                    calorieProgress: calorieProgress,
                  ),
          ),
          const SizedBox(height: 24),

          // Streak Counter
          isLoading
              ? const StreakCounterSkeleton()
              : StreakCounterWidget(streakDays: streakDays ?? 0),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
