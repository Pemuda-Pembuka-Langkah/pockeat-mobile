// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';

void main() {
  group('NotificationChannels', () {
    test('should define all required channels for application features', () {
      // Pastikan semua channel yang diperlukan untuk fitur-fitur aplikasi didefinisikan
      expect(NotificationChannels.mealReminder, isNotNull);
      expect(NotificationChannels.workoutReminder, isNotNull);
      expect(NotificationChannels.subscription, isNotNull);
      expect(NotificationChannels.server, isNotNull);
      expect(NotificationChannels.petStatus, isNotNull);
      expect(NotificationChannels.dailyStreak, isNotNull);
    });
    
    test('channels should be properly configured with correct importance levels', () {
      // Pastikan semua channel penting memiliki tingkat importance yang benar
      final criticalChannels = [
        NotificationChannels.mealReminder,
        NotificationChannels.petStatus,
        NotificationChannels.dailyStreak,
      ];
      
      for (final channel in criticalChannels) {
        expect(channel.importance, Importance.high, reason: '${channel.id} should have high importance');
      }
    });
    
    test('mealReminder channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.mealReminder.id, 'meal_reminder_channel');
      expect(NotificationChannels.mealReminder.name, 'Pengingat Waktu Makan');
      expect(
        NotificationChannels.mealReminder.description,
        'Channel untuk mengirim pengingat tentang waktu makan (sarapan, makan siang, makan malam)',
      );
      expect(NotificationChannels.mealReminder.importance, Importance.high);
    });

    test('legacy caloriesReminder should reference mealReminder', () {
      // Ensure backward compatibility
      expect(NotificationChannels.caloriesReminder, NotificationChannels.mealReminder);
      expect(NotificationChannels.caloriesReminder.id, NotificationChannels.mealReminder.id);
      expect(NotificationChannels.caloriesReminder.name, NotificationChannels.mealReminder.name);
    });

    test('workoutReminder channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.workoutReminder.id, 'workout_reminder_channel');
      expect(NotificationChannels.workoutReminder.name, 'Pengingat Workout');
      expect(
        NotificationChannels.workoutReminder.description,
        'Channel untuk mengirim pengingat tentang workout',
      );
      expect(NotificationChannels.workoutReminder.importance, Importance.high);
    });

    test('subscription channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.subscription.id, 'subscription_channel');
      expect(NotificationChannels.subscription.name, 'Subscription Channel');
      expect(
        NotificationChannels.subscription.description,
        'Channel untuk mengirim notifikasi tentang subscription',
      );
      expect(NotificationChannels.subscription.importance, Importance.high);
    });

    test('server channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.server.id, 'server_channel');
      expect(NotificationChannels.server.name, 'Server Channel');
      expect(
        NotificationChannels.server.description,
        'Channel untuk mengirim notifikasi dari server',
      );
      expect(NotificationChannels.server.importance, Importance.high);
    });

    test('petStatus channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.petStatus.id, 'pet_status_channel');
      expect(NotificationChannels.petStatus.name, 'Status Hewan Peliharaan');
      expect(
        NotificationChannels.petStatus.description,
        'Channel untuk mengirim notifikasi tentang status hewan peliharaan',
      );
      expect(NotificationChannels.petStatus.importance, Importance.high);
    });

    test('dailyStreak channel should have correct properties', () {
      // Assert
      expect(NotificationChannels.dailyStreak.id, 'daily_streak_channel');
      expect(NotificationChannels.dailyStreak.name, 'Pencapaian Streak Harian');
      expect(
        NotificationChannels.dailyStreak.description,
        'Channel untuk mengirim notifikasi tentang pencapaian streak dan milestone',
      );
      expect(NotificationChannels.dailyStreak.importance, Importance.high);
    });

    test('all channels should have unique IDs', () {
      // Collect all channel IDs
      final channelIds = [
        NotificationChannels.mealReminder.id,
        NotificationChannels.workoutReminder.id,
        NotificationChannels.subscription.id,
        NotificationChannels.server.id,
        NotificationChannels.petStatus.id,
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
    });
    
    test('channels for POC features should be properly defined', () {
      // POC-152: Pet sadness indicator
      expect(NotificationChannels.petStatus.id, 'pet_status_channel');
      expect(NotificationChannels.petStatus.name, contains('Hewan Peliharaan'));
      
      // POC-150: Daily streak celebration
      expect(NotificationChannels.dailyStreak.id, 'daily_streak_channel');
      expect(NotificationChannels.dailyStreak.name, contains('Streak'));
      
      // POC-149: Meal reminders
      expect(NotificationChannels.mealReminder.id, 'meal_reminder_channel');
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
        NotificationChannels.dailyStreak,
      ];
      
      for (final channel in allChannels) {
        expect(channel.description, isNotNull);
        expect(channel.description!.length, greaterThan(10), 
            reason: 'Description for ${channel.id} should be informative');
        expect(channel.description, contains('Channel untuk'));
      }
    });
  });
}
