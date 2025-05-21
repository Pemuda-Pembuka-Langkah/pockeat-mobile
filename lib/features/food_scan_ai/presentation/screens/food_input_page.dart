//coverage:ignore-file

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/free_limit/services/free_limit_service.dart';

class FoodInputPage extends StatefulWidget {
  const FoodInputPage({super.key});

  @override
  State<FoodInputPage> createState() => _FoodInputPageState();
}

class _FoodInputPageState extends State<FoodInputPage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  late final AnalyticsService _analyticsService;
  late final FreeLimitService _freeLimitService;

  @override
  void initState() {
    super.initState();
    // Initialize services
    _analyticsService = GetIt.instance<AnalyticsService>();
    _freeLimitService = GetIt.instance<FreeLimitService>();

    // Track analytics
    _analyticsService.logScreenView(
        screenName: 'food_input_page', screenClass: 'FoodInputPage');

    // Check trial validity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTrialValidity();
    });
  }

  // Check if user can access this feature
  Future<void> _checkTrialValidity() async {
    await _freeLimitService.checkAndRedirect(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to the root route instead of just popping
        await Navigator.of(context).pushReplacementNamed('/');
        return false; // Prevents default pop behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          title: const Text(
            'Add Food',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Replace Column with SingleChildScrollView to handle overflow
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // add button to go to notification settings

                    Text(
                      'How would you like to\nadd your food?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Scan Option
                _buildInputOption(
                  context: context,
                  icon: CupertinoIcons.camera_viewfinder,
                  title: 'Scan Food',
                  subtitle: 'Take a photo of your food',
                  color: primaryGreen,
                  route: '/scan',
                ),
                const SizedBox(height: 20),

                // Manual Text Input Option
                _buildInputOption(
                  context: context,
                  icon: CupertinoIcons.text_justify,
                  title: 'Explain your meal',
                  subtitle: 'Generate your meal\'s data with our AI',
                  color: primaryPink,
                  route: '/food-text-input',
                ),
                const SizedBox(height: 20),

                // Database Option
                _buildInputOption(
                  context: context,
                  icon: CupertinoIcons.table,
                  title: 'Create Your Own Meal',
                  subtitle: 'Choose ingredients from our nutrition database',
                  color: Colors.blue,
                  route: '/nutrition-database',
                ),
                const SizedBox(height: 20),

                // Saved Meals Option
                _buildInputOption(
                  context: context,
                  icon: CupertinoIcons.bookmark_fill,
                  title: 'Saved Meals',
                  subtitle: 'Choose from your previously saved meals',
                  color: Colors.amber,
                  route: '/saved-meals',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? route,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 26,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}