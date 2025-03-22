import 'package:flutter/material.dart';
import 'package:pockeat/features/sync_fitness_tracker/services/health_connect_sync.dart';

class HealthConnectWidget extends StatefulWidget {
  final Color primaryColor;

  const HealthConnectWidget({
    super.key,
    this.primaryColor = const Color(0xFFFF6B6B),
  });

  @override
  State<HealthConnectWidget> createState() => _HealthConnectWidgetState();
}

class _HealthConnectWidgetState extends State<HealthConnectWidget>
    with WidgetsBindingObserver {
  final FitnessTrackerSync _fitnessSync = FitnessTrackerSync();
  int _steps = 0;
  double _calories = 0;
  bool _isLoading = false;
  bool _isConnected = false;
  bool _isHealthConnectAvailable = true;
  bool _hasAttemptedConnection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAvailabilityAndPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has resumed from background, check permissions again
      if (_hasAttemptedConnection) {
        _checkPermissionsAfterResume();
      }
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
        final hasPermissions =
            await _fitnessSync.initializeAndCheckPermissions();
        setState(() {
          _isHealthConnectAvailable = true;
          _isConnected = hasPermissions;
          _isLoading = false;
        });

        if (hasPermissions) {
          // Try to load data even if we're not sure about permissions
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
      });
    }
  }

  Future<void> _checkPermissionsAfterResume() async {
    debugPrint('Checking permissions after app resume');

    setState(() {
      _isLoading = true;
    });

    try {
      // Try more aggressive permission check
      bool hasPermissions = false;

      // First try direct data read
      try {
        await _fitnessSync.performForcedDataRead();
        hasPermissions = true;
      } catch (e) {
        debugPrint('Error with forced data read: $e');
        // Fall back to permission check
        hasPermissions = await _fitnessSync.hasRequiredPermissions();
      }

      // If we think we now have permissions, try to load data
      if (hasPermissions) {
        _fitnessSync.setPermissionGranted(); // Manually set permission state
        setState(() {
          _isConnected = true;
        });
        _loadFitnessData();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking permissions after resume: $e');
      setState(() {
        _isLoading = false;
      });

      // Try loading data anyway as a fallback
      _loadFitnessDataWithFailSafe();
    }
  }

  // Try to load fitness data even if permission checks are failing
  Future<void> _loadFitnessDataWithFailSafe() async {
    try {
      final data = await _fitnessSync.getTodayFitnessData();

      // If we get data, update the UI and consider ourselves connected
      if (data['steps'] > 0 || data['calories'] > 0) {
        setState(() {
          _steps = data['steps'] ?? 0;
          _calories = (data['calories'] ?? 0);
          _isConnected = true;
          _isLoading = false;
        });

        // Update the permission state in the service
        _fitnessSync.setPermissionGranted();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error in failsafe fitness data load: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFitnessData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _fitnessSync.getTodayFitnessData();

      // If we successfully got data, consider permissions granted
      if (data['steps'] > 0 || data['calories'] > 0) {
        _fitnessSync.setPermissionGranted();
      }

      setState(() {
        _steps = data['steps'] ?? 0;
        _calories = (data['calories'] ?? 0);
        _isLoading = false;
        _isConnected = true;
      });
    } catch (e) {
      debugPrint('Error loading fitness data: $e');
      setState(() {
        _isLoading = false;
      });

      // Try direct permission request as fallback
      final granted = await _fitnessSync.requestAuthorization();
      if (granted) {
        _loadFitnessDataWithFailSafe();
      }
    }
  }

  Future<void> _showPermissionsTutorial() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Connect Permissions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please follow these steps in Health Connect:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInstructionStep(1, 'Tap on "App permissions"'),
              _buildInstructionStep(2, 'Find and tap on "Pockeat"'),
              _buildInstructionStep(3, 'Enable ALL permissions:'),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('• Steps'),
                    Text('• Active energy burned'),
                    Text('• Total calories burned'),
                  ],
                ),
              ),
              _buildInstructionStep(4, 'Return to Pockeat app'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Important: Make sure all toggles are turned ON for Pockeat in Health Connect',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
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
              _connectToHealthServices();
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

  Widget _buildInstructionStep(int number, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
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

  Future<void> _connectToHealthServices() async {
    setState(() {
      _isLoading = true;
      _hasAttemptedConnection = true;
    });

    try {
      if (!_isHealthConnectAvailable) {
        await _showInstallHealthConnectDialog();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Try direct authorization first
      final granted = await _fitnessSync.requestAuthorization();
      if (granted) {
        setState(() {
          _isConnected = true;
        });
        _loadFitnessData();
        return;
      }

      // If direct authorization failed, open Health Connect
      // ignore: use_build_context_synchronously
      await _fitnessSync.openHealthConnect(context);

      // We'll check permissions when the app resumes via didChangeAppLifecycleState
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error connecting to health services: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Health Connect card - only show if not connected
          if (!_isConnected) _buildConnectCard(),

          const SizedBox(height: 12),

          // Steps section
          _buildStepsCard(),

          const SizedBox(height: 12),

          // Calories section
          _buildCaloriesCard(),

          // Refresh button - only show if connected
          if (_isConnected)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildRefreshButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectCard() {
    return GestureDetector(
      onTap: _isLoading ? null : _showPermissionsTutorial,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                      Icons.favorite,
                      color: widget.primaryColor,
                      size: 16,
                    ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect Health Connect',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'to track your steps and calories',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
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
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.refresh, size: 18),
      label: const Text('Refresh Health Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.directions_walk_outlined,
                size: 16,
                color: Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                'Steps',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isLoading ? '-' : '$_steps',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$_steps',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard() {
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
          const Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 16,
                color: Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                'Calories burned',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isLoading ? '-' : '${_calories.toInt()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${_calories.toInt()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
