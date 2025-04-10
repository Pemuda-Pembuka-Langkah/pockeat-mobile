import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
import 'health_metrics_check_service_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  late HealthMetricsCheckService service;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    // Set up the firestore call chain
    when(mockFirestore.collection('health_metrics')).thenReturn(mockCollectionRef);
    when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);

    service = HealthMetricsCheckService(firestore: mockFirestore);
  });

  test('returns true when document exists', () async {
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
    when(mockDocSnapshot.exists).thenReturn(true);

    final result = await service.hasCompletedOnboarding('test-user-id');

    expect(result, isTrue);
    verify(mockFirestore.collection('health_metrics')).called(1);
    verify(mockCollectionRef.doc('test-user-id')).called(1);
    verify(mockDocRef.get()).called(1);
  });

  test('returns false when document does not exist', () async {
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
    when(mockDocSnapshot.exists).thenReturn(false);

    final result = await service.hasCompletedOnboarding('test-user-id');

    expect(result, isFalse);
  });

  test('returns false on exception', () async {
    when(mockDocRef.get()).thenThrow(Exception('Firestore error'));

    final result = await service.hasCompletedOnboarding('test-user-id');

    expect(result, isFalse);
  });
}
