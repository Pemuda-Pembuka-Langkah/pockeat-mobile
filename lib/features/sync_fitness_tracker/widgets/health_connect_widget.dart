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

      setState(() {
        _steps = data['steps'] ?? 0;
        _calories = (data['calories'] ?? 0);
        _isLoading = false;
        _isConnected = hasPermissions;
      });
    } catch (e) {
      debugPrint('Error loading fitness data: $e');
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  Future<void> _requestAuthorization() async {
    try {
      final granted = await _fitnessSync.requestAuthorization();

      if (granted) {
        setState(() {
          _isConnected = true;
        });

        // Try loading data again
        _loadFitnessData();
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    } catch (e) {
      debugPrint('Error requesting authorization: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _showPermissionsTutorial() async {
    return showDialog(
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
              // Directly open Health Connect from here
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
      onTap: _isLoading
          ? null
          : () {
              debugPrint('Connect to Health Connect button tapped');
              _connectToHealthServices();
            },
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
