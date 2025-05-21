// free_trials_page.dart

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../widgets/pricing_option.dart';
import '../widgets/timeline_item.dart';

class FreeTrialPage extends StatefulWidget {
  const FreeTrialPage({super.key});

  @override
  State<FreeTrialPage> createState() => _FreeTrialPageState();
}

class _FreeTrialPageState extends State<FreeTrialPage>
    with SingleTickerProviderStateMixin {
  // Colors based on app design
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryBlue = const Color(0xFF2A7FFF);
  final Color textDarkColor = Colors.black87;
  final Color textLightColor = Colors.black54;
  final Color orangeColor = const Color(0xFFFF9F40);
  final Color purpleColor = const Color(0xFF5E60CE);
  final Color redColor = const Color(0xFFFF6B6B);

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Calculate trial and billing dates
  DateTime get todayDate => DateTime.now();
  DateTime get reminderDate => todayDate.add(const Duration(days: 5));
  DateTime get billingDate => todayDate.add(const Duration(days: 7));

  // Pricing constants
  final int monthlyPrice = 15000;
  final int yearlyPrice =
      (15000 * 12 * 0.67).toInt(); // 33% discount for yearly

  // Track selected pricing option
  bool _isMonthlySelected = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Format for displaying dates
  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back button on top left
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.arrow_back,
                                color: textDarkColor, size: 20),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Main explanation card
                      Container(
                        margin: const EdgeInsets.only(top: 40, bottom: 32),
                        padding: const EdgeInsets.symmetric(
                            vertical: 32, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'This app is still in development.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textDarkColor,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'You only get to access the app for 7 days.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                color: textLightColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'To get full access, apply to be our beta tester so that we can publish the app.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Center(
                              child: Material(
                                color: primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    final url =
                                        Uri.parse('https://pockeat.online');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 18),
                                    child: Text(
                                      'pockeat.online',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Timeline card with panda glued to it
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildTimelineItem(
                                  day: 'Today',
                                  message:
                                      'Access all app features like AI, pet companion, and more',
                                  icon: Icons.check_circle,
                                  color: orangeColor,
                                  isFirst: true,
                                ),
                                _buildTimelineItem(
                                  day: 'During Trial',
                                  message:
                                      'You\'ll get a notification before your access ends',
                                  icon: Icons.notifications_active,
                                  color: purpleColor,
                                ),
                                _buildTimelineItem(
                                  day: 'In 7 Days - Access Ends',
                                  message:
                                      'Your free access will end. Apply as a beta tester for more!',
                                  icon: Icons.lock_outline,
                                  color: redColor,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -48,
                            left: -30,
                            child: Image.asset(
                              'assets/images/panda_pointing_commision.png',
                              width: 110,
                              height: 110,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Beta tester call to action
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Apply at pockeat.online to become a beta tester.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textLightColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Start My Trial button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryGreen.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          child: const Text(
                            'Start My Trial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String day,
    required String message,
    required IconData icon,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TimelineItem(
      day: day,
      message: message,
      icon: icon,
      color: color,
      isFirst: isFirst,
      isLast: isLast,
      textDarkColor: textDarkColor,
      textLightColor: textLightColor,
    );
  }
}
