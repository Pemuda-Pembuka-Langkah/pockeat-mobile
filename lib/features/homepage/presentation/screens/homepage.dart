// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/homepage/presentation/screens/overview_section.dart';
import 'package:pockeat/features/homepage/presentation/screens/pet_homepage_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  String? dbInfo;
  
  // Food streak data
  int _streakDays = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadStreakDays();
  }
  
  Future<void> _loadStreakDays() async {
    // Skip if widget is no longer mounted
    if (!mounted) return;

    try {
      // Use GetIt to get FirebaseAuth for better testability
      final auth = GetIt.I<FirebaseAuth>();
      final user = auth.currentUser;
      
      if (user != null) {
        // Get FoodLogHistoryService from GetIt
        final foodLogHistoryService = GetIt.I<FoodLogHistoryService>();
        
        // Get streak days for current user
        final streakDays = await foodLogHistoryService.getFoodStreakDays(user.uid);
        
        if (mounted) {
          setState(() {
            _streakDays = streakDays;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            // User is null, keep default streak days (0)
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading streak days: $e');
      if (mounted) {
        setState(() {
          // Error occurred, keep default streak days (0)
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    backgroundColor: primaryYellow,
                    elevation: 0,
                    toolbarHeight: 60,
                    title: const Row(
                      children: [
                        Text(
                          'Pockeat',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                    children: [
                      PetHomepageSection(streakDays: _streakDays),
                      const OverviewSection(),
                    ],
                  )),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
