import 'package:flutter/material.dart';

// Model classes stay the same
class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  List<ExerciseSet> sets;

  Exercise({
    String? id,
    required this.name,
    required this.bodyPart,
    List<ExerciseSet>? sets,
  }) : id = id ?? DateTime.now().toString(),
       sets = sets ?? [];
}

class ExerciseSet {
  final double weight;
  final int reps;

  ExerciseSet({
    required this.weight,
    required this.reps,
  });
}

// Pre-defined exercises stay the same
final Map<String, List<String>> exercisesByCategory = {
  'Upper Body': [
    'Bench Press',
    'Shoulder Press',
    'Bicep Curls',
    'Tricep Extensions',
    'Pull Ups',
    'Push Ups',
    'Lateral Raises',
  ],
  'Lower Body': [
    'Squats',
    'Deadlifts',
    'Leg Press',
    'Lunges',
    'Calf Raises',
    'Leg Extensions',
    'Hamstring Curls',
  ],
  'Core': [
    'Crunches',
    'Planks',
    'Russian Twists',
    'Leg Raises',
    'Ab Rollouts',
    'Side Planks',
  ],
  'Full Body': [
    'Clean and Press',
    'Burpees',
    'Turkish Get-ups',
    'Thrusters',
    'Mountain Climbers',
  ],
};

class WeightliftingPage extends StatefulWidget {
  @override
  _WeightliftingPageState createState() => _WeightliftingPageState();
}

class _WeightliftingPageState extends State<WeightliftingPage> {
  // Theme colors
  final Color primaryYellow = Color(0xFFFFE893);
  final Color primaryGreen = Color(0xFF4ECDC4);
  
  String selectedBodyPart = 'Upper Body';
  List<Exercise> exercises = [];

  // Logic methods stay the same
  void addExercise(String name) {
    setState(() {
      exercises.add(Exercise(
        name: name,
        bodyPart: selectedBodyPart,
      ));
    });
  }

  void addSet(Exercise exercise, double weight, int reps) {
    setState(() {
      exercise.sets.add(ExerciseSet(weight: weight, reps: reps));
    });
  }

  double calculateVolume(Exercise exercise) {
    return exercise.sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }

  double calculateTotalVolume() {
    return exercises.fold(0.0, (sum, exercise) => sum + calculateVolume(exercise));
  }

  Map<String, dynamic> getWorkoutSummary() {
    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0;
    
    for (var exercise in exercises) {
      totalSets += exercise.sets.length;
      for (var set in exercise.sets) {
        totalReps += set.reps;
        totalVolume += (set.weight * set.reps);
      }
    }

    return {
      'exercises': exercises.length,
      'sets': totalSets,
      'reps': totalReps,
      'volume': totalVolume,
    };
  }

  void clearWorkout() {
    setState(() {
      exercises.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weightlifting',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black54),
            onPressed: clearWorkout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Body Part',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: exercisesByCategory.keys.map((category) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: _buildBodyPartChip(category),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 24),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Add ${selectedBodyPart} Exercises',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...(exercisesByCategory[selectedBodyPart] ?? [])
                            .map((exercise) => _buildExerciseChip(exercise)),
                        _buildCustomButton(),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
              
              if (exercises.isNotEmpty)
                _buildWorkoutSummary(),

              ...exercises.map((exercise) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _buildExerciseCard(exercise),
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: exercises.isNotEmpty
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBodyPartChip(String category) {
    final isSelected = selectedBodyPart == category;

    return GestureDetector(
      onTap: () => setState(() => selectedBodyPart = category),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseChip(String exerciseName) {
    return GestureDetector(
      onTap: () => addExercise(exerciseName),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryGreen.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, size: 16, color: primaryGreen),
            SizedBox(width: 4),
            Text(
              exerciseName,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.add, size: 16, color: primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Custom',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSummary() {
    final summary = getWorkoutSummary();
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Exercises',
                summary['exercises'].toString(),
                Icons.fitness_center,
              ),
              _buildSummaryItem(
                'Sets',
                summary['sets'].toString(),
                Icons.repeat,
              ),
              _buildSummaryItem(
                'Volume',
                '${summary['volume'].toStringAsFixed(1)} kg',
                Icons.bar_chart,
              ),
              _buildSummaryItem(
                'Calories',
                'Est. ${(summary['volume'] * 0.15).toInt()} kcal',
                Icons.local_fire_department,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryGreen,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Workout saved successfully!'),
                backgroundColor: primaryGreen,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Save Workout (${calculateTotalVolume().toStringAsFixed(1)} kg)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center, color: primaryGreen),
                    SizedBox(width: 12),
                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${calculateVolume(exercise).toStringAsFixed(1)} kg',
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: exercise.sets.length,
            itemBuilder: (context, index) {
              return _buildSetRow(index + 1, exercise.sets[index]);
            },
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () => _showAddSetDialog(exercise),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add Set'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int setNumber, ExerciseSet set) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$setNumber',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Text(
            '${set.weight} kg',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            ' × ',
            style: TextStyle(
              color: Colors.black38,
              fontSize: 14,
            ),
          ),
          Text(
            '${set.reps} reps',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSetDialog(Exercise exercise) {
    double weight = 0;
    int reps = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Set',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryGreen),
                ),
              ),
              onChanged: (value) => weight = double.tryParse(value) ?? 0,
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reps',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryGreen),
                ),
              ),
              onChanged: (value) => reps = int.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
            ),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (weight > 0 && reps > 0) {
                addSet(exercise, weight, reps);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}