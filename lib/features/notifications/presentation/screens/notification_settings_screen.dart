// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/notifications/domain/constants/notification_constants.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';

// coverage-ignore:start

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = getIt<NotificationService>();
  final SharedPreferences _prefs = getIt<SharedPreferences>();

  // State variables
  bool _isDailyStreakEnabled = false;
  TimeOfDay _dailyStreakTime = const TimeOfDay(
      hour: NotificationConstants.defaultStreakNotificationHour,
      minute: NotificationConstants.defaultStreakNotificationMinute);

  // Colors - match with profile page for consistency
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  // Using preference keys from NotificationConstants

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  /// Load saved notification settings
  Future<void> _loadNotificationSettings() async {
    // Check if daily streak notification is enabled in SharedPreferences
    final bool isEnabled = await _notificationService
        .isNotificationEnabled(NotificationConstants.dailyStreakChannelId);

    // Get saved time or use default from constants
    final int hour = _prefs.getInt(NotificationConstants.prefDailyStreakHour) ??
        NotificationConstants.defaultStreakNotificationHour;
    final int minute =
        _prefs.getInt(NotificationConstants.prefDailyStreakMinute) ??
            NotificationConstants.defaultStreakNotificationMinute;

    setState(() {
      _isDailyStreakEnabled = isEnabled;
      _dailyStreakTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  /// Toggle daily streak notification
  Future<void> _toggleDailyStreakNotification(bool value) async {
    try {
      // Toggle notification in service - business logic handled in service
      await _notificationService.toggleNotification(
          NotificationConstants.dailyStreakChannelId, value);

      setState(() {
        _isDailyStreakEnabled = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'Notifikasi streak harian telah diaktifkan'
                : 'Notifikasi streak harian telah dinonaktifkan'),
            backgroundColor: value ? primaryGreen : Colors.grey,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal ${value ? 'mengaktifkan' : 'menonaktifkan'} notifikasi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Select time for daily streak notification
  Future<void> _selectDailyStreakTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyStreakTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryPink,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryPink,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dailyStreakTime) {
      // Save new time to preferences
      await _prefs.setInt(
          NotificationConstants.prefDailyStreakHour, picked.hour);
      await _prefs.setInt(
          NotificationConstants.prefDailyStreakMinute, picked.minute);

      setState(() {
        _dailyStreakTime = picked;
      });

      // Re-schedule notification if enabled
      if (_isDailyStreakEnabled) {
        // Toggle off and back on to trigger rescheduling
        await _notificationService.toggleNotification(
            NotificationConstants.dailyStreakChannelId, false);
        await _notificationService.toggleNotification(
            NotificationConstants.dailyStreakChannelId, true);
      }

      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Waktu notifikasi diubah ke ${_formatTimeOfDay(picked)}'),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Schedule notification is handled by the service

  /// Format TimeOfDay to readable string
  String _formatTimeOfDay(TimeOfDay tod) {
    final hours = tod.hour.toString().padLeft(2, '0');
    final minutes = tod.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Explanation text
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 16),
                child: Text(
                  'Kelola pengaturan notifikasi Anda untuk pengalaman lebih baik',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              // Daily Streak Notification Card
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                      child: Text(
                        'Notifikasi Streak Harian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    SwitchListTile(
                      title: const Text(
                        'Aktifkan Notifikasi Streak',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Dapatkan pengingat untuk mencatat aktivitas Anda dan menjaga streak',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      value: _isDailyStreakEnabled,
                      onChanged: _toggleDailyStreakNotification,
                      activeColor: primaryPink,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                    ),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    ListTile(
                      enabled: _isDailyStreakEnabled,
                      title: const Text(
                        'Waktu Notifikasi',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Notifikasi akan dikirim pukul ${_formatTimeOfDay(_dailyStreakTime)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: _isDailyStreakEnabled
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                      ),
                      trailing: Icon(
                        Icons.access_time,
                        color: _isDailyStreakEnabled
                            ? primaryPink
                            : Colors.grey[400],
                      ),
                      onTap: _isDailyStreakEnabled
                          ? () => _selectDailyStreakTime(context)
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              // Info Card
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: primaryGreen.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryGreen, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notifikasi membantu Anda konsisten dalam mencatat aktivitas dan menjaga streak harian',
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// coverage-ignore:end
