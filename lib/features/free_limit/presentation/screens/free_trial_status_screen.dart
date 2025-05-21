// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';

class FreeTrialStatusScreen extends StatefulWidget {
  const FreeTrialStatusScreen({super.key});

  @override
  State<FreeTrialStatusScreen> createState() => _FreeTrialStatusScreenState();
}

class _FreeTrialStatusScreenState extends State<FreeTrialStatusScreen>
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

  // User data
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  late final LoginService _loginService;

  // Days left calculation
  int get _daysLeft {
    if (_currentUser?.freeTrialEndsAt == null) return 0;

    final now = DateTime.now();
    final end = _currentUser!.freeTrialEndsAt!;

    if (now.isAfter(end)) return 0;

    return end.difference(now).inDays + 1; // +1 to include today
  }

  // Trial status indicator
  String get _trialStatusText {
    final daysLeft = _daysLeft;
    if (daysLeft <= 0) {
      return 'Your free trial has ended';
    } else if (daysLeft == 1) {
      return 'Final day of your free trial';
    } else {
      return '$daysLeft days left in your free trial';
    }
  }

  // Trial progress percentage
  double get _trialProgressPercentage {
    // Assuming trial is 7 days
    const totalDays = 7;
    final daysLeft = _daysLeft;

    if (daysLeft <= 0) return 1.0; // Trial ended (100% complete)
    if (daysLeft >= totalDays) return 0.0; // Just started (0% complete)

    return (totalDays - daysLeft) / totalDays;
  }

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();
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
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Format for displaying dates
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Load user data
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _loginService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Free Trial Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildTrialStatusView(),
    );
  }

  /// Widget to display error view
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: redColor,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load free trial status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget to display trial status view
  Widget _buildTrialStatusView() {
    return SafeArea(
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
                    const SizedBox(height: 20),
                    // Trial status card
                    _buildTrialStatusCard(),
                    const SizedBox(height: 24),
                    // Trial details card
                    _buildTrialDetailsCard(),
                    const SizedBox(height: 24),
                    // Beta tester promotion card
                    _buildBetaTesterCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Trial status card with progress bar
  Widget _buildTrialStatusCard() {
    final Color statusColor = _daysLeft <= 2
        ? redColor
        : _daysLeft <= 4
            ? orangeColor
            : primaryGreen;

    return Container(
      padding: const EdgeInsets.all(24),
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
          // Trial status icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _daysLeft <= 0
                  ? Icons.lock_outline
                  : _daysLeft <= 2
                      ? Icons.access_time_filled
                      : Icons.timer_outlined,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // Trial status text
          Text(
            _trialStatusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 24),
          // Progress bar
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _trialProgressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Start and end dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Started: ${formatDate(_currentUser?.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Ends: ${formatDate(_currentUser?.freeTrialEndsAt)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textDarkColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Trial details card with information
  Widget _buildTrialDetailsCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Free Trial',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.check_circle_outline,
            text: 'Full access to AI features',
            color: primaryGreen,
          ),
          _buildInfoItem(
            icon: Icons.check_circle_outline,
            text: 'Complete tracking capabilities',
            color: primaryGreen,
          ),
          _buildInfoItem(
            icon: Icons.check_circle_outline,
            text: 'Personalized pet companion',
            color: primaryGreen,
          ),
          _buildInfoItem(
            icon: Icons.check_circle_outline,
            text: 'Detailed health metrics analysis',
            color: primaryGreen,
          ),
          if (_daysLeft <= 0)
            _buildInfoItem(
              icon: Icons.cancel_outlined,
              text: 'Your trial has ended',
              color: redColor,
            )
          else
            _buildInfoItem(
              icon: Icons.info_outline,
              text: 'Access will end in $_daysLeft days',
              color: _daysLeft <= 2 ? redColor : orangeColor,
            ),
        ],
      ),
    );
  }

  // Beta tester promotion card
  Widget _buildBetaTesterCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Become a Beta Tester',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Help us improve Pockeat and get extended access by becoming a beta tester!',
                style: TextStyle(
                  fontSize: 14,
                  color: textLightColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Benefits:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textDarkColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildBenefitItem('Extended app access', primaryGreen),
              _buildBenefitItem('Early feature previews', primaryGreen),
              _buildBenefitItem('Direct feedback channel', primaryGreen),
              _buildBenefitItem('Help shape the app\'s future', primaryGreen),
              const SizedBox(height: 24),
              Center(
                child: Material(
                  color: primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final url = Uri.parse('https://pockeat.online');
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
        Positioned(
          bottom: -30,
          right: -20,
          child: Image.asset(
            'assets/images/panda_pointing_commision.png',
            width: 100,
            height: 100,
          ),
        ),
      ],
    );
  }

  // Helper method to build info item
  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textDarkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build benefit item
  Widget _buildBenefitItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.star_outline, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textLightColor,
            ),
          ),
        ],
      ),
    );
  }
}
