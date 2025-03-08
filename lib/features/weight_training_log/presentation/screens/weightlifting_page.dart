import 'package:flutter/material.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository.dart';
import 'package:pockeat/features/weight_training_log/domain/repositories/weight_lifting_repository_impl.dart';
import 'package:pockeat/features/weight_training_log/services/workout_service.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/body_part_chip.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/exercise_chip.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/exercise_card.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/workout_summary.dart';
import 'package:pockeat/features/weight_training_log/presentation/widgets/bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeightliftingPage extends StatefulWidget {
  const WeightliftingPage({Key? key}) : super(key: key);

  @override
  _WeightliftingPageState createState() => _WeightliftingPageState();
}

class _WeightliftingPageState extends State<WeightliftingPage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  
  // Add repository instance
  late final WeightLiftingRepository _exerciseRepository;
  
  final Map<String, Map<String, double>> exercisesByCategory = WeightLiftingRepositoryImpl.exercisesByCategory;

  String selectedBodyPart = 'Upper Body';
  List<WeightLifting> exercises = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize repository
    _exerciseRepository = WeightLiftingRepositoryImpl(
      firestore: FirebaseFirestore.instance,
    );
  }

  void addExercise(String name) {
    setState(() {
      exercises.add(WeightLifting(
        name: name,
        bodyPart: selectedBodyPart,
        metValue: exercisesByCategory[selectedBodyPart]?[name] ?? 3.15,
      ));
    });
  }

  void addSet(WeightLifting exercise, double weight, int reps, double duration) {
    setState(() {
      exercise.sets.add(WeightLiftingSet(weight: weight, reps: reps, duration: duration));
    });
  }

  void clearWorkout() => setState(() => exercises.clear());

  // New method to save workout to repository
  Future<void> saveWorkout() async {
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exercises to save'))
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      // Add current date to each exercise before saving
      final now = DateTime.now();
      final dateString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      // Save each exercise
      List<Future<String>> saveFutures = [];
      
      for (final exercise in exercises) {
        // Add date to exercise JSON before saving
        final exerciseWithDate = WeightLifting(
          id: exercise.id,
          name: exercise.name,
          bodyPart: exercise.bodyPart,
          metValue: exercise.metValue,
          sets: exercise.sets,
        );
        
        // Save exercise to repository
        saveFutures.add(_exerciseRepository.saveExercise(exerciseWithDate));
      }
      
      // Wait for all exercises to be saved
      await Future.wait(saveFutures);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout saved successfully! Total volume: ${calculateTotalVolume(exercises).toStringAsFixed(1)} kg'),
            backgroundColor: Colors.green,
          )
        );
        // Clear workout after successful save
        clearWorkout();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout: ${e.toString()}'),
            backgroundColor: Colors.red,
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showAddSetDialog(WeightLifting exercise) {
    // Create text editing controllers to track input values
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final durationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: _buildDialogTitle('Add Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Weight (kg)', weightController),
            const SizedBox(height: 16),
            _buildTextField('Reps', repsController),
            const SizedBox(height: 16),
            _buildTextField('Duration (minutes)', durationController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel')
          ),
          ElevatedButton(
            onPressed: () {
              // Parse and validate the input values
              final weight = double.tryParse(weightController.text) ?? 0;
              final reps = int.tryParse(repsController.text) ?? 0;
              final duration = double.tryParse(durationController.text) ?? 0;
              
              if (weight > 0 && reps > 0 && duration > 0) {
                addSet(exercise, weight, reps, duration);
                Navigator.pop(context);
              } else {
                // Show error message if validation fails
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid values for weight, reps, and duration'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Text _buildDialogTitle(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  TextField _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
      ),
    );
  }

  List<Widget> _buildDialogActions(WeightLifting exercise, double weight, int reps, double duration) {
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

  // Updated to use the saveWorkout method
  Widget _buildBottomBar() => BottomBar(
    totalVolume: calculateTotalVolume(exercises), 
    primaryGreen: primaryGreen, 
    onSaveWorkout: _isSaving ? null : saveWorkout,
  );
}