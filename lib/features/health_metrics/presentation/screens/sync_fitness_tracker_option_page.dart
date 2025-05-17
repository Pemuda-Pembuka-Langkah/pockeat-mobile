// sync_fitness_tracker_option_page.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';
import 'package:pockeat/features/sync_fitness_tracker/services/health_connect_sync.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

class SyncFitnessTrackerOptionPage extends StatefulWidget {
  const SyncFitnessTrackerOptionPage({super.key});

  @override
  State<SyncFitnessTrackerOptionPage> createState() =>
      _SyncFitnessTrackerOptionPageState();
}

class _SyncFitnessTrackerOptionPageState
    extends State<SyncFitnessTrackerOptionPage>
    with SingleTickerProviderStateMixin {
  // Colors from the app's design system
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color textDarkColor = Colors.black87;
  final Color textLightColor = Colors.black54;
  // User preference state
  bool? _syncFitnessTracker;

  // Service for managing user preferences
  late UserPreferencesService _userPreferencesService;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    // Initialize services
    _userPreferencesService = GetIt.instance<UserPreferencesService>();

    // Load saved preference
    _loadSyncFitnessTrackerPreference();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  /// Load sync fitness tracker preference
  Future<void> _loadSyncFitnessTrackerPreference() async {
    try {
      // Get setting from UserPreferencesService
      final enabled =
          await _userPreferencesService.isSyncFitnessTrackerEnabled();

      setState(() {
        _syncFitnessTracker = enabled;
      });
    } catch (e) {
      debugPrint('Error loading sync fitness tracker setting: $e');
    }
  }

  /// Save sync fitness tracker setting using UserPreferencesService
  Future<void> _saveSyncFitnessTrackerSetting(bool value) async {
    try {
      // Save using UserPreferencesService
      await _userPreferencesService.setSyncFitnessTrackerEnabled(value);

      setState(() {
        _syncFitnessTracker = value;
      });
    } catch (e) {
      debugPrint('Error saving sync fitness tracker setting: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save preference'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
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
            child: Icon(Icons.arrow_back, color: textDarkColor, size: 20),
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                bgColor,
              ],
              stops: const [0.0, 0.6],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Onboarding progress indicator
                const OnboardingProgressIndicator(
                  totalSteps: 16,
                  currentStep: 14, // This is the 15th step (0-indexed)
                  barHeight: 6.0,
                  showPercentage: true,
                ),

                const SizedBox(height: 20),

                // Title with modern style
                const Text(
                  "Health Trackers",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Connect to a fitness tracker to sync your activity data",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 32),

                // Main content in a white container with shadow
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Scrollable content area
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Fitness tracker illustration
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: primaryGreen.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.watch,
                                        size: 64,
                                        color: primaryGreen,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Title
                                    const Text(
                                      "Connect to Health Tracker",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 16),

                                    // Description
                                    Text(
                                      "PockEat can automatically import activity data from the most popular third party tracker which is Health Connect!",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textLightColor,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 16),

                                    // Benefits
                                    _buildBenefitItem(
                                      icon: Icons.autorenew,
                                      text:
                                          "Automatic exercise calorie adjustment",
                                    ),

                                    _buildBenefitItem(
                                      icon: Icons.trending_up,
                                      text: "Integrated tracking",
                                    ),

                                    _buildBenefitItem(
                                      icon: Icons.insights,
                                      text: "Better insights on your progress",
                                    ),

                                    // Add bottom padding for scrollable area
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),

                            // Fix buttons at the bottom

                            const SizedBox(
                                height: 16), // Connect to Health Connect button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  // Save preference that user wants to sync fitness tracker
                                  await _saveSyncFitnessTrackerSetting(true);

                                  // Create an instance of FitnessTrackerSync to request permissions
                                  // Use GetIt to allow mocking in tests
                                  final fitnessSync =
                                      GetIt.instance<FitnessTrackerSync>();

                                  try {
                                    // Check if Health Connect is available
                                    final isAvailable = await fitnessSync
                                        .isHealthConnectAvailable();

                                    if (isAvailable) {
                                      // Show explanation dialog
                                      await _showHealthConnectExplanation(
                                          context, fitnessSync);
                                    }
                                  } catch (e) {
                                    debugPrint(
                                        'Error checking Health Connect: $e');
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryGreen,
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: primaryGreen,
                                      width: 1.5,
                                    ),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: const Icon(Icons.fitness_center),
                                label: const Text(
                                  'Open Health Connect',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Skip button
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () async {
                                  // Save preference that user does not want to sync fitness tracker
                                  await _saveSyncFitnessTrackerSetting(false);
                                  if (context.mounted) {
                                    Navigator.pushNamed(
                                        context, '/pet-onboard');
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: textDarkColor,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: _syncFitnessTracker == false
                                          ? primaryGreen.withOpacity(0.5)
                                          : Colors.grey.shade300,
                                      width:
                                          _syncFitnessTracker == false ? 2 : 1,
                                    ),
                                  ),
                                  backgroundColor: _syncFitnessTracker == false
                                      ? Colors.grey.shade50
                                      : null,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_syncFitnessTracker == false)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: textDarkColor,
                                          size: 18,
                                        ),
                                      ),
                                    const Text(
                                      'Not Now',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show Health Connect permission explanation dialog
  Future<void> _showHealthConnectExplanation(
      BuildContext context, FitnessTrackerSync fitnessSync) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connect to Health Connect'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 48,
              color: Color(0xFF4ECDC4),
            ),
            SizedBox(height: 16),
            Text(
              'We need to access your fitness data from Health Connect.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'When Health Connect opens, please select "Allow" for Steps, Active energy burned, and Total calories burned.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Request authorization directly
              fitnessSync.requestAuthorization();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
            ),
            child: const Text('Open Health Connect'),
          ),
        ],
      ),
    );
  }

  // Benefit item with icon and text
  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textDarkColor,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
