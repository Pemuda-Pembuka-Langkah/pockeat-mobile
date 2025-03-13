import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/homepage/presentation/screens/food_detail_page.dart';

/// A widget that displays a section of recent food analysis history.
///
/// This widget connects to the FoodScanPhotoService to fetch food analysis logs
/// and displays them in a card format. It handles its own navigation to food detail pages.
class RecentlyFoodsSection extends StatefulWidget {
  final int limit;

  const RecentlyFoodsSection({
    super.key,
    this.limit = 5,
  });

  @override
  State<RecentlyFoodsSection> createState() => _RecentlyFoodsSectionState();
}

class _RecentlyFoodsSectionState extends State<RecentlyFoodsSection> with WidgetsBindingObserver {
  final FoodScanPhotoService _foodScanPhotoService = getIt<FoodScanPhotoService>();
  late Future<List<FoodAnalysisResult>> _foodHistoryFuture;
  final _focusNode = FocusNode();
  
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  @override
  void initState() {
    super.initState();
    _loadFoodHistory();
    
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
      _loadFoodHistory();
    }
  }

  void _onFocusChange() {
    // Refresh data when this widget gains focus
    if (_focusNode.hasFocus) {
      _loadFoodHistory();
    }
  }

  void _loadFoodHistory() {
    setState(() {
      _foodHistoryFuture = _foodScanPhotoService.getAllFoodAnalysis();
    });
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToAllFoods() {
    // TODO: Implement navigation to all foods history page
    debugPrint('Navigate to all foods history');
  }

  void _navigateToFoodDetail(FoodAnalysisResult food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailPage(food: food)),
    ).then((_) {
      // Refresh data when returning from detail page
      _loadFoodHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Show All',
                        style: TextStyle(
                          color: primaryPink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<FoodAnalysisResult>>(
              future: _foodHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: primaryPink),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading foods: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadFoodHistory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPink,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.no_food, size: 64, color: primaryYellow),
                          const SizedBox(height: 16),
                          const Text(
                            'No food history yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Scan your food to start tracking your nutrition intake',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  final foods = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: foods.length > widget.limit ? widget.limit : foods.length,
                    itemBuilder: (context, index) => _buildFoodCard(foods[index]),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodAnalysisResult food) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToFoodDetail(food),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Icon or Image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: food.foodImageUrl != null && food.foodImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          food.foodImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.fastfood,
                              size: 24,
                              color: primaryPink,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.fastfood,
                        size: 24,
                        color: primaryPink,
                      ),
              ),
              const SizedBox(width: 12),
              // Food Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            food.foodName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            _getTimeAgo(food.timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Nutrition info with highlighting
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: 'Calories: '),
                          TextSpan(
                            text: '${food.nutritionInfo.calories.toInt()} kcal',
                            style: TextStyle(
                              color: primaryPink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' • Protein: '),
                          TextSpan(
                            text: '${food.nutritionInfo.protein.toInt()}g',
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' • Carbs: '),
                          TextSpan(
                            text: '${food.nutritionInfo.carbs.toInt()}g',
                            style: TextStyle(
                              color: primaryYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
