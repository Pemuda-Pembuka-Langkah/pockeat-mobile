import 'package:flutter/material.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_history_card.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A widget that displays a section of recent food logs
///
/// This widget connects to the FoodLogHistoryService to fetch food logs
/// and displays them using the FoodHistoryCard widget.
/// It handles its own navigation to food history pages.
class FoodRecentSection extends StatefulWidget {
  /// The service to use for retrieving food logs
  final FoodLogHistoryService service;

  /// The maximum number of food logs to display
  final int limit;

  final FirebaseAuth? auth;

  /// Creates a new [FoodRecentSection] widget
  const FoodRecentSection({
    super.key,
    required this.service,
    this.limit = 5,
    this.auth,
  });

  @override
  State<FoodRecentSection> createState() => _FoodRecentSectionState();
}

class _FoodRecentSectionState extends State<FoodRecentSection> with WidgetsBindingObserver {
  late Future<List<FoodLogHistoryItem>> _foodsFuture;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadFoods();
    
    // Register as an observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Listen to focus changes to detect when we return to this widget
    _focusNode.addListener(_onFocusChange);
    
    // Request focus to ensure we get focus events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Clean up resources
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app is resumed
    if (state == AppLifecycleState.resumed) {
      _loadFoods();
    }
  }

  void _onFocusChange() {
    // Refresh data when this widget gains focus
    if (_focusNode.hasFocus) {
      _loadFoods();
    }
  }

  @override
  void didUpdateWidget(FoodRecentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service || oldWidget.limit != widget.limit) {
      _loadFoods();
    }
  }

  void _loadFoods() {
    // Get current user's ID
    final userId = (widget.auth ?? FirebaseAuth.instance).currentUser?.uid ?? '';

    setState(() {
      _foodsFuture = widget.service.getAllFoodLogs(userId, limit: widget.limit);
    });
  }

  void _navigateToAllFoods() {
    Navigator.of(context).pushNamed('/food-history').then((_) {
      // Refresh data when returning from food history page
      _loadFoods();
    });
  }

  void _navigateToFoodDetail(FoodLogHistoryItem food) {
    Navigator.of(context).pushNamed(
      '/food-detail',
      arguments: {
        'foodId': food.id,
      },
    ).then((_) {
      // Refresh data when returning from detail page
      _loadFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF4CAF50);

    return Focus(
      focusNode: _focusNode,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16), // Add consistent bottom padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // Added bottom padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Foods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToAllFoods,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Fixed padding
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Show All',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<FoodLogHistoryItem>>(
              future: _foodsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16), // Consistent vertical padding
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Consistent with other paddings
                    child: Center(
                      child: Text(
                        'Error loading foods: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Consistent with other paddings
                    child: Center(
                      child: Text(
                        'No food history yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  );
                } else {
                  final foods = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16), // Consistent horizontal padding
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero, // No additional padding in ListView
                      itemCount: foods.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8), // Consistent spacing between cards
                        child: FoodHistoryCard(
                          food: foods[index],
                          onTap: () => _navigateToFoodDetail(foods[index]),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
