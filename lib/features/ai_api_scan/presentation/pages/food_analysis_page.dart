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
    _initializeGeminiService();
  }

  void _initializeGeminiService() {
    try {
      // Initialize the Gemini service with the API key from .env
      _geminiService = GeminiServiceImpl.fromEnv();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize Gemini service: $e';
      });
    }
  }

  Future<void> _analyzeByText() async {
    if (_textController.text.isEmpty) {
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

    try {
      final result = await _geminiService.analyzeFoodByText(_textController.text);
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _imageFile = File(image.path);
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      final result = await _geminiService.analyzeFoodByImage(_imageFile!);
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _imageFile = File(image.path);
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      // We're assuming one serving by default, can be customized with a dialog
      final result = await _geminiService.analyzeNutritionLabel(_imageFile!, 1.0);
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
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
                hintText: 'Describe the food (e.g., "Chicken Caesar salad with croutons")',
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
            if (_analysisResult != null)
              _buildResultsCard(_analysisResult!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(FoodAnalysisResult result) {
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
                _nutritionItem('Sugar', '${result.nutritionInfo.sugar}g'),
                _nutritionItem('Fiber', '${result.nutritionInfo.fiber}g'),
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
                      Text('${ingredient.percentage.toStringAsFixed(1)}%'),
                      const SizedBox(width: 8),
                      if (ingredient.allergen)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Allergen',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[900],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _nutritionItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
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
    _textController.dispose();
    super.dispose();
  }
}