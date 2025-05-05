// health_metrics_repository_test.dart

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository_impl.dart';
import 'health_metrics_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockSnapshot;
  late HealthMetricsRepositoryImpl repository;

  const userId = 'test-user';
  final testModel = HealthMetricsModel(
    userId: userId,
    height: 180.0,
    weight: 75.0,
    age: 28,
    gender: 'male',
    activityLevel: 'moderate',
    fitnessGoal: 'Maintain',
    bmi: 23.1,
    bmiCategory: 'Normal',
    desiredWeight: 72.0,
  );

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    when(mockFirestore.collection('health_metrics')).thenReturn(mockCollection);
    when(mockCollection.doc(userId)).thenReturn(mockDocumentRef);

    repository = HealthMetricsRepositoryImpl(firestore: mockFirestore);
  });

  test('HealthMetricsRepositoryImpl initializes correctly', () {
    expect(repository, isA<HealthMetricsRepositoryImpl>());
  });

  test('saveHealthMetrics calls Firestore set with merge option', () async {
    await repository.saveHealthMetrics(testModel);

    verify(mockFirestore.collection('health_metrics')).called(1);
    verify(mockCollection.doc(userId)).called(1);
    verify(mockDocumentRef.set(
        testModel.toMap(),
        argThat(isA<SetOptions>()), // <<-- expect any SetOptions
      )).called(1);
  });

  test('getHealthMetrics returns HealthMetricsModel when document exists', () async {
    when(mockDocumentRef.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.data()).thenReturn(testModel.toMap());
    when(mockSnapshot.id).thenReturn(userId);

    final result = await repository.getHealthMetrics(userId);

    expect(result, isNotNull);
    expect(result, isA<HealthMetricsModel>());
    expect(result!.userId, userId);
    expect(result.height, 180.0);
    expect(result.weight, 75.0);
    expect(result.age, 28);
    expect(result.gender, 'male');
    expect(result.activityLevel, 'moderate');
    expect(result.fitnessGoal, 'Maintain');
    expect(result.desiredWeight, 72.0);
  });

  test('getHealthMetrics returns null when document does not exist', () async {
    when(mockDocumentRef.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(false);

    final result = await repository.getHealthMetrics(userId);

    expect(result, isNull);
  });

  test('saveHealthMetrics throws exception when Firestore write fails', () async {
    when(mockDocumentRef.set(any, any)).thenThrow(
      FirebaseException(plugin: 'firestore', message: 'Write error'),
    );

    expect(
      () => repository.saveHealthMetrics(testModel),
      throwsA(isA<Exception>()),
    );
  });

  test('getHealthMetrics throws exception when Firestore read fails', () async {
    when(mockDocumentRef.get()).thenThrow(
      FirebaseException(plugin: 'firestore', message: 'Read error'),
    );

    expect(
      () => repository.getHealthMetrics(userId),
      throwsA(isA<Exception>()),
    );
  });
}
