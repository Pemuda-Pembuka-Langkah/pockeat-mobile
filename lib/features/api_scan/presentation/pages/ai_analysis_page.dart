// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/api_scan/services/exercise/exercise_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/food_image_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/api_scan/services/food/nutrition_label_analysis_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textDescriptionController = TextEditingController();
  final _exerciseDescriptionController = TextEditingController();
  final _servingsController = TextEditingController(text: '1.0');
  final _correctionController = TextEditingController();

  // States
  bool _isLoading = false;
  FoodAnalysisResult? _foodAnalysisResult;
  ExerciseAnalysisResult? _exerciseResult;
  String? _errorMessage;
  bool _showCorrectionInterface = false;

  // Services
  final _foodTextAnalysisService = getIt<FoodTextAnalysisService>();
  final _foodImageAnalysisService = getIt<FoodImageAnalysisService>();
  final _nutritionLabelService = getIt<NutritionLabelAnalysisService>();
  final _exerciseAnalysisService = getIt<ExerciseAnalysisService>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      // Reset results when changing tabs
      if (_tabController.indexIsChanging) {
        setState(() {
          _foodAnalysisResult = null;
          _exerciseResult = null;
          _errorMessage = null;
          _showCorrectionInterface = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _textDescriptionController.dispose();
    _exerciseDescriptionController.dispose();
    _servingsController.dispose();
    _correctionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Food text analysis
  Future<void> _analyzeFoodByText() async {
    final description = _textDescriptionController.text.trim();
    if (description.isEmpty) {
      _showError('Please enter a food description');
      return;
    }

    setState(() {
      _isLoading = true;
      _foodAnalysisResult = null;
      _errorMessage = null;
      _showCorrectionInterface = false;
    });

    try {
      final result = await _foodTextAnalysisService.analyze(description);
      setState(() {
        _foodAnalysisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error analyzing food: ${e.toString()}');
    }
  }

  // Food text correction
  Future<void> _correctFoodTextAnalysis() async {
    if (_foodAnalysisResult == null) return;

    final correction = _correctionController.text.trim();
    if (correction.isEmpty) {
      _showError('Please enter correction details');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _foodTextAnalysisService.correctAnalysis(
          _foodAnalysisResult!, correction);
      if (!mounted) return;

      setState(() {
        _foodAnalysisResult = result;
        _isLoading = false;
        _showCorrectionInterface = false;
        _correctionController.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis corrected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to correct analysis: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Food image analysis
  Future<void> _analyzeFoodByImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      _isLoading = true;
      _foodAnalysisResult = null;
      _errorMessage = null;
      _showCorrectionInterface = false;
    });

    try {
      final result = await _foodImageAnalysisService.analyze(File(image.path));
      setState(() {
        _foodAnalysisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error analyzing food image: ${e.toString()}');
    }
  }

  // Food image correction
  Future<void> _correctFoodImageAnalysis() async {
    if (_foodAnalysisResult == null) return;

    final correction = _correctionController.text.trim();
    if (correction.isEmpty) {
      _showError('Please enter correction details');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _foodImageAnalysisService.correctAnalysis(
          _foodAnalysisResult!, correction);
      if (!mounted) return;

      setState(() {
        _foodAnalysisResult = result;
        _isLoading = false;
        _showCorrectionInterface = false;
        _correctionController.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis corrected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to correct analysis: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Nutrition label analysis
  Future<void> _analyzeNutritionLabel() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    final servingsText = _servingsController.text.trim();
    double servings;
    try {
      servings = double.parse(servingsText);
    } catch (e) {
      _showError('Please enter a valid number for servings');
      return;
    }

    setState(() {
      _isLoading = true;
      _foodAnalysisResult = null;
      _errorMessage = null;
      _showCorrectionInterface = false;
    });

    try {
      final result =
          await _nutritionLabelService.analyze(File(image.path), servings);
      setState(() {
        _foodAnalysisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error analyzing nutrition label: ${e.toString()}');
    }
  }

  // Nutrition label correction
  Future<void> _correctNutritionLabelAnalysis() async {
    if (_foodAnalysisResult == null) return;

    final correction = _correctionController.text.trim();
    if (correction.isEmpty) {
      _showError('Please enter correction details');
      return;
    }

    final servingsText = _servingsController.text.trim();
    double servings;
    try {
      servings = double.parse(servingsText);
    } catch (e) {
      _showError('Please enter a valid number for servings');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _nutritionLabelService.correctAnalysis(
          _foodAnalysisResult!, correction, servings);
      if (!mounted) return;

      setState(() {
        _foodAnalysisResult = result;
        _isLoading = false;
        _showCorrectionInterface = false;
        _correctionController.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis corrected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to correct analysis: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Exercise analysis
  Future<void> _analyzeExercise() async {
    final description = _exerciseDescriptionController.text.trim();
    if (description.isEmpty) {
      _showError('Please enter an exercise description');
      return;
    }

    setState(() {
      _isLoading = true;
      _exerciseResult = null;
      _errorMessage = null;
      _showCorrectionInterface = false;
    });

    try {
      final result = await _exerciseAnalysisService.analyze(description);
      setState(() {
        _exerciseResult = result;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error analyzing exercise: ${e.toString()}');
    }
  }

  // Exercise correction
  Future<void> _correctExerciseAnalysis() async {
    if (_exerciseResult == null) return;

    final correction = _correctionController.text.trim();
    if (correction.isEmpty) {
      _showError('Please enter correction details');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _exerciseAnalysisService.correctAnalysis(
          _exerciseResult!, correction);
      if (!mounted) return;

      setState(() {
        _exerciseResult = result;
        _isLoading = false;
        _showCorrectionInterface = false;
        _correctionController.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis corrected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to correct analysis: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _toggleCorrectionInterface() {
    setState(() {
      _showCorrectionInterface = !_showCorrectionInterface;
      if (!_showCorrectionInterface) {
        _correctionController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Food Text'),
            Tab(icon: Icon(Icons.camera_alt), text: 'Food Image'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Nutrition'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Exercise'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Food Text Analysis Tab
          _buildFoodTextAnalysisTab(),

          // Food Image Analysis Tab
          _buildFoodImageAnalysisTab(),

          // Nutrition Label Analysis Tab
          _buildNutritionLabelAnalysisTab(),

          // Exercise Analysis Tab
          _buildExerciseAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildFoodTextAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _textDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Food Description',
              hintText: 'e.g., Grilled chicken sandwich with lettuce and mayo',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _analyzeFoodByText,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Analyze Food'),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          if (_foodAnalysisResult != null) ...[
            _buildFoodAnalysisResult(_foodAnalysisResult!),
            const SizedBox(height: 16),
            if (!_showCorrectionInterface)
              OutlinedButton.icon(
                onPressed: _toggleCorrectionInterface,
                icon: const Icon(Icons.edit),
                label: const Text('Request Correction'),
              )
            else
              _buildCorrectionInterface(_correctFoodTextAnalysis),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodImageAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Take a photo of your food to analyze its nutritional content',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _analyzeFoodByImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Food Photo'),
          ),
          const SizedBox(height: 24),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          if (_foodAnalysisResult != null) ...[
            _buildFoodAnalysisResult(_foodAnalysisResult!),
            const SizedBox(height: 16),
            if (!_showCorrectionInterface)
              OutlinedButton.icon(
                onPressed: _toggleCorrectionInterface,
                icon: const Icon(Icons.edit),
                label: const Text('Request Correction'),
              )
            else
              _buildCorrectionInterface(_correctFoodImageAnalysis),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionLabelAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Take a photo of a nutrition label to analyze',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _servingsController,
            decoration: const InputDecoration(
              labelText: 'Number of Servings',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _analyzeNutritionLabel,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Nutrition Label'),
          ),
          const SizedBox(height: 24),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          if (_foodAnalysisResult != null) ...[
            _buildFoodAnalysisResult(_foodAnalysisResult!),
            const SizedBox(height: 16),
            if (!_showCorrectionInterface)
              OutlinedButton.icon(
                onPressed: _toggleCorrectionInterface,
                icon: const Icon(Icons.edit),
                label: const Text('Request Correction'),
              )
            else
              _buildCorrectionInterface(_correctNutritionLabelAnalysis),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _exerciseDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Exercise Description',
              hintText: 'e.g., 30 minutes of jogging at moderate pace',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _analyzeExercise,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Analyze Exercise'),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          if (_exerciseResult != null) ...[
            _buildExerciseAnalysisResult(_exerciseResult!),
            const SizedBox(height: 16),
            if (!_showCorrectionInterface)
              OutlinedButton.icon(
                onPressed: _toggleCorrectionInterface,
                icon: const Icon(Icons.edit),
                label: const Text('Request Correction'),
              )
            else
              _buildCorrectionInterface(_correctExerciseAnalysis),
          ],
        ],
      ),
    );
  }

  Widget _buildCorrectionInterface(Function() onSubmit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _correctionController,
          decoration: const InputDecoration(
            labelText: 'What needs correction?',
            hintText: 'e.g., The calorie count is wrong, it should be higher',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Correction'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _isLoading ? null : _toggleCorrectionInterface,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodAnalysisResult(FoodAnalysisResult result) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.foodName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const Text(
              'Ingredients:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...result.ingredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• ${ingredient.name}: ${ingredient.servings}g'),
                )),
            const SizedBox(height: 16),
            const Text(
              'Nutrition Info:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildNutritionTable(result.nutritionInfo),
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Warnings:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ...result.warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(warning)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionTable(NutritionInfo info) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
      },
      children: [
        _buildTableRow('Calories', '${info.calories} kcal', isHeader: true),
        _buildTableRow('Protein', '${info.protein}g'),
        _buildTableRow('Carbs', '${info.carbs}g'),
        _buildTableRow('Fat', '${info.fat}g'),
        _buildTableRow('Sodium', '${info.sodium}mg'),
        _buildTableRow('Fiber', '${info.fiber}g'),
        _buildTableRow('Sugar', '${info.sugar}g'),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader ? BoxDecoration(color: Colors.grey.shade200) : null,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseAnalysisResult(ExerciseAnalysisResult result) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.exerciseType,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.summary ?? 'No summary available',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),
            _buildExerciseInfoItem('Duration', result.duration),
            _buildExerciseInfoItem('Intensity', result.intensity),
            _buildExerciseInfoItem(
                'Calories Burned', '${result.estimatedCalories} kcal'),
            _buildExerciseInfoItem('MET Value', result.metValue.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
