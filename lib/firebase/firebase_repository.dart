import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFirestoreRepository<T> {
  final FirebaseFirestore _firestore;
  final String collectionName;
  
  // Function to convert T to Map
  final Map<String, dynamic> Function(T item) toMap;
  // Function to convert Map to T
  final T Function(Map<String, dynamic> map, String id) fromMap;

  BaseFirestoreRepository({
    FirebaseFirestore? firestore,
    required this.collectionName,
    required this.toMap,
    required this.fromMap,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> save(T item, String id) async {
    try {
      final docRef = _firestore.collection(collectionName).doc(id);
      await docRef.set(toMap(item));
      return id;
    } catch (e) {
      throw Exception('Failed to save item: $e');
    }
  }

  Future<T?> getById(String id) async {
    try {
      final docSnapshot = await _firestore.collection(collectionName).doc(id).get();
      if (!docSnapshot.exists) return null;

      return fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
    } catch (e) {
      throw Exception('Failed to retrieve item: $e');
    }
  }

  Future<List<T>> getAll({
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve items: $e');
    }
  }
}