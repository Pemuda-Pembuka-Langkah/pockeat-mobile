// lib/features/weights_history/domain/repositories/weight_history_repository_impl_test.dart

// Package imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports
import 'package:pockeat/features/weight_history/domain/repositories/weight_history_repository_impl.dart';
import 'package:pockeat/features/weight_history/domain/models/weight_history_entry.dart';

import 'weight_history_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockHealthMetricsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDocument;
  late MockCollectionReference<Map<String, dynamic>> mockWeightsHistoryCollection;
  late WeightHistoryRepositoryImpl repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockHealthMetricsCollection = MockCollectionReference();
    mockUserDocument = MockDocumentReference();
    mockWeightsHistoryCollection = MockCollectionReference();

    when(mockFirestore.collection('health_metrics')).thenReturn(mockHealthMetricsCollection);
    when(mockHealthMetricsCollection.doc(any)).thenReturn(mockUserDocument);
    when(mockUserDocument.collection('weights_history')).thenReturn(mockWeightsHistoryCollection);

    repository = WeightHistoryRepositoryImpl(firestore: mockFirestore);
  });

  group('WeightHistoryRepositoryImpl', () {
    test('addWeightEntry should add weight entry to Firestore', () async {
      // Arrange
      final userId = 'testUserId';
      final weight = 65.0;
      final timestamp = DateTime.now();

      when(mockWeightsHistoryCollection.add(any)).thenAnswer((_) async => MockDocumentReference());

      // Act
      await repository.addWeightEntry(
        userId: userId,
        weight: weight,
        timestamp: timestamp,
      );

      // Assert
      verify(mockFirestore.collection('health_metrics')).called(1);
      verify(mockHealthMetricsCollection.doc(userId)).called(1);
      verify(mockUserDocument.collection('weights_history')).called(1);

      final captured = verify(mockWeightsHistoryCollection.add(captureAny)).captured.single as Map<String, dynamic>;
      expect(captured['weight'], weight);
      expect(captured['timestamp'], isA<DateTime>());
    });

    test('addWeightEntry throws an Exception if FirebaseException occurs', () async {
      // Arrange
      final userId = 'testUserId';
      final weight = 65.0;
      final timestamp = DateTime.now();

      when(mockWeightsHistoryCollection.add(any)).thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to write',
      ));

      // Act & Assert
      expect(
        () async => await repository.addWeightEntry(
          userId: userId,
          weight: weight,
          timestamp: timestamp,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
