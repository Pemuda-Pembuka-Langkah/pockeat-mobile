import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFirestoreRepository<T> {
  final FirebaseFirestore _firestore;
  final String collectionName;
  
  // Function to convert T to Map
  final Map<String, dynamic> Function(T item) toMap;
  // Function to convert Map to T
  final T Function(Map<String, dynamic> map, String id) fromMap;


// coverage:ignore-start
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
      if (!docSnapshot.exists || docSnapshot.data() == null) return null;

      final data = docSnapshot.data();
      if (data is Map<String, dynamic>) {
        return fromMap(data, docSnapshot.id);
      }
      throw Exception('Document data is not in the expected format');
    } catch (e) {
      throw Exception('Failed to retrieve item: $e');
    }
  }

  Future<List<T>> getAll({
    String? orderBy,
    bool descending = true,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data is Map<String, dynamic>) {
              return fromMap(data, doc.id);
            }
            throw Exception('Document data is not in the expected format');
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve items: $e');
    }
  }
  
  /// Retrieves items by date using a timestamp field
  /// 
  /// Parameter [date] to filter results by a specific date
  /// Parameter [timestampField] the field name that contains the timestamp
  /// Parameter [limit] to restrict the number of returned results
  /// Parameter [descending] to control the sort order
  /// Returns [List<T>] containing items on the specified date
  Future<List<T>> getByDate({
    required DateTime date,
    required String timestampField,
    int? limit,
    bool descending = true,
  }) async {
    try {
      // Create timestamp for the start of the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final startTimestamp = Timestamp.fromDate(startOfDay);
      
      // Create timestamp for the end of the day
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      final endTimestamp = Timestamp.fromDate(endOfDay);
      
      var query = _firestore
          .collection(collectionName)
          .where(timestampField, isGreaterThanOrEqualTo: startTimestamp)
          .where(timestampField, isLessThanOrEqualTo: endTimestamp)
          .orderBy(timestampField, descending: descending);
      
      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return fromMap(data, doc.id);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve items by date: $e');
    }
  }
  
  /// Retrieves items by month and year using a timestamp field
  /// 
  /// Parameters [month] (1-12) and [year] to filter results
  /// Parameter [timestampField] the field name that contains the timestamp
  /// Parameter [limit] to restrict the number of returned results
  /// Parameter [descending] to control the sort order
  /// Returns [List<T>] containing items on the specified month and year
  Future<List<T>> getByMonth({
    required int month,
    required int year,
    required String timestampField,
    int? limit,
    bool descending = true,
  }) async {
    try {
      // Validate month
      if (month < 1 || month > 12) {
        throw ArgumentError('Month must be between 1 and 12');
      }
      
      // Create timestamp for the start of the month
      final startOfMonth = DateTime(year, month, 1);
      final startTimestamp = Timestamp.fromDate(startOfMonth);
      
      // Create timestamp for the end of the month
      final endOfMonth = month < 12 
          ? DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1))
          : DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      final endTimestamp = Timestamp.fromDate(endOfMonth);
      
      var query = _firestore
          .collection(collectionName)
          .where(timestampField, isGreaterThanOrEqualTo: startTimestamp)
          .where(timestampField, isLessThanOrEqualTo: endTimestamp)
          .orderBy(timestampField, descending: descending);
      
      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return fromMap(data, doc.id);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve items by month: $e');
    }
  }
  
  /// Retrieves items by year using a timestamp field
  /// 
  /// Parameter [year] to filter results
  /// Parameter [timestampField] the field name that contains the timestamp
  /// Parameter [limit] to restrict the number of returned results
  /// Parameter [descending] to control the sort order
  /// Returns [List<T>] containing items on the specified year
  Future<List<T>> getByYear({
    required int year,
    required String timestampField,
    int? limit,
    bool descending = true,
  }) async {
    try {
      // Create timestamp for the start of the year
      final startOfYear = DateTime(year, 1, 1);
      final startTimestamp = Timestamp.fromDate(startOfYear);
      
      // Create timestamp for the end of the year
      final endOfYear = DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      final endTimestamp = Timestamp.fromDate(endOfYear);
      
      var query = _firestore
          .collection(collectionName)
          .where(timestampField, isGreaterThanOrEqualTo: startTimestamp)
          .where(timestampField, isLessThanOrEqualTo: endTimestamp)
          .orderBy(timestampField, descending: descending);
      
      // Apply limit if provided
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return fromMap(data, doc.id);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve items by year: $e');
    }
  }
  
  /// Deletes an item by its ID
  /// 
  /// Parameter [id] the unique identifier of the item to delete
  /// Returns [bool] true if successfully deleted, false if the document doesn't exist
  Future<bool> deleteById(String id) async {
    try {
      // Check if document exists first
      final docRef = _firestore.collection(collectionName).doc(id);
      final docSnapshot = await docRef.get();
      
      // If document doesn't exist, return false
      if (!docSnapshot.exists) {
        return false;
      }
      
      // Delete the document and return true
      await docRef.delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // coverage:ignore-end
}