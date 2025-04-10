import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository_impl.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

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

  test('saveHealthMetrics stores data with correct userId', () async {
    await repository.saveHealthMetrics(testModel);

    verify(mockFirestore.collection('health_metrics')).called(1);
    verify(mockCollection.doc(userId)).called(1);
    verify(mockDocumentRef.set(testModel.toMap(), any)).called(1);
  });

  test('getHealthMetrics returns a valid model if document exists', () async {
    when(mockDocumentRef.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.data()).thenReturn(testModel.toMap());
    when(mockSnapshot.id).thenReturn(userId);

    final result = await repository.getHealthMetrics(userId);

    expect(result, isA<HealthMetricsModel>());
    expect(result?.userId, equals(userId));
    expect(result?.height, equals(180.0));
    expect(result?.weight, equals(75.0));
    expect(result?.age, equals(28));
    expect(result?.gender, equals('male'));
    expect(result?.activityLevel, equals('moderate'));
    expect(result?.fitnessGoal, equals('Maintain'));
  });

  test('getHealthMetrics returns null if document does not exist', () async {
    when(mockDocumentRef.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(false);

    final result = await repository.getHealthMetrics(userId);

    expect(result, isNull);
  });

  test('saveHealthMetrics throws exception on Firestore failure', () async {
    when(mockDocumentRef.set(any, any)).thenThrow(FirebaseException(
      plugin: 'firestore',
      message: 'Write error',
    ));

    expect(() => repository.saveHealthMetrics(testModel), throwsException);
  });

  test('getHealthMetrics throws exception on Firestore failure', () async {
    when(mockDocumentRef.get()).thenThrow(FirebaseException(
      plugin: 'firestore',
      message: 'Read error',
    ));

    expect(() => repository.getHealthMetrics(userId), throwsException);
  });
}