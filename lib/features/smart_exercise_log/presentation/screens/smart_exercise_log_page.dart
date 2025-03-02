import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service.dart';
import 'package:pockeat/features/ai_api_scan/services/gemini_service_impl.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository_impl.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/analysis_result_widget.dart';
import 'package:pockeat/features/smart_exercise_log/presentation/widgets/workout_form_widget.dart';

class SmartExerciseLogPage extends StatefulWidget {
  // Tambahkan parameter optional untuk dependency injection
  final GeminiService? geminiService;
  final SmartExerciseLogRepository? repository;

  const SmartExerciseLogPage({
    super.key, 
    this.geminiService,
    this.repository,
  });

  @override
  State<SmartExerciseLogPage> createState() => _SmartExerciseLogPageState();
}

class _SmartExerciseLogPageState extends State<SmartExerciseLogPage> {
  // Warna tema yang konsisten
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPurple = const Color(0xFF9B6BFF);
  
  // State variables
  bool isAnalyzing = false;
  ExerciseAnalysisResult? analysisResult;
  
  // Dependencies
  late final GeminiService _geminiService;
  late final SmartExerciseLogRepository _repository;
  
  @override
  void initState() {
    super.initState();
    // Gunakan dependency yang diinjeksi atau fallback ke implementasi default
    _geminiService = widget.geminiService ?? GeminiServiceImpl(
      apiKey: dotenv.env['GOOGLE_GEMINI_API_KEY'] ?? ''
    );
    _repository = widget.repository ?? SmartExerciseLogRepositoryImpl();
  }
  
  Future<void> analyzeWorkout(String workoutDescription) async {
    setState(() => isAnalyzing = true);
    
    try {
      // Use Gemini service for AI analysis
      final result = await _geminiService.analyzeExercise(workoutDescription);
      
      setState(() {
        analysisResult = result;
        isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        isAnalyzing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menganalisis olahraga: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void resetAnalysis() {
    setState(() {
      analysisResult = null;
    });
  }
  
  Future<void> saveExerciseLog() async {
    if (analysisResult == null || !analysisResult!.isComplete) return;
    
    try {
      await _repository.saveAnalysisResult(analysisResult!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Catatan olahraga berhasil disimpan!'),
            backgroundColor: primaryPurple,
          ),
        );
        
        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan catatan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          'Smart Workout Log',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Workout Form - using your WorkoutFormWidget component
            if (analysisResult == null)
              WorkoutFormWidget(
                onAnalyzePressed: analyzeWorkout,
                isLoading: isAnalyzing,
              ),
            
            // Analysis Result - using your AnalysisResultWidget component
            if (analysisResult != null && !isAnalyzing) ...[
              const SizedBox(height: 24),
              AnalysisResultWidget(
                analysisResult: analysisResult!,
                onRetry: resetAnalysis,
                onSave: saveExerciseLog,
              ),
            ],
          ],
        ),
      ),
    );
  }
}