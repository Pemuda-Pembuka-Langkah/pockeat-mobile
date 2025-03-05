// lib/features/ai_analysis/presentation/pages/food_analysis_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';

class FoodAnalysisPage extends StatefulWidget {
  const FoodAnalysisPage({Key? key}) : super(key: key);

  @override
  State<FoodAnalysisPage> createState() => _FoodAnalysisPageState();
}

class _FoodAnalysisPageState extends State<FoodAnalysisPage> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late GeminiServiceImpl _geminiService;

  bool _isLoading = false;
  File? _imageFile;
  FoodAnalysisResult? _analysisResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print("DEBUG: FoodAnalysisPage - initState called");
    _initializeGeminiService();
  }

  void _initializeGeminiService() {
    try {
      print("DEBUG: FoodAnalysisPage - Initializing Gemini service");
      // Initialize the Gemini service with the API key from .env
      _geminiService = GeminiServiceImpl.fromEnv();
      print(
          "DEBUG: FoodAnalysisPage - Gemini service initialized successfully");
    } catch (e) {
      print(
          "ERROR: FoodAnalysisPage - Failed to initialize Gemini service: $e");
      setState(() {
        _errorMessage = 'Failed to initialize Gemini service: $e';
      });
    }
  }

  Future<void> _analyzeByText() async {
    if (_textController.text.isEmpty) {
      print("DEBUG: FoodAnalysisPage - Text input is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food description')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    print(
        "DEBUG: FoodAnalysisPage - Starting text analysis with input: ${_textController.text}");
    try {
      final result =
          await _geminiService.analyzeFoodByText(_textController.text);
      print("DEBUG: FoodAnalysisPage - Text analysis completed successfully");
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      print("ERROR: FoodAnalysisPage - Text analysis failed: $e");
      setState(() {
        _errorMessage = 'Analysis failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndAnalyzeImage() async {
    print("DEBUG: FoodAnalysisPage - Opening image picker");
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print("DEBUG: FoodAnalysisPage - No image selected");
      return;
    }

    setState(() {
      _imageFile = File(image.path);
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    print(
        "DEBUG: FoodAnalysisPage - Starting image analysis with file: ${image.path}");
    try {
      final result = await _geminiService.analyzeFoodByImage(_imageFile!);
      print("DEBUG: FoodAnalysisPage - Image analysis completed successfully");
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      print("ERROR: FoodAnalysisPage - Image analysis failed: $e");
      setState(() {
        _errorMessage = 'Analysis failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeNutritionLabel() async {
    print("DEBUG: FoodAnalysisPage - Opening image picker for nutrition label");
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print("DEBUG: FoodAnalysisPage - No image selected for nutrition label");
      return;
    }

    setState(() {
      _imageFile = File(image.path);
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    print(
        "DEBUG: FoodAnalysisPage - Starting nutrition label analysis with file: ${image.path}");
    try {
      // We're assuming one serving by default, can be customized with a dialog
      final result =
          await _geminiService.analyzeNutritionLabel(_imageFile!, 1.0);
      print(
          "DEBUG: FoodAnalysisPage - Nutrition label analysis completed successfully");
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      print("ERROR: FoodAnalysisPage - Nutrition label analysis failed: $e");
      setState(() {
        _errorMessage = 'Analysis failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG: FoodAnalysisPage - build method called");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Analysis'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text input area
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Describe the food (e.g., "Chicken Caesar salad with croutons")',
                border: OutlineInputBorder(),
                labelText: 'Food Description',
              ),
            ),
            const SizedBox(height: 16),

            // Analysis button
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeByText,
              child: const Text('Analyze Description'),
            ),

            const SizedBox(height: 8),
            const Center(child: Text('OR')),
            const SizedBox(height: 8),

            // Image upload buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickAndAnalyzeImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Analyze Food Image'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _analyzeNutritionLabel,
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Analyze Nutrition Label'),
                  ),
                ),
              ],
            ),

            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: CircularProgressIndicator()),
              ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ),
              ),

            // Image preview
            if (_imageFile != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Results
            if (_analysisResult != null) _buildResultsCard(_analysisResult!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(FoodAnalysisResult result) {
    print(
        "DEBUG: FoodAnalysisPage - Building results card for: ${result.foodName}");
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.foodName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),

            // Warnings section (if any)
            if (result.warnings.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Nutritional Warnings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...result.warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 16, color: Colors.amber.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              warning,
                              style: TextStyle(color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Nutrition Info
            const Text('Nutrition Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            Row(
              children: [
                _nutritionItem('Calories', '${result.nutritionInfo.calories}'),
                _nutritionItem('Protein', '${result.nutritionInfo.protein}g'),
                _nutritionItem('Carbs', '${result.nutritionInfo.carbs}g'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _nutritionItem('Fat', '${result.nutritionInfo.fat}g'),
                _nutritionItem(
                  'Sugar', 
                  '${result.nutritionInfo.sugar}g',
                  isHighlighted: result.warnings.contains(FoodAnalysisResult.HIGH_SUGAR_WARNING)
                ),
                _nutritionItem(
                  'Sodium', 
                  '${result.nutritionInfo.sodium}mg',
                  isHighlighted: result.warnings.contains(FoodAnalysisResult.HIGH_SODIUM_WARNING)
                ),
              ],
            ),

            // Ingredients
            if (result.ingredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Ingredients',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              for (var ingredient in result.ingredients)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(ingredient.name),
                      ),
                      Text('${ingredient.servings.toStringAsFixed(1)} grams'),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _nutritionItem(String label, String value, {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.amber.shade50 : Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted 
              ? Border.all(color: Colors.amber.shade300, width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isHighlighted ? Colors.amber.shade900 : null,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isHighlighted ? Colors.amber.shade800 : Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("DEBUG: FoodAnalysisPage - dispose called");
    _textController.dispose();
    super.dispose();
  }
}

