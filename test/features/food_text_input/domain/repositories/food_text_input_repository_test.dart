// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_text_input/domain/repositories/food_text_input_repository.dart';
import 'package:pockeat/firebase/firebase_repository.dart';
import 'food_text_input_repository_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, QuerySnapshot, 
QueryDocumentSnapshot, DocumentReference, DocumentSnapshot])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocument;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late FoodTextInputRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocument = MockQueryDocumentSnapshot();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();

    when(mockFirestore.collection(any)).thenReturn(mockCollection);

    when(mockCollection.orderBy(any, descending: anyNamed('descending')))
      .thenReturn(mockCollection);
    
    when(mockCollection.where(any, isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo')))
      .thenReturn(mockCollection);
    when(mockCollection.where(any, isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo')))
      .thenReturn(mockCollection);

    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.id).thenReturn('testId');
    when(mockDocument.data()).thenReturn({'timestamp': DateTime.now().millisecondsSinceEpoch});

    when(mockCollection.doc(any)).thenReturn(mockDocumentReference);

    when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
    when(mockDocumentSnapshot.exists).thenReturn(true);

    when(mockDocumentReference.delete()).thenAnswer((_) async => Future.value());

    repository = FoodTextInputRepository(firestore: mockFirestore);
  });

  test('FoodTextInputRepository initializes correctly', () {
    expect(repository, isA<FoodTextInputRepository>());
  });

  test('getAll calls BaseFirestoreRepository.getAll with default parameters', () async {
    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.id).thenReturn('testId');
    when(mockDocument.data()).thenReturn({'timestamp': DateTime.now().millisecondsSinceEpoch});

    final results = await repository.getAll();
    expect(results, isA<List<FoodAnalysisResult>>());
  });

  test('getAnalysisResultsByDate calls BaseFirestoreRepository.getByDate', () async {
    final testDate = DateTime(2025, 3, 24);
    
    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.id).thenReturn('testId');
    when(mockDocument.data()).thenReturn({'timestamp': testDate.millisecondsSinceEpoch});

    final results = await repository.getAnalysisResultsByDate(testDate);
    expect(results, isA<List<FoodAnalysisResult>>());
  });

  test('getAnalysisResultsByMonth calls BaseFirestoreRepository.getByMonth', () async {
    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.id).thenReturn('testId');
    when(mockDocument.data()).thenReturn({'timestamp': DateTime(2025, 3, 24).millisecondsSinceEpoch});

    final results = await repository.getAnalysisResultsByMonth(3, 2025);
    expect(results, isA<List<FoodAnalysisResult>>());
  });

  test('getAnalysisResultsByYear calls BaseFirestoreRepository.getByYear', () async {
    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocument]);
    when(mockDocument.id).thenReturn('testId');
    when(mockDocument.data()).thenReturn({'timestamp': DateTime(2025, 1, 1).millisecondsSinceEpoch});

    final results = await repository.getAnalysisResultsByYear(2025);
    expect(results, isA<List<FoodAnalysisResult>>());
  });

  test('deleteById calls BaseFirestoreRepository.deleteById', () async {
    final testId = '1234';

    when(mockCollection.doc(testId)).thenReturn(mockDocumentReference);

    when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
    when(mockDocumentSnapshot.exists).thenReturn(true);

    when(mockDocumentReference.delete()).thenAnswer((_) async {});

    final result = await repository.deleteById(testId);
    expect(result, isTrue);
  });
}
