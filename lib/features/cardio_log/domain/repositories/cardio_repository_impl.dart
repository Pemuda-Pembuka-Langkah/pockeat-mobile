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
  
  @override
  Future<List<CardioActivity>> filterByDate(DateTime date) async {
    try {
      // Mendapatkan waktu awal hari (00:00:00)
      final startOfDay = DateTime(date.year, date.month, date.day);
      final startOfDayMs = startOfDay.millisecondsSinceEpoch;
      
      // Mendapatkan waktu akhir hari (23:59:59.999)
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      final endOfDayMs = endOfDay.millisecondsSinceEpoch;
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: startOfDayMs)
          .where('date', isLessThanOrEqualTo: endOfDayMs)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CardioActivityFactory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter cardio activities by date: $e');
    }
  }
  
  @override
  Future<List<CardioActivity>> filterByMonth(int month, int year) async {
    try {
      // Validasi bulan
      if (month < 1 || month > 12) {
        throw ArgumentError('Month must be between 1 and 12');
      }
      
      // Mendapatkan waktu awal bulan
      final startOfMonth = DateTime(year, month, 1);
      final startOfMonthMs = startOfMonth.millisecondsSinceEpoch;
      
      // Mendapatkan waktu akhir bulan (hari terakhir bulan tersebut)
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59, 999);
      final endOfMonthMs = endOfMonth.millisecondsSinceEpoch;
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: startOfMonthMs)
          .where('date', isLessThanOrEqualTo: endOfMonthMs)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CardioActivityFactory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter cardio activities by month: $e');
    }
  }
  
  @override
  Future<List<CardioActivity>> filterByYear(int year) async {
    try {
      // Mendapatkan waktu awal tahun
      final startOfYear = DateTime(year, 1, 1);
      final startOfYearMs = startOfYear.millisecondsSinceEpoch;
      
      // Mendapatkan waktu akhir tahun
      final endOfYear = DateTime(year, 12, 31, 23, 59, 59, 999);
      final endOfYearMs = endOfYear.millisecondsSinceEpoch;
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: startOfYearMs)
          .where('date', isLessThanOrEqualTo: endOfYearMs)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CardioActivityFactory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter cardio activities by year: $e');
    }
  }
  
  @override
  Future<List<CardioActivity>> getActivitiesWithLimit(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CardioActivityFactory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve cardio activities with limit: $e');
    }
  }
}