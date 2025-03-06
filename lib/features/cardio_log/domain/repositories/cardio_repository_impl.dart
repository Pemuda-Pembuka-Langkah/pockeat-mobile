import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cardio_activity.dart';
import '../models/cardio_activity_factory.dart';
import 'cardio_repository.dart';

/// Implementasi CardioRepository menggunakan Firebase Firestore
class CardioRepositoryImpl implements CardioRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'cardioActivities';
  
  CardioRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;
  
  @override
  Future<String> saveCardioActivity(CardioActivity activity) async {
    try {
      final docRef = _firestore.collection(_collection).doc(activity.id);
      await docRef.set(activity.toMap());
      return activity.id;
    } catch (e) {
      throw Exception('Failed to save cardio activity: $e');
    }
  }
  
  @override
  Future<CardioActivity?> getCardioActivityById(String id) async {
    try {
      final docSnapshot = await _firestore.collection(_collection).doc(id).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      return CardioActivityFactory.fromMap(data);
    } catch (e) {
      throw Exception('Failed to retrieve cardio activity: $e');
    }
  }
  
  @override
  Future<List<CardioActivity>> getAllCardioActivities() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CardioActivityFactory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve cardio activities: $e');
    }
  }
  
  @override
  Future<List<CardioActivity>> getCardioActivitiesByType(CardioType type) async {
    try {
      String typeString;
      switch (type) {
        case CardioType.running:
          typeString = 'running';
          break;
        case CardioType.cycling:
          typeString = 'cycling';
          break;
        case CardioType.swimming:
          typeString = 'swimming';
          break;
      }
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('type', isEqualTo: typeString)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CardioActivityFactory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve cardio activities by type: $e');
    }
  }
  
  @override
  Future<bool> deleteCardioActivity(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete cardio activity: $e');
    }
  }
} 