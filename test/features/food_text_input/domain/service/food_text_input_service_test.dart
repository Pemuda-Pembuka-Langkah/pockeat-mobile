import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/food_text_input/domain/services/food_text_input_service.dart';
import 'package:pockeat/features/ai_api_scan/services/food/food_text_analysis_service.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

@GenerateMocks([
  FoodTextAnalysisService, 
  FoodTextInputRepository, 
  Uuid,
  FirebaseAuth,
  User
])
import 'food_text_input_service_test.mocks.dart';

void main() {
  late FoodTextInputService foodTextInputService;
  late MockFoodTextAnalysisService mockFoodTextAnalysisService;
  late MockFoodTextInputRepository mockFoodTextInputRepository;
  late MockUuid mockUuid;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockFoodTextAnalysisService = MockFoodTextAnalysisService();
    mockFoodTextInputRepository = MockFoodTextInputRepository();
    mockUuid = MockUuid();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Set up Firebase Auth mock
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');

    // Replace the direct Firebase.instance with our mock in the service
    foodTextInputService = FoodTextInputService(
      mockFoodTextAnalysisService,
      mockFoodTextInputRepository,
      auth: mockFirebaseAuth
    );

    // We no longer need reflection since we're properly injecting the dependency
    // final service = foodTextInputService;
  });

  group('FoodTextInputService', () {
    final testDateTime = DateTime(2023, 1, 1);
    final testFoodAnalysis = FoodAnalysisResult(
      id: '123',
      foodName: 'Test Food',
      ingredients: [
        Ingredient(name: 'Test Ingredient', servings: 100),
      ],
      nutritionInfo: NutritionInfo(
        calories: 200,
        protein: 10,
        carbs: 20,
        fat: 5,
        sodium: 300,
        fiber: 5,
        sugar: 10,
      ),
      warnings: ['Test warning'],
      timestamp: testDateTime,
      userId: '',  // Empty initially, will be set by the service
    );

    test('analyzeFoodText should return analysis result', () async {
      when(mockFoodTextAnalysisService.analyze('test food'))
          .thenAnswer((_) async => testFoodAnalysis);

      final result = await foodTextInputService.analyzeFoodText('test food');

      expect(result, equals(testFoodAnalysis));
      verify(mockFoodTextAnalysisService.analyze('test food')).called(1);
    });

    test('analyzeFoodText should handle errors', () async {
      when(mockFoodTextAnalysisService.analyze('error text'))
          .thenThrow(Exception('Analysis error'));

      expect(() => foodTextInputService.analyzeFoodText('error text'),
          throwsA(isA<Exception>()));
      verify(mockFoodTextAnalysisService.analyze('error text')).called(1);
    });

    test('saveFoodAnalysis should save analysis with existing ID', () async {
      // Setup FirebaseAuth mock to bypass the issue
      final expectedAnalysisWithUserId = testFoodAnalysis.copyWith(userId: 'test-user-id');
      
      // Mock the repository to return success
      when(mockFoodTextInputRepository.save(any, '123'))
          .thenAnswer((_) async => 'save-id-123');

      // Use stub method to directly test the functionality without FirebaseAuth
      final result = await foodTextInputService.saveFoodAnalysis(testFoodAnalysis);

      expect(result, 'Food analysis saved successfully');
      
      // Verify that save is called with the correct parameters
      verify(mockFoodTextInputRepository.save(
        argThat(predicate((FoodAnalysisResult food) => 
          food.id == '123' && food.userId == 'test-user-id')), 
        '123'
      )).called(1);
    });

    test('saveFoodAnalysis should handle errors', () async {
      // Setup repository to throw an error
      when(mockFoodTextInputRepository.save(any, any))
          .thenThrow(Exception('Save error'));

      // Test error handling
      expect(() => foodTextInputService.saveFoodAnalysis(testFoodAnalysis),
          throwsA(isA<Exception>()));
      
      // Verify repository call
      verify(mockFoodTextInputRepository.save(any, '123')).called(1);
    });

    test('correctFoodAnalysis should return corrected analysis', () async {
      final correctedAnalysis = testFoodAnalysis.copyWith(foodName: 'Corrected Food');
      when(mockFoodTextAnalysisService.correctAnalysis(testFoodAnalysis, 'correction comment'))
          .thenAnswer((_) async => correctedAnalysis);

      final result = await foodTextInputService.correctFoodAnalysis(
          testFoodAnalysis, 'correction comment');

      expect(result, equals(correctedAnalysis));
      verify(mockFoodTextAnalysisService.correctAnalysis(
              testFoodAnalysis, 'correction comment'))
          .called(1);
    });

    test('correctFoodAnalysis should handle errors', () async {
      when(mockFoodTextAnalysisService.correctAnalysis(any, any))
          .thenThrow(Exception('Correction error'));

      expect(
          () => foodTextInputService.correctFoodAnalysis(
              testFoodAnalysis, 'correction comment'),
          throwsA(isA<Exception>()));
      verify(mockFoodTextAnalysisService.correctAnalysis(
              testFoodAnalysis, 'correction comment'))
          .called(1);
    });

    test('getAllFoodAnalysis should return all food analysis results', () async {
      final List<FoodAnalysisResult> analysisResults = [testFoodAnalysis];
      when(mockFoodTextInputRepository.getAll())
          .thenAnswer((_) async => analysisResults);

      final results = await foodTextInputService.getAllFoodAnalysis();

      expect(results, equals(analysisResults));
      verify(mockFoodTextInputRepository.getAll()).called(1);
    });
  });
}
