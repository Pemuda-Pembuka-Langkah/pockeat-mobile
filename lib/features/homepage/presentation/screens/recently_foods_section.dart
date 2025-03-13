import 'package:flutter/material.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_scan_ai/domain/services/food_scan_photo_service.dart';
import 'package:pockeat/features/homepage/presentation/screens/food_detail_page.dart';

class RecentlyFoodsSection extends StatefulWidget {
  const RecentlyFoodsSection({Key? key}) : super(key: key);

  @override
  State<RecentlyFoodsSection> createState() => _RecentlyFoodsSectionState();
}

class _RecentlyFoodsSectionState extends State<RecentlyFoodsSection> {
  final FoodScanPhotoService _foodScanPhotoService = getIt<FoodScanPhotoService>();
  List<FoodAnalysisResult> _foodHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  @override
  void initState() {
    super.initState();
    _loadFoodHistory();
  }

  Future<void> _loadFoodHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final foodHistory = await _foodScanPhotoService.getAllFoodAnalysis();
      
      setState(() {
        _foodHistory = foodHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat riwayat makanan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? _buildLoadingState()
        : _errorMessage != null
            ? _buildErrorState()
            : _foodHistory.isEmpty
                ? _buildEmptyState()
                : _buildFoodHistoryList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: primaryPink),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
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
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_food, size: 64, color: primaryYellow),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat makanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pindai makanan Anda untuk mulai melacak asupan nutrisi',
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
  }

  void _navigateToFoodDetail(FoodAnalysisResult food) {
    debugPrint('Navigating to food detail');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailPage(food: food)),
    );
  }

  Widget _buildFoodHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _foodHistory.length,
      itemBuilder: (context, index) {
        final food = _foodHistory[index];
        return GestureDetector(
          onTap: () => _navigateToFoodDetail(food),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food image or placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: food.foodImageUrl != null && food.foodImageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                food.foodImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.fastfood,
                                    size: 40,
                                    color: primaryPink,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.fastfood,
                              size: 40,
                              color: primaryPink,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.foodName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildNutrientBadge(
                                'Kalori',
                                '${food.nutritionInfo.calories.toInt()} kkal',
                                primaryPink,
                              ),
                              const SizedBox(width: 8),
                              _buildNutrientBadge(
                                'Protein',
                                '${food.nutritionInfo.protein.toInt()}g',
                                primaryGreen,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
