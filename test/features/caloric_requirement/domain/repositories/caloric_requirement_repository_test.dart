import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository_impl.dart';

import 'caloric_requirement_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockSnapshot;
  late CaloricRequirementRepositoryImpl repository;

  const userId = 'test-user';
  final timestamp = DateTime(2024, 4, 12, 10, 0, 0);
  final testModel = CaloricRequirementModel(
    userId: userId,
    bmr: 1500.0,
    tdee: 2000.0,
    timestamp: timestamp,
  );

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    when(mockFirestore.collection('caloric_requirements')).thenReturn(mockCollection);
    when(mockCollection.doc(userId)).thenReturn(mockDocRef);

    repository = CaloricRequirementRepositoryImpl(firestore: mockFirestore);
  });

  test('CaloricRequirementRepositoryImpl initializes correctly', () {
    expect(repository, isA<CaloricRequirementRepositoryImpl>());
  });

  test('saveCaloricRequirement stores data successfully', () async {
    await repository.saveCaloricRequirement(userId: userId, result: testModel);

    verify(mockFirestore.collection('caloric_requirements')).called(1);
    verify(mockCollection.doc(userId)).called(1);
    verify(mockDocRef.set(testModel.toMap(), any)).called(1);
  });

  test('saveCaloricRequirement throws exception on Firestore failure', () async {
    when(mockDocRef.set(any, any)).thenThrow(FirebaseException(
      plugin: 'firestore',
      message: 'Write failed',
    ));

    expect(
      () => repository.saveCaloricRequirement(userId: userId, result: testModel),
      throwsException,
    );
  });

  test('getCaloricRequirement returns model if document exists', () async {
    when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.id).thenReturn(userId);
    when(mockSnapshot.data()).thenReturn({
      'userId': userId,
      'bmr': 1500.0,
      'tdee': 2000.0,
      'timestamp': timestamp.toIso8601String(),
    });

    final result = await repository.getCaloricRequirement(userId);

    expect(result, isA<CaloricRequirementModel>());
    expect(result?.bmr, 1500.0);
    expect(result?.tdee, 2000.0);
    expect(result?.timestamp, timestamp);
    expect(result?.userId, userId);
  });

  test('getCaloricRequirement returns null if document does not exist', () async {
    when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(false);

    final result = await repository.getCaloricRequirement(userId);

    expect(result, isNull);
  });

  test('getCaloricRequirement throws exception on Firestore failure', () async {
    when(mockDocRef.get()).thenThrow(FirebaseException(
      plugin: 'firestore',
      message: 'Read failed',
    ));

    expect(() => repository.getCaloricRequirement(userId), throwsException);
  });
}