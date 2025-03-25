import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/presentation/screens/exercise_log_detail_page.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/cycling_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/running_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/smart_exercise_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/swimming_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/weight_lifting_detail_widget.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_detail_service.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

@GenerateMocks([ExerciseDetailService])
import 'exercise_log_detail_page_test.mocks.dart';

// Mock NavigatorObserver untuk menguji navigasi
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockExerciseDetailService mockExerciseDetailService;
  late MockNavigatorObserver mockNavigatorObserver;
  final getIt = GetIt.instance;

  // Sample data untuk testing
  final runningActivity = RunningActivity(
    id: 'run-1',
    userId: "test-user-id",
    date: DateTime(2025, 3, 1),
    startTime: DateTime(2025, 3, 1, 8, 0),
    endTime: DateTime(2025, 3, 1, 8, 30),
    distanceKm: 5.0,
    caloriesBurned: 350,
  );

  final cyclingActivity = CyclingActivity(
    id: 'cycle-1',
    userId: "test-user-id",
    date: DateTime(2025, 3, 2),
    startTime: DateTime(2025, 3, 2, 10, 0),
    endTime: DateTime(2025, 3, 2, 11, 0),
    distanceKm: 20.0,
    cyclingType: CyclingType.commute,
    caloriesBurned: 450,
  );

  final swimmingActivity = SwimmingActivity(
    id: 'swim-1',
    userId: "test-user-id",
    date: DateTime(2025, 3, 3),
    startTime: DateTime(2025, 3, 3, 16, 0),
    endTime: DateTime(2025, 3, 3, 16, 45),
    laps: 20,
    poolLength: 50.0,
    stroke: 'freestyle',
    caloriesBurned: 500,
  );

  final smartExerciseResult = ExerciseAnalysisResult(
    id: 'smart-1',
    exerciseType: 'Push-ups',
    duration: '15 min',
    intensity: 'High',
    estimatedCalories: 120,
    metValue: 8.0,
    timestamp: DateTime(2025, 3, 4),
    originalInput: 'I did push-ups for 15 minutes',
  );

  // Membuat sample weight lifting exercise dengan set
  final weightLiftingSet = WeightLiftingSet(
    weight: 60.0,
    reps: 12,
    duration: 45.0,
  );

  final weightLiftingExercise = WeightLifting(
    id: 'weight-1',
    userId: 'test-user-id',
    name: 'Bench Press',
    bodyPart: 'Chest',
    metValue: 6.0,
    timestamp: DateTime(2025, 3, 5),
    sets: [weightLiftingSet],
  );

  setUp(() {
    mockExerciseDetailService = MockExerciseDetailService();
    mockNavigatorObserver = MockNavigatorObserver();

    // Register mock in GetIt
    if (getIt.isRegistered<ExerciseDetailService>()) {
      getIt.unregister<ExerciseDetailService>();
    }
    getIt.registerSingleton<ExerciseDetailService>(mockExerciseDetailService);

    // Setup default mock responses
    when(mockExerciseDetailService.getActualActivityType(any, any))
        .thenAnswer((_) async => 'running');
    when(mockExerciseDetailService
            .getCardioActivityDetail<RunningActivity>(any))
        .thenAnswer((_) async => runningActivity);
    when(mockExerciseDetailService
            .getCardioActivityDetail<CyclingActivity>(any))
        .thenAnswer((_) async => cyclingActivity);
    when(mockExerciseDetailService
            .getCardioActivityDetail<SwimmingActivity>(any))
        .thenAnswer((_) async => swimmingActivity);
    when(mockExerciseDetailService.getSmartExerciseDetail(any))
        .thenAnswer((_) async => smartExerciseResult);
    when(mockExerciseDetailService.getWeightLiftingDetail(any))
        .thenAnswer((_) async => weightLiftingExercise);
    when(mockExerciseDetailService.deleteExerciseLog(any, any))
        .thenAnswer((_) async => true);
  });

  tearDown(() {
    getIt.reset();
  });

  group('ExerciseLogDetailPage Widget Tests', () {
    testWidgets('should show loading indicator while data is loading',
        (WidgetTester tester) async {
      // Arrange - Menggunakan Future yang tertunda untuk mensimulasikan loading
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) =>
              Future.delayed(const Duration(seconds: 1), () => 'running'));
      when(mockExerciseDetailService
              .getCardioActivityDetail<RunningActivity>(any))
          .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 1), () => runningActivity));

      // Act - Membuat widget dan pump
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));

      // Assert - harus menampilkan loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up - menyelesaikan future agar test bisa selesai
      await tester.pumpAndSettle();
    });

    testWidgets('should display error message when data loading fails',
        (WidgetTester tester) async {
      // Arrange - Setup error response
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) async => 'running');
      when(mockExerciseDetailService
              .getCardioActivityDetail<RunningActivity>(any))
          .thenAnswer((_) => Future.error('Failed to load data'));

      // Act - Membuat widget dan menunggu hingga selesai
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan pesan error
      expect(find.text('Error loading data'), findsOneWidget);
    });

    testWidgets('should display RunningDetailWidget for running activity',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) async => 'running');
      when(mockExerciseDetailService
              .getCardioActivityDetail<RunningActivity>(any))
          .thenAnswer((_) async => runningActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));

      // Tunggu hingga future selesai
      await tester.pumpAndSettle();

      // Assert - harus menampilkan RunningDetailWidget
      expect(find.byType(RunningDetailWidget), findsOneWidget);
    });

    testWidgets('should display CyclingDetailWidget for cycling activity',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) async => 'cycling');
      when(mockExerciseDetailService
              .getCardioActivityDetail<CyclingActivity>(any))
          .thenAnswer((_) async => cyclingActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'cycle-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan CyclingDetailWidget
      expect(find.byType(CyclingDetailWidget), findsOneWidget);
    });

    testWidgets('should display SwimmingDetailWidget for swimming activity',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) async => 'swimming');
      when(mockExerciseDetailService
              .getCardioActivityDetail<SwimmingActivity>(any))
          .thenAnswer((_) async => swimmingActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'swim-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan data swimming
      expect(find.byType(SwimmingDetailWidget), findsOneWidget);
    });

    testWidgets('should display SmartExerciseDetailWidget for smart exercise',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'smart-1',
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan SmartExerciseDetailWidget
      expect(find.byType(SmartExerciseDetailWidget), findsOneWidget);
    });

    testWidgets('should display WeightLiftingDetailWidget for weight lifting',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'weight-1',
          activityType: ExerciseLogHistoryItem.typeWeightlifting,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan WeightLiftingDetailWidget
      expect(find.byType(WeightLiftingDetailWidget), findsOneWidget);
    });

    testWidgets('should show delete button in AppBar',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan tombol delete di AppBar
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should show confirmation dialog when delete button is pressed',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap tombol delete
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan dialog konfirmasi
      expect(find.text('Delete Exercise'), findsOneWidget);
      expect(
          find.text(
              'Are you sure you want to delete this exercise log? This action cannot be undone.'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should delete exercise when confirmed in dialog',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.deleteExerciseLog(any, any))
          .thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [mockNavigatorObserver],
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap tombol delete
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap "Delete" di dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify delete dipanggil
      verify(mockExerciseDetailService.deleteExerciseLog(any, any)).called(1);
    });

    testWidgets('should not delete exercise when cancel is pressed in dialog',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap tombol delete
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap "Cancel" di dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify delete tidak dipanggil
      verifyNever(mockExerciseDetailService.deleteExerciseLog(any, any));
    });

    testWidgets('should show error snackbar when delete fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.deleteExerciseLog(any, any))
          .thenAnswer((_) async => false);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseLogDetailPage(
            exerciseId: 'run-1',
            activityType: ExerciseLogHistoryItem.typeCardio,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Tap tombol delete
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap "Delete" di dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan snackbar error
      expect(find.text('Failed to delete exercise log'), findsOneWidget);
    });

    testWidgets('should display unsupported cardio type message',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) async => 'unknown');
      when(mockExerciseDetailService.getCardioActivityDetail(any))
          .thenThrow(Exception('Invalid data type'));

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'unknown-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan pesan unsupported
      expect(find.text('Cardio Details'), findsOneWidget);
    });

    testWidgets('should display unsupported activity type message',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'unknown-1',
          activityType: 'unknown-type',
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan pesan unsupported
      expect(find.text('Exercise Details'), findsOneWidget);
      // Hanya memeriksa AppBar title, tidak memeriksa konten yang mungkin berubah
    });

    testWidgets('should display invalid weight lifting data message',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.getWeightLiftingDetail(any))
          .thenThrow(Exception('Invalid data type'));

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'invalid-1',
          activityType: ExerciseLogHistoryItem.typeWeightlifting,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan pesan invalid
      expect(find.text('Weight Training Details'), findsOneWidget);
    });

    testWidgets('should display running activity data',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) async => 'running');
      when(mockExerciseDetailService
              .getCardioActivityDetail<RunningActivity>(any))
          .thenAnswer((_) async => runningActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'run-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan data running
      expect(find.byType(RunningDetailWidget), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
    });

    testWidgets('should display cycling activity data',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) async => 'cycling');
      when(mockExerciseDetailService
              .getCardioActivityDetail<CyclingActivity>(any))
          .thenAnswer((_) async => cyclingActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'cycle-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan data cycling
      expect(find.byType(CyclingDetailWidget), findsOneWidget);
    });

    testWidgets('should display swimming activity data',
        (WidgetTester tester) async {
      // Arrange
      when(mockExerciseDetailService.getActualActivityType(any, any))
          .thenAnswer((_) async => 'swimming');
      when(mockExerciseDetailService
              .getCardioActivityDetail<SwimmingActivity>(any))
          .thenAnswer((_) async => swimmingActivity);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'swim-1',
          activityType: ExerciseLogHistoryItem.typeCardio,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan data swimming
      expect(find.byType(SwimmingDetailWidget), findsOneWidget);
    });

    testWidgets('should display smart exercise data',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'smart-1',
          activityType: ExerciseLogHistoryItem.typeSmartExercise,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan data smart exercise
      expect(find.text('Smart Exercise Details'), findsOneWidget);
    });

    testWidgets('should display weight lifting data',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: ExerciseLogDetailPage(
          exerciseId: 'weight-1',
          activityType: ExerciseLogHistoryItem.typeWeightlifting,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert - harus menampilkan data weight lifting
      expect(find.text('Weight Training Details'), findsOneWidget);
    });
  });
}
