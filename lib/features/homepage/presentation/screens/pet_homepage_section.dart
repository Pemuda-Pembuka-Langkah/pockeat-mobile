// lib/features/homepage/presentation/widgets/pet_homepage_section.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/homepage/presentation/widgets/pet_companion_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/heart_bar_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/streak_counter_widget.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:get_it/get_it.dart';

class PetHomepageSection extends StatefulWidget {
  final String petName;

  const PetHomepageSection({
    super.key,
    this.petName = 'Panda',
  });

  @override
  State<PetHomepageSection> createState() => _PetHomepageSectionState();
}

class _PetHomepageSectionState extends State<PetHomepageSection> {
  final PetService _petService = GetIt.instance<PetService>();
  final FoodLogHistoryService _foodLogHistoryService =
      GetIt.instance<FoodLogHistoryService>();

  final userId = GetIt.instance<FirebaseAuth>().currentUser?.uid ?? '';

  late Future<String> _petMood;
  late Future<int> _dayStreak;
  late Future<int> _petHeart;

  @override
  void initState() {
    super.initState();
    _petMood = _petService.getPetMood(userId);
    _dayStreak = _foodLogHistoryService.getFoodStreakDays(userId);
    _petHeart = _petService.getPetHeart(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          // Heart Bar
          FutureBuilder<int>(
            future: _petHeart,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return HeartBarWidget(heart: snapshot.data ?? 0);
              }
            },
          ),
          const SizedBox(height: 24),

          // Bagian Peliharaan
          // Menggunakan FutureBuilder untuk menangani state loading
          Center(
            child: FutureBuilder<String>(
              future: _petMood,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Tampilkan loading indicator selama menunggu data
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Tampilkan pesan error jika terjadi kesalahan
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Data sudah tersedia, tentukan image path berdasarkan mood
                  final String imagePath = snapshot.data == 'happy'
                      ? 'assets/images/panda_happy.json'
                      : 'assets/images/panda_sad.json';

                  return PetCompanionWidget(
                    petName: widget.petName,
                    petImagePath: imagePath,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Streak Counter
          FutureBuilder<int>(
            future: _dayStreak,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final streakDays = snapshot.data ?? 0;

                return StreakCounterWidget(streakDays: streakDays);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
