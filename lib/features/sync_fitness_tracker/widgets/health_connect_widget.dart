//

// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/sync_fitness_tracker/services/health_connect_sync.dart';

//

class HealthConnectWidget extends StatefulWidget {
  final Color primaryColor;

  const HealthConnectWidget({
    super.key,
    this.primaryColor = const Color(0xFFFF6B6B),
  });
//coverage:ignore-start
  @override
  State<HealthConnectWidget> createState() => _HealthConnectWidgetState();
}

class _HealthConnectWidgetState extends State<HealthConnectWidget>
    with WidgetsBindingObserver {
  final FitnessTrackerSync _fitnessSync = FitnessTrackerSync();
  final _exerciseService = GetIt.instance<ExerciseLogHistoryService>();
  final _auth = FirebaseAuth.instance;

  int _steps = 0;
  double _calories = 0;
  double _exerciseCalories = 0;
  bool _isLoading = false;
  bool _isConnected = false;
  bool _isHealthConnectAvailable = true;
  bool _hasAttemptedConnection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAvailabilityAndPermissions();
    _loadExerciseCalories();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasAttemptedConnection) {
      // Only check permissions when the app resumes after a connection attempt
      // This prevents unnecessary permission checks that could cause loops
      debugPrint('App resumed after connection attempt, checking permissions');
      _checkPermissionsAfterResume();
      // Reset the flag after checking
      _hasAttemptedConnection = false;
    }
  }

  Future<void> _checkAvailabilityAndPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First check if Health Connect is available
      final isAvailable = await _fitnessSync.isHealthConnectAvailable();

      if (isAvailable) {
        // Use the initialization method which does a simple permission check
        final hasPermissions =
            await _fitnessSync.initializeAndCheckPermissions();

        setState(() {
          _isHealthConnectAvailable = true;
          _isConnected = hasPermissions;
          _isLoading = false;
        });

        if (hasPermissions) {
          // Try to load data if we have permissions
          _loadFitnessData();
        }
      } else {
        setState(() {
          _isHealthConnectAvailable = false;
          _isConnected = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking Health Connect: $e');
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  Future<void> _checkPermissionsAfterResume() async {
    debugPrint('Checking permissions after app resume');

    setState(() {
      _isLoading = true;
    });

    try {
      // Always do a direct permission check
      final hasPermissions = await _fitnessSync.hasRequiredPermissions();
      debugPrint('Permission check after resume: $hasPermissions');

      setState(() {
        _isConnected = hasPermissions;
        _isLoading = false;
      });

      if (hasPermissions) {
        debugPrint('Permissions granted, loading fitness data');
        // Load data if we have permissions
        _loadFitnessData();
      } else {
        debugPrint('Permissions still not granted after resume');
      }
    } catch (e) {
      debugPrint('Error checking permissions after resume: $e');
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  Future<void> _loadFitnessData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _fitnessSync.getTodayFitnessData();

      // Check if we still have permissions from the returned data
      final hasPermissions = data['hasPermissions'] != false;

      // If we've lost permissions, reset tracker data
      if (_isConnected && !hasPermissions) {
        debugPrint('Lost Health Connect permissions, resetting tracker data');
        await _fitnessSync.resetTrackerData();
      }

      setState(() {
        _steps = data['steps'] ?? 0;
        _calories = (data['calories'] ?? 0);
        _isLoading = false;
        _isConnected = hasPermissions;
      });

      // Reload exercise calories in case tracker data was reset
      if (!hasPermissions) {
        await _loadExerciseCalories();
      }
    } catch (e) {
      debugPrint('Error loading fitness data: $e');
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  Future<void> _loadExerciseCalories() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        setState(() {
          _exerciseCalories = 0;
        });
        return;
      }

      // Get today's exercise logs
      final today = DateTime.now();
      final exerciseLogs =
          await _exerciseService.getExerciseLogsByDate(userId, today);

      // Sum up calories burned from exercise logs
      double totalCalories = 0;
      for (final log in exerciseLogs) {
        totalCalories += log.caloriesBurned.toDouble();
      }

      setState(() {
        _exerciseCalories = totalCalories;
      });

      debugPrint('Loaded exercise calories: $_exerciseCalories');
    } catch (e) {
      debugPrint('Error loading exercise calories: $e');
      setState(() {
        _exerciseCalories = 0;
      });
    }
  }

  Future<void> _showInstallHealthConnectDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Connect Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 48,
              color: Color.fromARGB(255, 123, 162, 194),
            ),
            SizedBox(height: 16),
            Text(
              'Health Connect is required to track your fitness data.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please install Health Connect from the Google Play Store to continue.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // ignore: invalid_use_of_protected_member
              _fitnessSync.openHealthConnectPlayStore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
            ),
            child: const Text('Install Health Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _showHealthConnectExplanation() async {
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
              color: Color(0xFFFF6B6B),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // ignore: invalid_use_of_protected_member
              _fitnessSync.openHealthConnect(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
            ),
            child: const Text('Open Health Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToHealthServices() async {
    setState(() {
      _isLoading = true;
      _hasAttemptedConnection = true; // Set flag to check permissions on resume
    });

    try {
      if (!_isHealthConnectAvailable) {
        await _showInstallHealthConnectDialog();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Try requesting authorization directly first
      debugPrint('Requesting Health Connect authorization directly...');
      final granted = await _fitnessSync.requestAuthorization();

      if (granted) {
        debugPrint('Authorization granted directly');
        setState(() {
          _isConnected = true;
          _isLoading = false;
        });
        _loadFitnessData();
        return;
      }

      // If direct authorization failed, show explanation and launch Health Connect
      debugPrint('Direct authorization failed, showing explanation...');
      await _showHealthConnectExplanation();

      // We'll check permissions when the app resumes
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error connecting to health services: $e');
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Always show both cards but format them differently based on connection status
            Row(
              children: [
                Expanded(child: _buildStepsCard()),
                const SizedBox(width: 10),
                Expanded(child: _buildCaloriesCard()),
              ],
            ),

            const SizedBox(height: 12),

            // Health Connect card - only show if not connected
            if (!_isConnected)
              _buildConnectCard()
            else
              Center(
                child: SizedBox(
                  height: 42,
                  child: _buildRefreshButton(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectCard() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              debugPrint('Connect to Health Connect button tapped');
              _connectToHealthServices();
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: widget.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                      ),
                    )
                  : Icon(
                      Icons.fitness_center,
                      color: widget.primaryColor,
                      size: 16,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Connect Health Connect',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Get more accurate fitness data',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white60,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _loadFitnessData,
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.refresh, size: 20),
      label: const Text('Refresh', style: TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(120, 42),
        maximumSize: const Size(180, 42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isConnected ? Colors.black54 : Colors.black26,
                      ),
                    ),
                  ),
                  if (!_isConnected)
                    GestureDetector(
                      onTap: _connectToHealthServices,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Connect',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isLoading
                    ? '-'
                    : _isConnected
                        ? '$_steps'
                        : '- - -',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isConnected ? Colors.black87 : Colors.black26,
                ),
              ),
              const SizedBox(height: 8),
              // Add a row with spacer to match the calories card height
              if (_isConnected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$_steps',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                // Empty spacer when not connected to match height
                const SizedBox(height: 23),
            ],
          ),
          // Show a blur overlay when not connected
          if (!_isConnected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard() {
    // Calculate the total calories and display differently based on connection status
    final totalCalories = _exerciseCalories + (_isConnected ? _calories : 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Calories Burned',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Show total calories
          Text(
            _isLoading ? '-' : '${totalCalories.toInt()}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Show the breakdown of calories in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Always show exercise calories indicator (even when zero)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4)
                      .withOpacity(_exerciseCalories > 0 ? 0.1 : 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fitness_center,
                        size: 12,
                        color: Color(0xFF4ECDC4)
                            .withOpacity(_exerciseCalories > 0 ? 1.0 : 0.5)),
                    const SizedBox(width: 3),
                    Text(
                      '${_exerciseCalories.toInt()}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4ECDC4)
                            .withOpacity(_exerciseCalories > 0 ? 1.0 : 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Health Connect calories (always show if connected)
              if (_isConnected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.primaryColor
                        .withOpacity(_calories > 0 ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.heart_broken,
                          size: 12,
                          color: widget.primaryColor
                              .withOpacity(_calories > 0 ? 1.0 : 0.5)),
                      const SizedBox(width: 3),
                      Text(
                        '${_calories.toInt()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.primaryColor
                              .withOpacity(_calories > 0 ? 1.0 : 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
//coverage:ignore-end
}
