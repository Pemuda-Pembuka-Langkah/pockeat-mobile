// lib/features/homepage/presentation/widgets/pet_homepage_section.dart
import 'package:flutter/material.dart';
import 'package:pockeat/features/homepage/presentation/widgets/pet_companion_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/heart_bar_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/streak_counter_widget.dart';

class PetHomepageSection extends StatefulWidget {
  final String petName;
  final String petImagePath;
  final double calorieProgress;
  final int currentCalories;
  final int goalCalories;
  final int streakDays;

  const PetHomepageSection({
    super.key,
    this.petName = 'Panda',
    this.petImagePath = 'assets/images/panda_happy.gif',
    this.calorieProgress = 0.65,
    this.currentCalories = 1300,
    this.goalCalories = 2000,
    this.streakDays = 5,
  });

  @override
  State<PetHomepageSection> createState() => _PetHomepageSectionState();
}

class _PetHomepageSectionState extends State<PetHomepageSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          // Heart Bar
          HeartBarWidget(
            progress: widget.calorieProgress,
            currentCalories: widget.currentCalories,
            goalCalories: widget.goalCalories,
          ),
          const SizedBox(height: 24),

          // Bagian Peliharaan
          Center(
            child: PetCompanionWidget(
              petName: widget.petName,
              petImagePath: widget.petImagePath,
            ),
          ),
          const SizedBox(height: 24),

          // Streak Counter
          StreakCounterWidget(streakDays: widget.streakDays),
          const SizedBox(height: 16),

        ],
      ),
    );
  }
}