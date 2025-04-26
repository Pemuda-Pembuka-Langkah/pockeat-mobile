// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';

void main() {
  group('NotificationModel', () {
    final DateTime testTime = DateTime(2023, 1, 1, 10, 0);
    final DateTime newTime = DateTime(2023, 1, 2, 15, 30);
    
    test('should create a NotificationModel with provided values', () {
      final notification = NotificationModel(
        id: 'test-id',
        title: 'Test Title',
        body: 'Test Body',
        payload: 'test_payload',
        scheduledTime: testTime,
        isRead: true,
        imageUrl: 'https://example.com/pet_sad.png',
      );
      
      expect(notification.id, 'test-id');
      expect(notification.title, 'Test Title');
      expect(notification.body, 'Test Body');
      expect(notification.payload, 'test_payload');
      expect(notification.scheduledTime, testTime);
      expect(notification.isRead, true);
      expect(notification.imageUrl, 'https://example.com/pet_sad.png');
    });
    
    test('should create a NotificationModel with generated id when not provided', () {
      final notification = NotificationModel(
        title: 'Test Title',
        body: 'Test Body',
        scheduledTime: testTime,
      );
      
      expect(notification.id, isNotNull);
      expect(notification.id.isNotEmpty, true);
      expect(notification.title, 'Test Title');
      expect(notification.body, 'Test Body');
      expect(notification.payload, isNull);
      expect(notification.scheduledTime, testTime);
      expect(notification.isRead, false);
      expect(notification.imageUrl, isNull);
    });
    
    test('should create daily calorie reminder notification', () {
      final notification = NotificationModel(
        title: 'Pengingat Kalori Harian',
        body: 'Jangan lupa untuk melacak asupan kalori hari ini!',
        payload: 'daily_calorie_tracking',
        scheduledTime: testTime,
      );
      
      expect(notification.id, isNotNull);
      expect(notification.title, 'Pengingat Kalori Harian');
      expect(notification.body, 'Jangan lupa untuk melacak asupan kalori hari ini!');
      expect(notification.payload, 'daily_calorie_tracking');
      expect(notification.scheduledTime, testTime);
      expect(notification.isRead, false);
    });
    
    test('should copy with new values', () {
      final original = NotificationModel(
        id: 'original-id',
        title: 'Original Title',
        body: 'Original Body',
        payload: 'original_payload',
        scheduledTime: testTime,
        isRead: false,
        imageUrl: 'https://example.com/original.png',
      );
      
      final updated = original.copyWith(
        title: 'Updated Title',
        isRead: true,
        imageUrl: 'https://example.com/updated.png',
      );
      
      // Memastikan nilai yang diperbarui sudah berubah
      expect(updated.title, 'Updated Title');
      expect(updated.isRead, true);
      expect(updated.imageUrl, 'https://example.com/updated.png');
      
      // Memastikan nilai yang tidak diperbarui tetap sama
      expect(updated.id, 'original-id');
      expect(updated.body, 'Original Body');
      expect(updated.payload, 'original_payload');
      expect(updated.scheduledTime, testTime);
      
      // Memastikan objek asli tidak dimodifikasi (immutability)
      expect(original.title, 'Original Title');
      expect(original.isRead, false);
      expect(original.imageUrl, 'https://example.com/original.png');
    });
    
    test('should convert to and from map', () {
      final original = NotificationModel(
        id: 'map-test-id',
        title: 'Map Test',
        body: 'Testing toMap and fromMap',
        payload: 'map_test',
        scheduledTime: testTime,
        isRead: true,
        imageUrl: 'https://example.com/pet.png',
      );
      
      final map = original.toMap();
      final fromMap = NotificationModel.fromMap(map);
      
      expect(fromMap.id, original.id);
      expect(fromMap.title, original.title);
      expect(fromMap.body, original.body);
      expect(fromMap.payload, original.payload);
      expect(fromMap.scheduledTime.millisecondsSinceEpoch, original.scheduledTime.millisecondsSinceEpoch);
      expect(fromMap.isRead, original.isRead);
      expect(fromMap.imageUrl, original.imageUrl);
    });
    
    test('should handle null payload and imageUrl in toMap and fromMap', () {
      final original = NotificationModel(
        id: 'null-payload-id',
        title: 'Null Payload Test',
        body: 'Testing with null payload',
        payload: null,
        scheduledTime: testTime,
        isRead: false,
        imageUrl: null,
      );
      
      final map = original.toMap();
      final fromMap = NotificationModel.fromMap(map);
      
      expect(fromMap.payload, isNull);
      expect(fromMap.imageUrl, isNull);
    });
    
    test('should handle default isRead value in fromMap', () {
      final map = {
        'id': 'default-is-read-id',
        'title': 'Default isRead Test',
        'body': 'Testing default isRead value',
        'payload': 'test_payload',
        'scheduledTime': testTime.millisecondsSinceEpoch,
        // isRead tidak ada di map
        'imageUrl': 'https://example.com/default.png',
      };
      
      final fromMap = NotificationModel.fromMap(map);
      
      expect(fromMap.isRead, false); // Memastikan nilai default false digunakan
      expect(fromMap.imageUrl, 'https://example.com/default.png');
    });
    
    test('copyWith should preserve values when called without parameters', () {
      // Arrange
      final original = NotificationModel(
        id: 'test-id',
        title: 'Test Title',
        body: 'Test Body',
        payload: 'test_payload',
        scheduledTime: testTime,
        isRead: false,
        imageUrl: 'https://example.com/test.png',
      );
      
      // Act
      final copied = original.copyWith();
      
      // Assert
      expect(copied.id, 'test-id');
      expect(copied.title, 'Test Title');
      expect(copied.body, 'Test Body');
      expect(copied.payload, 'test_payload');
      expect(copied.scheduledTime, testTime);
      expect(copied.isRead, false);
      expect(copied.imageUrl, 'https://example.com/test.png');
      expect(identical(original, copied), isFalse); // Memastikan objek berbeda
    });
    
    test('copyWith should update all fields when provided', () {
      // Arrange
      final original = NotificationModel(
        id: 'original-id',
        title: 'Original Title',
        body: 'Original Body',
        payload: 'original_payload',
        scheduledTime: testTime,
        isRead: false,
      );
      
      // Act
      final allUpdated = original.copyWith(
        id: 'updated-id',
        title: 'Updated Title',
        body: 'Updated Body',
        payload: 'updated_payload',
        scheduledTime: newTime,
        isRead: true,
      );
      
      // Assert
      expect(allUpdated.id, 'updated-id');
      expect(allUpdated.title, 'Updated Title');
      expect(allUpdated.body, 'Updated Body');
      expect(allUpdated.payload, 'updated_payload');
      expect(allUpdated.scheduledTime, newTime);
      expect(allUpdated.isRead, true);
    });
    
    test('toMap should include all properties in the map', () {
      // Arrange
      final notification = NotificationModel(
        id: 'map-id',
        title: 'Map Title',
        body: 'Map Body',
        payload: 'map_payload',
        scheduledTime: testTime,
        isRead: true,
      );
      
      // Act
      final map = notification.toMap();
      
      // Assert
      expect(map.keys, containsAll(['id', 'title', 'body', 'payload', 'scheduledTime', 'isRead']));
      expect(map['id'], 'map-id');
      expect(map['title'], 'Map Title');
      expect(map['body'], 'Map Body');
      expect(map['payload'], 'map_payload');
      expect(map['scheduledTime'], testTime.millisecondsSinceEpoch);
      expect(map['isRead'], true);
    });
    
    test('fromMap should create identical model when converting back and forth', () {
      // Arrange
      final original = NotificationModel(
        id: 'identity-id',
        title: 'Identity Title',
        body: 'Identity Body',
        payload: 'identity_payload',
        scheduledTime: testTime,
        isRead: true,
      );
      
      // Act
      final map = original.toMap();
      final recreated = NotificationModel.fromMap(map);
      
      // Assert - test deep equality
      expect(recreated.id, original.id);
      expect(recreated.title, original.title);
      expect(recreated.body, original.body);
      expect(recreated.payload, original.payload);
      expect(recreated.scheduledTime.millisecondsSinceEpoch, 
             original.scheduledTime.millisecondsSinceEpoch);
      expect(recreated.isRead, original.isRead);
    });
    
    test('should generate different ids for different instances', () {
      // Arrange & Act
      final notification1 = NotificationModel(
        title: 'Title 1',
        body: 'Body 1',
        scheduledTime: testTime,
      );
      
      final notification2 = NotificationModel(
        title: 'Title 2',
        body: 'Body 2',
        scheduledTime: testTime,
      );
      
      // Assert
      expect(notification1.id, isNot(equals(notification2.id)));
    });
  });
} 
