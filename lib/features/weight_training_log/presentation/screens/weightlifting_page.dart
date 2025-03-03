import 'package:flutter/material.dart';
import 'package:pockeat/features/weight_training_log/domain/models/exercise.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/exercise_repository.dart';
import 'package:pockeat/features/weight_training_log/services/workout_service.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/body_part_chip.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/exercise_chip.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/exercise_card.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/workout_summary.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/bottom_bar.dart';

class WeightliftingPage extends StatefulWidget {
  const WeightliftingPage({Key? key}) : super(key: key);

  @override
  _WeightliftingPageState createState() => _WeightliftingPageState();
}

class _WeightliftingPageState extends State<WeightliftingPage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  String selectedBodyPart = 'Upper Body';
  List<Exercise> exercises = [];

  void addExercise(String name) {
    setState(() {
      exercises.add(Exercise(
        name: name,
        bodyPart: selectedBodyPart,
        metValue: exercisesByCategory[selectedBodyPart]?[name] ?? 3.15,
      ));
    });
  }

  void addSet(Exercise exercise, double weight, int reps, double duration) {
    setState(() {
      exercise.sets.add(ExerciseSet(weight: weight, reps: reps, duration: duration));
    });
  }

  void clearWorkout() {
    setState(() {
      exercises.clear();
    });
  }

  void _showAddSetDialog(Exercise exercise) {
    double weight = 0;
    int reps = 0;
    double duration = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
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
              key: const Key('weightField'),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: const TextStyle(color: Colors.black54),
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
            const SizedBox(height: 16),
            TextField(
              key: const Key('repsField'),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reps',
                labelStyle: const TextStyle(color: Colors.black54),
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
            const SizedBox(height: 16),
            TextField(
              key: const Key('durationField'),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Duration (minutes)',
                labelStyle: const TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryGreen),
                ),
              ),
              onChanged: (value) => duration = double.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (weight > 0 && reps > 0 && duration > 0) {
                addSet(exercise, weight, reps, duration);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
        title: const Text(
          'Weightlifting',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: clearWorkout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Body Part',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: exercisesByCategory.keys.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: BodyPartChip(
                        category: category,
                        isSelected: selectedBodyPart == category,
                        onTap: () {
                          setState(() {
                            selectedBodyPart = category;
                          });
                        },
                        primaryGreen: primaryGreen,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
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
                      'Quick Add $selectedBodyPart Exercises',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...(exercisesByCategory[selectedBodyPart]?.keys ?? [])
                            .map((exercise) => ExerciseChipWidget(
                                  exerciseName: exercise,
                                  onTap: () => addExercise(exercise),
                                  primaryGreen: primaryGreen,
                                ))
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (exercises.isNotEmpty)
                WorkoutSummary(
                  exerciseCount: exercises.length,
                  totalSets: calculateTotalSets(exercises),
                  totalReps: calculateTotalReps(exercises),
                  totalVolume: calculateTotalVolume(exercises),
                  totalDuration: calculateTotalDuration(exercises),
                  estimatedCalories: calculateEstimatedCalories(exercises),
                  primaryGreen: primaryGreen,
                ),
              ...exercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ExerciseCard(
                      exercise: exercise,
                      primaryGreen: primaryGreen,
                      volume: calculateExerciseVolume(exercise),
                      onAddSet: () => _showAddSetDialog(exercise),
                    ),
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: exercises.isNotEmpty
          ? BottomBar(
              totalVolume: calculateTotalVolume(exercises),
              primaryGreen: primaryGreen,
              onSaveWorkout: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Workout saved successfully!'),
                    backgroundColor: primaryGreen,
                  ),
                );
              },
            )
          : null,
    );
  }
}
