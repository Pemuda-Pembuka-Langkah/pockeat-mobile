import 'package:flutter/material.dart';
import '../../services/calorie_calculator.dart';
import '../widgets/cycling_form.dart';
import '../widgets/running_form.dart';
import '../widgets/swimming_form.dart';

// Pindahkan enum ke level teratas file
enum CardioType { running, cycling, swimming }

class CardioInputPage extends StatefulWidget {
  const CardioInputPage({super.key});

  @override
  _CardioInputPageState createState() => _CardioInputPageState();
}

class _CardioInputPageState extends State<CardioInputPage> {
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);

  // Tambahkan enum untuk tipe aktivitas
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

              // Form fields sesuai tipe yang dipilih
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
              // Ambil data langsung dari form yang aktif
              double calories = 0;
              
              switch (selectedType) {
                case CardioType.running:
                  if (runningForm != null) {
                    // Ambil nilai langsung dari form running
                    calories = runningForm!.calculateCalories();
                  }
                  break;
                  
                case CardioType.cycling:
                  if (cyclingForm != null) {
                    // Ambil nilai langsung dari form cycling
                    calories = cyclingForm!.calculateCalories();
                  }
                  break;
                  
                case CardioType.swimming:
                  if (swimmingForm != null) {
                    // Ambil nilai langsung dari form swimming
                    calories = swimmingForm!.calculateCalories();
                  }
                  break;
              }

              // Tampilkan SnackBar dengan hasil kalori yang terbakar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Calories burned: ${calories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: primaryPink,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'CLOSE',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
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
}