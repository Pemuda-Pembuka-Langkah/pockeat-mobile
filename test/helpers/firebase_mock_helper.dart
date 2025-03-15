// test/helpers/firebase_mock_helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

// Mock for FirebaseApp
class MockFirebaseApp extends Mock implements FirebaseApp {}

// Mock for FirebaseFirestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return MockCollectionReference();
  }
}

// Mock for CollectionReference
class MockCollectionReference<T extends Object?> extends Mock implements CollectionReference<T> {
  @override
  Query<T> orderBy(Object field, {bool descending = false}) {
    return MockQuery<T>();
  }
}

// Mock for Query
class MockQuery<T extends Object?> extends Mock implements Query<T> {
  @override
  Query<T> startAt(Iterable<Object?> values) {
    return this;
  }
  
  @override
  Query<T> endAt(Iterable<Object?> values) {
    return this;
  }
  
  @override
  Query<T> limit(int limit) {
    return this;
  }
  
  @override
  Future<QuerySnapshot<T>> get([GetOptions? options]) async {
    return MockQuerySnapshot<T>();
  }
}

// Mock for QuerySnapshot
class MockQuerySnapshot<T extends Object?> extends Mock implements QuerySnapshot<T> {
  @override
  List<QueryDocumentSnapshot<T>> get docs => [];
}

// Setup function to provide mocked Firebase instances
class FirebaseMockHelper {
  static MockFirebaseFirestore getFirestoreMock() {
    return MockFirebaseFirestore();
  }
}