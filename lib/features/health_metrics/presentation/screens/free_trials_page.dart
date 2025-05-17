// free_trials_page.dart

// Flutter imports:
import 'package:flutter/material.dart';

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

                      // Trial Header
                      Text(
                        'Start your 7-day FREE\ntrial to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textDarkColor,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Subheader
                      Text(
                        'Experience all features without limits.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: textLightColor,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Timeline items with cards
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
                              day: 'In 5 Days - Reminder',
                              message:
                                  'You\'ll receive a friendly notification',
                              icon: Icons.notifications_active,
                              color: purpleColor,
                            ),
                            _buildTimelineItem(
                              day: 'In 7 Days - Billing Starts',
                              message:
                                  'You\'ll be charged on ${formatDate(billingDate)}',
                              icon: Icons.calendar_today,
                              color: redColor,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Pricing options
                      Text(
                        'Choose Your Plan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDarkColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isMonthlySelected = true;
                                });
                              },
                              child: _buildPricingOption(
                                title: 'Monthly',
                                price: monthlyPrice,
                                isSelected: _isMonthlySelected,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isMonthlySelected = false;
                                });
                              },
                              child: _buildPricingOption(
                                title: 'Yearly',
                                price: yearlyPrice,
                                discount: '33%',
                                isSelected: !_isMonthlySelected,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // No Payment text
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'No Payment Due Now',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Start Trial Button with glow effect
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
                            // Start free trial logic here
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          child: const Text(
                            'Start My 7-Day Free Trial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Terms text
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'By proceeding, you agree to our Terms of Service',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textLightColor,
                              fontSize: 13,
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

  Widget _buildPricingOption({
    required String title,
    required int price,
    String? discount,
    required bool isSelected,
  }) {
    return PricingOption(
      title: title,
      price: price,
      discount: discount,
      isSelected: isSelected,
      primaryGreen: primaryGreen,
      textDarkColor: textDarkColor,
      textLightColor: textLightColor,
    );
  }
}
