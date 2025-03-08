import 'package:flutter/material.dart';
import 'package:pockeat/features/weight_training_log/domain/models/exercise.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/exercise_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/exercise_repository_impl.dart';
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

  final Map<String, Map<String, double>> exercisesByCategory = ExerciseRepositoryImpl.exercisesByCategory;

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

  void clearWorkout() => setState(() => exercises.clear());

  void _showAddSetDialog(Exercise exercise) {
    double weight = 0, duration = 0;
    int reps = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: _buildDialogTitle('Add Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Weight (kg)', (value) => weight = double.tryParse(value) ?? 0),
            const SizedBox(height: 16),
            _buildTextField('Reps', (value) => reps = int.tryParse(value) ?? 0),
            const SizedBox(height: 16),
            _buildTextField('Duration (minutes)', (value) => duration = double.tryParse(value) ?? 0),
          ],
        ),
        actions: _buildDialogActions(exercise, weight, reps, duration),
      ),
    );
  }

  Text _buildDialogTitle(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  TextField _buildTextField(String label, Function(String) onChanged) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      onChanged: onChanged,
    );
  }

  List<Widget> _buildDialogActions(Exercise exercise, double weight, int reps, double duration) {
    return [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(
        onPressed: () {
          if (weight > 0 && reps > 0 && duration > 0) {
            addSet(exercise, weight, reps, duration);
            Navigator.pop(context);
          }
        },
        child: const Text('Add'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: exercises.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: primaryYellow,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      title: const Text('Weightlifting', style: TextStyle(fontWeight: FontWeight.w600)),
      actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: clearWorkout)],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Select Body Part'),
          _buildBodyPartChips(),
          const SizedBox(height: 24),
          _buildExerciseQuickAdd(),
          const SizedBox(height: 24),
          if (exercises.isNotEmpty) WorkoutSummary(
            exerciseCount: exercises.length,
            totalSets: calculateTotalSets(exercises),
            totalReps: calculateTotalReps(exercises),
            totalVolume: calculateTotalVolume(exercises),
            totalDuration: calculateTotalDuration(exercises),
            estimatedCalories: calculateEstimatedCalories(exercises),
            primaryGreen: primaryGreen,
          ),
          ...exercises.map((exercise) => ExerciseCard(
                exercise: exercise,
                primaryGreen: primaryGreen,
                volume: calculateExerciseVolume(exercise),
                onAddSet: () => _showAddSetDialog(exercise),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontWeight: FontWeight.w600));

  Widget _buildBodyPartChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: exercisesByCategory.keys.map((category) => BodyPartChip(
          category: category,
          isSelected: selectedBodyPart == category,
          onTap: () => setState(() => selectedBodyPart = category),
          primaryGreen: primaryGreen
        )).toList(),
      ),
    );
  }

  Widget _buildExerciseQuickAdd() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quick Add $selectedBodyPart Exercises'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (exercisesByCategory[selectedBodyPart]?.keys ?? []).map((exercise) => ExerciseChipWidget(
                  exerciseName: exercise,
                  onTap: () => addExercise(exercise),
                  primaryGreen: primaryGreen,
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() => BottomBar(totalVolume: calculateTotalVolume(exercises), primaryGreen: primaryGreen, onSaveWorkout: () {});
}