import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:get_it/get_it.dart';

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

  @override
  void initState() {
    super.initState();
    _analyticsService = GetIt.instance<AnalyticsService>();
    _analyticsService.logScreenView(
        screenName: 'food_input_page', screenClass: 'FoodInputPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Food',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
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
            const SizedBox(height: 16),

            // Manual Input Option
            _buildInputOption(
              context: context,
              icon: CupertinoIcons.text_justify,
              title: 'Input Manually',
              subtitle: 'Search or prompt food details',
              color: primaryPink,
              route: '/food-text-input',
            ),
            const SizedBox(height: 16),

            _buildInputOption(
              context: context,
              icon: CupertinoIcons.bell,
              title: 'Notification Settings',
              subtitle: 'Set your notification preferences',
              color: primaryGreen,
              route: '/notification-settings',
            ),
          ],
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
    return SizedBox(
      height: 100,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: route != null
              ? () {
                  // Track navigation event based on route
                  if (route == '/scan') {
                    _analyticsService.logEvent(
                      name: 'food_input_method_selected',
                      parameters: {
                        'method': 'scan',
                        'timestamp': DateTime.now().toIso8601String(),
                      },
                    );
                  } else if (route == '/food-text-input') {
                    _analyticsService.logEvent(
                      name: 'food_input_method_selected',
                      parameters: {
                        'method': 'text',
                        'timestamp': DateTime.now().toIso8601String(),
                      },
                    );
                  } else if (route == '/notification-settings') {
                    _analyticsService.logEvent(
                      name: 'view_notification_settings',
                      parameters: {
                        'source': 'food_input_page',
                        'timestamp': DateTime.now().toIso8601String(),
                      },
                    );
                  }
                  Navigator.pushNamed(context, route);
                }
              : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
