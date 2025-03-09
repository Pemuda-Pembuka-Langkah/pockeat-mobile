import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  const CardioInputPage({
    super.key, 
    this.repository,
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

  // GlobalKeys for each form
  final GlobalKey<RunningFormState> _runningFormKey = GlobalKey<RunningFormState>();
  final GlobalKey<CyclingFormState> _cyclingFormKey = GlobalKey<CyclingFormState>();
  final GlobalKey<SwimmingFormState> _swimmingFormKey = GlobalKey<SwimmingFormState>();

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
    _repository = widget.repository ?? CardioRepositoryImpl(firestore: FirebaseFirestore.instance);
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
              
              // Create and save activity object
              _saveActivity(calories);
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
  
  // Function to save activity
  Future<void> _saveActivity(double calories) async {
    try {
      CardioActivity? activity;
      DateTime now = DateTime.now();
      
      switch (selectedType) {
        case CardioType.running:
          activity = RunningActivity(
            date: DateTime(now.year, now.month, now.day),
            startTime: DateTime(
              now.year, now.month, now.day, 
              now.hour, now.minute
            ).subtract(runningDuration),
            endTime: DateTime(now.year, now.month, now.day, now.hour, now.minute),
            distanceKm: runningDistance,
            caloriesBurned: calories,
          );
          break;
          
        case CardioType.cycling:
          activity = CyclingActivity(
            date: DateTime(now.year, now.month, now.day),
            startTime: DateTime(
              now.year, now.month, now.day, 
              now.hour, now.minute
            ).subtract(cyclingDuration),
            endTime: DateTime(now.year, now.month, now.day, now.hour, now.minute),
            distanceKm: cyclingDistance,
            cyclingType: _parseCyclingType(cyclingType),
            caloriesBurned: calories,
          );
          break;
          
        case CardioType.swimming:
          activity = SwimmingActivity(
            date: DateTime(now.year, now.month, now.day),
            startTime: DateTime(
              now.year, now.month, now.day, 
              now.hour, now.minute
            ).subtract(swimmingDuration),
            endTime: DateTime(now.year, now.month, now.day, now.hour, now.minute),
            laps: swimmingLaps,
            poolLength: poolLength,
            stroke: swimmingStroke,
            caloriesBurned: calories,
          );
          break;
      }
      
      // Save using repository
      await _repository.saveCardioActivity(activity);
          
      // Show success message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Activity successfully saved! Calories burned: ${calories.toStringAsFixed(0)} kcal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: primaryPink,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _navigateAfterSave();
      
    } catch (e) {
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save activity. Please try again.',
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
  
  // Separate method for navigation to make testing easier
  void _navigateAfterSave() {
    // Simply show a success message without navigation for better testability
    // Navigation can be handled by the parent widget if needed
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