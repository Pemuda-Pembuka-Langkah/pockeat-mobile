import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/calorie_calculator.dart';
import '../widgets/cycling_form.dart';
import '../widgets/running_form.dart';
import '../widgets/swimming_form.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/cardio_repository.dart';
import '../../domain/repositories/cardio_repository_impl.dart';

// Using CardioType from model for consistency
// enum CardioType { running, cycling, swimming }

class CardioInputPage extends StatefulWidget {
  final CardioRepository? repository;
  final FirebaseAuth? auth; // Add this parameter

  const CardioInputPage({
    super.key,
    this.repository,
    this.auth,
  });

  @override
  CardioInputPageState createState() => CardioInputPageState();
}

class CardioInputPageState extends State<CardioInputPage> {
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);

  // Repository to store data
  late CardioRepository _repository;
  late FirebaseAuth _auth;

  // GlobalKeys for each form
  final GlobalKey<RunningFormState> _runningFormKey =
      GlobalKey<RunningFormState>();
  final GlobalKey<CyclingFormState> _cyclingFormKey =
      GlobalKey<CyclingFormState>();
  final GlobalKey<SwimmingFormState> _swimmingFormKey =
      GlobalKey<SwimmingFormState>();

  // Type of activity selected
  CardioType selectedType = CardioType.running;

  // Current form widgets
  RunningForm? runningForm;
  CyclingForm? cyclingForm;
  SwimmingForm? swimmingForm;

  // Variables to track the latest data from forms
  double runningDistance = 5.0;
  Duration runningDuration = const Duration(minutes: 30);

  double cyclingDistance = 5.0;
  Duration cyclingDuration = const Duration(minutes: 30);
  String cyclingType = "mountain";

  int swimmingLaps = 10;
  double poolLength = 25.0;
  String swimmingStroke = "Freestyle (Front Crawl)";
  Duration swimmingDuration = const Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    // Initialize repository, use injected repository or create a new one
    _repository = widget.repository ??
        CardioRepositoryImpl(firestore: FirebaseFirestore.instance);
    _auth =
        widget.auth ?? FirebaseAuth.instance; // Use injected auth or default
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
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cardio Type Selection
              const Text(
                'Cardio Exercise Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildCardioTypeButton(
                      CardioType.running, 'Running', Icons.directions_run),
                  const SizedBox(width: 8),
                  _buildCardioTypeButton(
                      CardioType.cycling, 'Cycling', Icons.directions_bike),
                  const SizedBox(width: 8),
                  _buildCardioTypeButton(
                      CardioType.swimming, 'Swimming', Icons.pool),
                ],
              ),

              const SizedBox(height: 16),

              // Form fields based on selected type
              _buildFormFields(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              // Get data directly from active form
              double calories = 0;

              switch (selectedType) {
                case CardioType.running:
                  if (runningForm != null) {
                    // Get values directly from running form
                    calories = runningForm!.calculateCalories();
                  }
                  break;

                case CardioType.cycling:
                  if (cyclingForm != null) {
                    // Get values directly from cycling form
                    calories = cyclingForm!.calculateCalories();
                  }
                  break;

                case CardioType.swimming:
                  if (swimmingForm != null) {
                    // Get values directly from swimming form
                    calories = swimmingForm!.calculateCalories();
                  }
                  break;
              }

              // Create and save activity object without popping immediately
              _saveActivity(calories);
              // Remove this line to prevent immediate navigation
              // Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save ${_getActivityName()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardioTypeButton(CardioType type, String label, IconData icon) {
    bool isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryPink.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryPink : Colors.black12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primaryPink : Colors.black54),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.black54,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Callback methods to track form data
  void _updateRunningData(double distance, Duration duration) {
    runningDistance = distance;
    runningDuration = duration;
  }

  void _updateCyclingData(double distance, Duration duration, String type) {
    cyclingDistance = distance;
    cyclingDuration = duration;
    cyclingType = type;
  }

  void _updateSwimmingData(int laps, double length, Duration duration) {
    swimmingLaps = laps;
    poolLength = length;
    swimmingDuration = duration;
  }

  Widget _buildFormFields() {
    switch (selectedType) {
      case CardioType.running:
        runningForm = RunningForm(
          key: _runningFormKey,
          primaryPink: primaryPink,
          onCalculate: (distance, duration) {
            // Store the values for later
            _updateRunningData(distance, duration);
            return CalorieCalculator.calculateRunningCalories(
              distanceKm: distance,
              duration: duration,
            );
          },
        );
        return runningForm!;

      case CardioType.cycling:
        cyclingForm = CyclingForm(
          key: _cyclingFormKey,
          primaryPink: primaryPink,
          onCalculate: (distance, duration, type) {
            // Store the values for later
            _updateCyclingData(distance, duration, type);
            return CalorieCalculator.calculateCyclingCalories(
              distanceKm: distance,
              duration: duration,
              cyclingType: type,
            );
          },
          // Add this callback to update the cycling type directly when it changes
          onTypeChanged: (type) {
            cyclingType = type;
          },
        );
        return cyclingForm!;

      case CardioType.swimming:
        swimmingForm = SwimmingForm(
          key: _swimmingFormKey,
          primaryPink: primaryPink,
          onCalculate: (laps, poolLength, stroke, duration) {
            _updateSwimmingData(laps, poolLength, duration);
            swimmingStroke = stroke;
            return CalorieCalculator.calculateSwimmingCalories(
              laps: laps,
              poolLength: poolLength,
              stroke: stroke,
              duration: duration,
            );
          },
        );
        return swimmingForm!;
    }
  }

  String _getAppBarTitle() {
    switch (selectedType) {
      case CardioType.running:
        return 'Running';
      case CardioType.cycling:
        return 'Cycling';
      case CardioType.swimming:
        return 'Swimming';
    }
  }

  String _getActivityName() {
    switch (selectedType) {
      case CardioType.running:
        return 'Run';
      case CardioType.cycling:
        return 'Ride';
      case CardioType.swimming:
        return 'Swim';
    }
  }

  Future<void> _saveActivity(double calories) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';

      // Validate user is logged in
      if (userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be logged in to save activities'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Basic validation checks
      bool isValid = true;
      String errorMessage = '';
      CardioActivity? activity;
      final todayDate = DateTime.now();
      Duration activityDuration;

      switch (selectedType) {
        case CardioType.running:
          final formState = _runningFormKey.currentState!;
          activityDuration =
              formState.selectedEndTime.difference(formState.selectedStartTime);

          // Validate running inputs
          if (runningDistance <= 0) {
            isValid = false;
            errorMessage = 'Distance must be greater than 0';
          } else if (activityDuration.inSeconds <= 0) {
            isValid = false;
            errorMessage = 'Duration must be greater than 0';
          }

          if (!isValid) break;

          activity = RunningActivity(
            userId: userId,
            date: todayDate,
            startTime: formState.selectedStartTime,
            endTime: formState.selectedEndTime,
            distanceKm: runningDistance,
            caloriesBurned: calories,
          );
          break;

        case CardioType.cycling:
          final formState = _cyclingFormKey.currentState!;
          activityDuration =
              formState.selectedEndTime.difference(formState.selectedStartTime);

          // Validate cycling inputs
          if (cyclingDistance <= 0) {
            isValid = false;
            errorMessage = 'Distance must be greater than 0';
          } else if (activityDuration.inSeconds <= 0) {
            isValid = false;
            errorMessage = 'Duration must be greater than 0';
          }

          if (!isValid) break;

          activity = CyclingActivity(
            userId: userId,
            date: todayDate,
            startTime: formState.selectedStartTime,
            endTime: formState.selectedEndTime,
            distanceKm: cyclingDistance,
            cyclingType: _parseCyclingType(cyclingType),
            caloriesBurned: calories,
          );
          break;

        case CardioType.swimming:
          final formState = _swimmingFormKey.currentState!;
          activityDuration =
              formState.selectedEndTime.difference(formState.selectedStartTime);

          // Validate swimming inputs
          if (swimmingLaps <= 0) {
            isValid = false;
            errorMessage = 'Laps must be greater than 0';
          } else if (poolLength <= 0) {
            isValid = false;
            errorMessage = 'Pool length must be greater than 0';
          } else if (activityDuration.inSeconds <= 0) {
            isValid = false;
            errorMessage = 'Duration must be greater than 0';
          }

          if (!isValid) break;

          activity = SwimmingActivity(
            userId: userId,
            date: todayDate,
            startTime: formState.selectedStartTime,
            endTime: formState.selectedEndTime,
            laps: swimmingLaps,
            poolLength: poolLength,
            stroke: swimmingStroke,
            caloriesBurned: calories,
          );
          break;
      }

      // If validation failed, show error message
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Save using repository
      await _repository.saveCardioActivity(activity!);

      // Show success message to user with navigation after SnackBar is dismissed
      if (mounted) {
        final snackBar = SnackBar(
          content: Text(
            'Activity successfully saved! Calories burned: ${calories.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.fixed,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save activity: $e',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Helper method to convert string to CyclingType
  CyclingType _parseCyclingType(String typeString) {
    switch (typeString) {
      case 'mountain':
        return CyclingType.mountain;
      case 'commute':
        return CyclingType.commute;
      case 'stationary':
        return CyclingType.stationary;
      default:
        return CyclingType.mountain;
    }
  }
}
