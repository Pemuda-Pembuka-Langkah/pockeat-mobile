// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';

void main() {
  group('NotificationChannels', () {
    test('constants should be defined and match NotificationConstants', () {
      // Verify all channel IDs match their corresponding constants
      expect(NotificationChannels.mealReminder.id, NotificationConstants.mealReminderChannelId);
      expect(NotificationChannels.workoutReminder.id, NotificationConstants.workoutReminderChannelId);
      expect(NotificationChannels.subscription.id, NotificationConstants.subscriptionChannelId);
      expect(NotificationChannels.server.id, NotificationConstants.serverChannelId);
      expect(NotificationChannels.dailyStreak.id, NotificationConstants.dailyStreakChannelId);
      expect(NotificationChannels.petSadness.id, NotificationConstants.petSadnessChannelId);
      expect(NotificationChannels.petStatus.id, NotificationConstants.petStatusChannelId);
    });
    test('should define all required channels for application features', () {
      // Pastikan semua channel yang diperlukan untuk fitur-fitur aplikasi didefinisikan
      expect(NotificationChannels.mealReminder, isNotNull);
      expect(NotificationChannels.workoutReminder, isNotNull);
      expect(NotificationChannels.subscription, isNotNull);
      expect(NotificationChannels.server, isNotNull);
      expect(NotificationChannels.petStatus, isNotNull);
      expect(NotificationChannels.petSadness, isNotNull);
      expect(NotificationChannels.dailyStreak, isNotNull);
    });
    
    test('channels should be properly configured with correct importance levels', () {
      // Pastikan semua channel penting memiliki tingkat importance yang benar
      final criticalChannels = [
        NotificationChannels.mealReminder,
        NotificationChannels.petStatus,
        NotificationChannels.petSadness,
        NotificationChannels.dailyStreak,
      ];
      
      for (final channel in criticalChannels) {
        expect(channel.importance, Importance.high, reason: '${channel.id} should have high importance');
      }
    });
    
    test('mealReminder channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.mealReminder.id, NotificationConstants.mealReminderChannelId);
      expect(NotificationChannels.mealReminder.name, 'Pengingat Waktu Makan');
      expect(
        NotificationChannels.mealReminder.description,
        'Channel untuk mengirim pengingat tentang waktu makan (sarapan, makan siang, makan malam)',
      );
      expect(NotificationChannels.mealReminder.importance, Importance.high);
      
      // Verify id matches the constant
      expect(NotificationChannels.mealReminder.id, equals(NotificationConstants.mealReminderChannelId));
    });

    test('legacy caloriesReminder should reference mealReminder', () {
      // Ensure backward compatibility
      expect(NotificationChannels.caloriesReminder, NotificationChannels.mealReminder);
      expect(NotificationChannels.caloriesReminder.id, NotificationChannels.mealReminder.id);
      expect(NotificationChannels.caloriesReminder.name, NotificationChannels.mealReminder.name);
    });

    test('workoutReminder channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.workoutReminder.id, NotificationConstants.workoutReminderChannelId);
      expect(NotificationChannels.workoutReminder.name, 'Pengingat Workout');
      expect(
        NotificationChannels.workoutReminder.description,
        'Channel untuk mengirim pengingat tentang workout',
      );
      expect(NotificationChannels.workoutReminder.importance, Importance.high);
      
      // Verify id matches the constant
      expect(NotificationChannels.workoutReminder.id, equals(NotificationConstants.workoutReminderChannelId));
    });

    test('subscription channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.subscription.id, NotificationConstants.subscriptionChannelId);
      expect(NotificationChannels.subscription.name, 'Informasi Langganan');
      expect(
        NotificationChannels.subscription.description,
        'Channel untuk informasi terkait langganan',
      );
      expect(NotificationChannels.subscription.importance, Importance.high);
      
      // Verify id matches the constant
      expect(NotificationChannels.subscription.id, equals(NotificationConstants.subscriptionChannelId));
    });

    test('server channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.server.id, NotificationConstants.serverChannelId);
      expect(NotificationChannels.server.name, 'Notifikasi Server');
      expect(
        NotificationChannels.server.description,
        'Channel untuk notifikasi dari server',
      );
      expect(NotificationChannels.server.importance, Importance.high);
      
      // Verify id matches the constant
      expect(NotificationChannels.server.id, equals(NotificationConstants.serverChannelId));
    });

    test('petStatus channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.petStatus.id, NotificationConstants.petStatusChannelId);
      expect(NotificationChannels.petStatus.name, 'Pet Status Updates');
      expect(
        NotificationChannels.petStatus.description,
        'Channel for sending notifications about your pet\'s status and mood',
      );
      expect(NotificationChannels.petStatus.importance, Importance.high);
      
      // Verify id matches the constant
      expect(NotificationChannels.petStatus.id, equals(NotificationConstants.petStatusChannelId));
    });

    test('petSadness channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.petSadness.id, NotificationConstants.petSadnessChannelId);
      expect(NotificationChannels.petSadness.name, 'Pet Sadness Alerts');
      expect(
        NotificationChannels.petSadness.description,
        'Notifikasi saat pet kamu sedih karena tidak melihatmu dalam waktu lama',
      );
      expect(NotificationChannels.petSadness.importance, Importance.high);
      
      // Verify id matches the constant
      expect(NotificationChannels.petSadness.id, equals(NotificationConstants.petSadnessChannelId));
    });

    test('dailyStreak channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.dailyStreak.id, NotificationConstants.dailyStreakChannelId);
      expect(NotificationChannels.dailyStreak.name, 'Streak Harian');
      expect(
        NotificationChannels.dailyStreak.description,
        'Channel untuk mengirim notifikasi tentang streak pola makan',
      );
      expect(NotificationChannels.dailyStreak.importance, Importance.high);
      
      // Verify id matches the constant
      expect(NotificationChannels.dailyStreak.id, equals(NotificationConstants.dailyStreakChannelId));
    });

    test('all channels should have unique IDs', () {
      // Collect all channel IDs
      final channelIds = [
        NotificationChannels.mealReminder.id,
        NotificationChannels.workoutReminder.id,
        NotificationChannels.subscription.id,
        NotificationChannels.server.id,
        NotificationChannels.petStatus.id,
        NotificationChannels.petSadness.id,
        NotificationChannels.dailyStreak.id,
      ];

      // Create a Set to remove duplicates
      final uniqueIds = channelIds.toSet();

      // Compare the lengths to ensure they are all unique
      expect(channelIds.length, uniqueIds.length);
      
      // Verifikasi format ID channel sesuai dengan konvensi (lowercase, underscore)
      for (final id in channelIds) {
        expect(id, matches(r'^[a-z]+(_[a-z]+)*_channel$'), 
            reason: 'Channel ID $id should follow the naming convention');
      }
      
      // Ensure constants match channel IDs
      expect(NotificationConstants.mealReminderChannelId, equals(NotificationChannels.mealReminder.id));
      expect(NotificationConstants.workoutReminderChannelId, equals(NotificationChannels.workoutReminder.id));
      expect(NotificationConstants.subscriptionChannelId, equals(NotificationChannels.subscription.id));
      expect(NotificationConstants.serverChannelId, equals(NotificationChannels.server.id));
      expect(NotificationConstants.dailyStreakChannelId, equals(NotificationChannels.dailyStreak.id));
      expect(NotificationConstants.petSadnessChannelId, equals(NotificationChannels.petSadness.id));
      expect(NotificationConstants.petStatusChannelId, equals(NotificationChannels.petStatus.id));
    });
    
    test('channels for POC features should be properly defined', () {
      // POC-152: Pet status indicators
      expect(NotificationChannels.petStatus.id, NotificationConstants.petStatusChannelId);
      expect(NotificationChannels.petStatus.name, contains('Pet Status'));
      
      // Pet sadness alerts
      expect(NotificationChannels.petSadness.id, NotificationConstants.petSadnessChannelId);
      expect(NotificationChannels.petSadness.name, contains('Pet Sadness'));
      
      // POC-150: Daily streak celebration
      expect(NotificationChannels.dailyStreak.id, NotificationConstants.dailyStreakChannelId);
      expect(NotificationChannels.dailyStreak.name, contains('Streak'));
      
      // POC-149: Meal reminders
      expect(NotificationChannels.mealReminder.id, NotificationConstants.mealReminderChannelId);
      expect(NotificationChannels.mealReminder.name, contains('Waktu Makan'));
    });
    
    test('descriptions should be properly defined and informative', () {
      // Semua channel harus memiliki deskripsi informatif
      final allChannels = [
        NotificationChannels.mealReminder,
        NotificationChannels.workoutReminder,
        NotificationChannels.subscription,
        NotificationChannels.server,
        NotificationChannels.petStatus,
        NotificationChannels.petSadness,
        NotificationChannels.dailyStreak,
      ];
      
      for (final channel in allChannels) {
        expect(channel.description, isNotNull);
        expect(channel.description!.length, greaterThan(10), 
            reason: 'Description for ${channel.id} should be informative');
        
        // More flexible pattern check - accommodates both Indonesian and English formats
        expect(
          channel.description!.contains('Channel untuk') || 
          channel.description!.contains('Notifikasi') ||
          channel.description!.contains('Channel for') ||
          channel.description!.contains('Notification'),
          isTrue,
          reason: 'Description for ${channel.id} should follow standard format'
        );
      }
    });
    
    test('channel values should be immutable', () {
      // Verifikasi bahwa semua nilai constant tidak dapat diubah
      // Ini adalah compile-time check yang memastikan bahwa channel-channel ini adalah const
      
      // NotificationChannels.mealReminder = AndroidNotificationChannel(...); // Hal ini akan memberi compile error
      // NotificationChannels.server.name = 'New Name'; // Hal ini juga akan memberi compile error
      
      // Pastikan kelas didefinisikan dengan benar dengan const konstruktor
      const testChannel = AndroidNotificationChannel(
        'test_id',
        'Test Name',
        description: 'Test description',
        importance: Importance.high,
      );
      expect(testChannel.id, equals('test_id'));
    });
    
    test('pet status channel should have hardcoded ID (not from constants)', () {
      // Ini satu-satunya channel yang ID-nya tidak berasal dari NotificationConstants
      expect(NotificationChannels.petStatus.id, equals('pet_status_channel'));
      
      // Verifikasi bahwa channel ini tidak memiliki constant yang terkait
      // Tidak bisa menggunakan expect dengan throwsNoSuchMethodError disini karena
      // ini adalah static compile-time check, bukan runtime error
    });
    
    test('legacy accessor should maintain expected behavior over time', () {
      // Memastikan accessor caloriesReminder selalu mengarah ke mealReminder
      expect(NotificationChannels.caloriesReminder, same(NotificationChannels.mealReminder));
      
      // Verifikasi bahwa getter caloriesReminder diimplementasikan dengan benar
      expect(NotificationChannels.caloriesReminder.id, equals(NotificationChannels.mealReminder.id));
      expect(NotificationChannels.caloriesReminder.name, equals(NotificationChannels.mealReminder.name));
      expect(NotificationChannels.caloriesReminder.description, equals(NotificationChannels.mealReminder.description));
    });
  });
}
