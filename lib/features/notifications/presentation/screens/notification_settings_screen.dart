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

  // Pet status notification variables
  bool _isPetStatusEnabled = false;
  TimeOfDay _petStatusTime = const TimeOfDay(
      hour: NotificationConstants.defaultPetStatusNotificationHour,
      minute: NotificationConstants.defaultPetStatusNotificationMinute);

  // Meal reminder state variables
  bool _isMealReminderEnabled = false;
  bool _isBreakfastEnabled = false;
  bool _isLunchEnabled = false;
  bool _isDinnerEnabled = false;

  TimeOfDay _breakfastTime = const TimeOfDay(
      hour: NotificationConstants.defaultBreakfastHour,
      minute: NotificationConstants.defaultBreakfastMinute);
  TimeOfDay _lunchTime = const TimeOfDay(
      hour: NotificationConstants.defaultLunchHour,
      minute: NotificationConstants.defaultLunchMinute);
  TimeOfDay _dinnerTime = const TimeOfDay(
      hour: NotificationConstants.defaultDinnerHour,
      minute: NotificationConstants.defaultDinnerMinute);

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
    final bool isStreakEnabled = await _notificationService
        .isNotificationEnabled(NotificationConstants.dailyStreakChannelId);

    // Get saved time or use default from constants
    final int streakHour =
        _prefs.getInt(NotificationConstants.prefDailyStreakHour) ??
            NotificationConstants.defaultStreakNotificationHour;
    final int streakMinute =
        _prefs.getInt(NotificationConstants.prefDailyStreakMinute) ??
            NotificationConstants.defaultStreakNotificationMinute;

    // Check if pet status notification is enabled
    final bool isPetStatusEnabled = await _notificationService
        .isNotificationEnabled(NotificationConstants.petStatusChannelId);

    // Get saved pet status time or use default from constants
    final int petStatusHour =
        _prefs.getInt(NotificationConstants.prefPetStatusHour) ??
            NotificationConstants.defaultPetStatusNotificationHour;
    final int petStatusMinute =
        _prefs.getInt(NotificationConstants.prefPetStatusMinute) ??
            NotificationConstants.defaultPetStatusNotificationMinute;

    // Load meal reminder settings
    final bool isMealReminderEnabled = await _notificationService
        .isNotificationEnabled(NotificationConstants.mealReminderChannelId);

    final bool isBreakfastEnabled = await _notificationService
        .isNotificationEnabled(NotificationConstants.breakfast);

    final bool isLunchEnabled = await _notificationService
        .isNotificationEnabled(NotificationConstants.lunch);

    final bool isDinnerEnabled = await _notificationService
        .isNotificationEnabled(NotificationConstants.dinner);

    // Get saved meal reminder times
    final breakfastTime =
        await _getMealReminderTime(NotificationConstants.breakfast);
    final lunchTime = await _getMealReminderTime(NotificationConstants.lunch);
    final dinnerTime = await _getMealReminderTime(NotificationConstants.dinner);

    setState(() {
      _isDailyStreakEnabled = isStreakEnabled;
      _dailyStreakTime = TimeOfDay(hour: streakHour, minute: streakMinute);

      _isPetStatusEnabled = isPetStatusEnabled;
      _petStatusTime = TimeOfDay(hour: petStatusHour, minute: petStatusMinute);

      _isMealReminderEnabled = isMealReminderEnabled;
      _isBreakfastEnabled = isBreakfastEnabled;
      _isLunchEnabled = isLunchEnabled;
      _isDinnerEnabled = isDinnerEnabled;

      _breakfastTime = breakfastTime;
      _lunchTime = lunchTime;
      _dinnerTime = dinnerTime;
    });
  }

  /// Helper method to get meal reminder time
  Future<TimeOfDay> _getMealReminderTime(String mealType) async {
    final prefKey = NotificationConstants.getMealTypeKey(mealType);
    final hourKey = "${prefKey}_hour";
    final minuteKey = "${prefKey}_minute";

    int? hour = _prefs.getInt(hourKey);
    int? minute = _prefs.getInt(minuteKey);

    switch (mealType) {
      case NotificationConstants.breakfast:
        return TimeOfDay(
          hour: hour ?? NotificationConstants.defaultBreakfastHour,
          minute: minute ?? NotificationConstants.defaultBreakfastMinute,
        );
      case NotificationConstants.lunch:
        return TimeOfDay(
          hour: hour ?? NotificationConstants.defaultLunchHour,
          minute: minute ?? NotificationConstants.defaultLunchMinute,
        );
      case NotificationConstants.dinner:
        return TimeOfDay(
          hour: hour ?? NotificationConstants.defaultDinnerHour,
          minute: minute ?? NotificationConstants.defaultDinnerMinute,
        );
      default:
        return const TimeOfDay(hour: 12, minute: 0);
    }
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
                ? 'Daily streak notification has been enabled'
                : 'Daily streak notification has been disabled'),
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

  /// Toggle pet status notification
  Future<void> _togglePetStatusNotification(bool value) async {
    try {
      // Toggle notification in service - business logic handled in service
      await _notificationService.toggleNotification(
          NotificationConstants.petStatusChannelId, value);

      setState(() {
        _isPetStatusEnabled = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'Pet status notification has been enabled'
                : 'Pet status notification has been disabled'),
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

  /// Toggle master meal reminder notification
  Future<void> _toggleMealReminderNotification(bool value) async {
    try {
      // Toggle notification in service - business logic handled in service
      await _notificationService.toggleNotification(
          NotificationConstants.mealReminderChannelId, value);

      setState(() {
        _isMealReminderEnabled = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'Meal reminder notifications have been enabled'
                : 'Meal reminder notifications have been disabled'),
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

  /// Toggle individual meal type notification
  Future<void> _toggleMealTypeNotification(String mealType, bool value) async {
    try {
      // Toggle notification in service - business logic handled in service
      await _notificationService.toggleNotification(mealType, value);

      setState(() {
        switch (mealType) {
          case NotificationConstants.breakfast:
            _isBreakfastEnabled = value;
            break;
          case NotificationConstants.lunch:
            _isLunchEnabled = value;
            break;
          case NotificationConstants.dinner:
            _isDinnerEnabled = value;
            break;
        }
      });

      if (mounted) {
        String mealName;
        switch (mealType) {
          case NotificationConstants.breakfast:
            mealName = 'breakfast';
            break;
          case NotificationConstants.lunch:
            mealName = 'lunch';
            break;
          case NotificationConstants.dinner:
            mealName = 'dinner';
            break;
          default:
            mealName = 'meal';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? '$mealName reminder notification has been enabled'
                : '$mealName reminder notification has been disabled'),
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
            content: Text(
                'Notification time changed to ${_formatTimeOfDay(picked)}'),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Select time for pet status notification
  Future<void> _selectPetStatusTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _petStatusTime,
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

    if (picked != null && picked != _petStatusTime) {
      // Save new time to preferences
      await _prefs.setInt(
          NotificationConstants.prefPetStatusHour, picked.hour);
      await _prefs.setInt(
          NotificationConstants.prefPetStatusMinute, picked.minute);

      setState(() {
        _petStatusTime = picked;
      });

      // Re-schedule notification if enabled
      if (_isPetStatusEnabled) {
        // Toggle off and back on to trigger rescheduling
        await _notificationService.toggleNotification(
            NotificationConstants.petStatusChannelId, false);
        await _notificationService.toggleNotification(
            NotificationConstants.petStatusChannelId, true);
      }

      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Pet status notification time changed to ${_formatTimeOfDay(picked)}'),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Select time for meal reminder notification
  Future<void> _selectMealReminderTime(
      BuildContext context, String mealType) async {
    // Get current time based on meal type
    TimeOfDay initialTime;
    // Define time range constraints for each meal type
    int? minHour, maxHour;

    switch (mealType) {
      case NotificationConstants.breakfast:
        initialTime = _breakfastTime;
        minHour = 5; // 5:00 AM
        maxHour = 10; // 10:59 AM
        break;
      case NotificationConstants.lunch:
        initialTime = _lunchTime;
        minHour = 11; // 11:00 AM
        maxHour = 15; // 3:59 PM
        break;
      case NotificationConstants.dinner:
        initialTime = _dinnerTime;
        minHour = 16; // 4:00 PM
        maxHour = 23; // 11:59 PM
        break;
      default:
        initialTime = const TimeOfDay(hour: 12, minute: 0);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

    if (picked != null && picked != initialTime) {
      // Get the specific meal name for the message
      String mealName;
      switch (mealType) {
        case NotificationConstants.breakfast:
          mealName = 'breakfast';
          break;
        case NotificationConstants.lunch:
          mealName = 'lunch';
          break;
        case NotificationConstants.dinner:
          mealName = 'dinner';
          break;
        default:
          mealName = 'meal';
      }

      // Validate time range
      if (minHour != null && maxHour != null) {
        if (picked.hour < minHour || picked.hour > maxHour) {
          // Time is outside the valid range for this meal type
          if (mounted) {
            String timeRangeText;
            switch (mealType) {
              case NotificationConstants.breakfast:
                timeRangeText = '5:00 AM - 10:59 AM';
                break;
              case NotificationConstants.lunch:
                timeRangeText = '11:00 AM - 3:59 PM';
                break;
              case NotificationConstants.dinner:
                timeRangeText = '4:00 PM - 11:59 PM';
                break;
              default:
                timeRangeText = 'appropriate hours';
            }

            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '$mealName reminders should be set during $timeRangeText'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
            return;
          }
        }
      }

      // Get preference keys for the meal type
      final prefKey = NotificationConstants.getMealTypeKey(mealType);
      final hourKey = "${prefKey}_hour";
      final minuteKey = "${prefKey}_minute";

      // Save to SharedPreferences
      await _prefs.setInt(hourKey, picked.hour);
      await _prefs.setInt(minuteKey, picked.minute);

      // Update state
      setState(() {
        switch (mealType) {
          case NotificationConstants.breakfast:
            _breakfastTime = picked;
            break;
          case NotificationConstants.lunch:
            _lunchTime = picked;
            break;
          case NotificationConstants.dinner:
            _dinnerTime = picked;
            break;
        }
      });

      // Re-schedule notification if this meal type is enabled
      final mealEnabled =
          await _notificationService.isNotificationEnabled(mealType);
      if (mealEnabled) {
        // Toggle off and back on to trigger rescheduling
        await _notificationService.toggleNotification(mealType, false);
        await _notificationService.toggleNotification(mealType, true);
      }

      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$mealName reminder time changed to ${_formatTimeOfDay(picked)}'),
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
          'Notification Settings',
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
                  'Manage your notification settings for a better experience',
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
                        'Daily Streak Notification',
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
                        'Enable Streak Notification',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Get reminders to log your activities and maintain your streak',
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
                        'Notification Time',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Notification will be sent at ${_formatTimeOfDay(_dailyStreakTime)}',
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
              // Pet Status Notification Card
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
                        'Pet Status Notification',
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
                        'Enable Pet Status Notification',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Get updates about your pet mood',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      value: _isPetStatusEnabled,
                      onChanged: _togglePetStatusNotification,
                      activeColor: primaryPink,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                    ),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    ListTile(
                      enabled: _isPetStatusEnabled,
                      title: const Text(
                        'Notification Time',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Set at ${_formatTimeOfDay(_petStatusTime)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: _isPetStatusEnabled
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                      ),
                      trailing: Icon(
                        Icons.access_time,
                        color: _isPetStatusEnabled
                            ? primaryPink
                            : Colors.grey[400],
                      ),
                      onTap: _isPetStatusEnabled
                          ? () => _selectPetStatusTime(context)
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              // Meal Reminder Notification Card
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
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: primaryPink, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Meal Time Reminders',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey.withOpacity(0.2)),

                    // Master Toggle for Meal Reminders
                    SwitchListTile(
                      title: const Text(
                        'Enable Meal Reminders',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Set reminder schedules for breakfast, lunch, and dinner',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      value: _isMealReminderEnabled,
                      onChanged: _toggleMealReminderNotification,
                      activeColor: primaryPink,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                    ),

                    Divider(color: Colors.grey.withOpacity(0.2)),

                    // Breakfast settings
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 8, bottom: 4),
                      child: Text(
                        'Individual Settings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    // Breakfast Toggle and Time
                    SwitchListTile(
                      title: const Text(
                        'Breakfast',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Time: ${_formatTimeOfDay(_breakfastTime)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: _isMealReminderEnabled && _isBreakfastEnabled
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                      ),
                      value: _isBreakfastEnabled,
                      onChanged: _isMealReminderEnabled
                          ? (value) => _toggleMealTypeNotification(
                              NotificationConstants.breakfast, value)
                          : null,
                      activeColor: primaryPink,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                    ),

                    // Time setting button for breakfast
                    if (_isMealReminderEnabled && _isBreakfastEnabled)
                      ListTile(
                        title: const Text(
                          'Set Breakfast Time',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(Icons.access_time, color: primaryPink),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 0),
                        dense: true,
                        onTap: () => _selectMealReminderTime(
                            context, NotificationConstants.breakfast),
                      ),

                    Divider(color: Colors.grey.withOpacity(0.2)),

                    // Lunch Toggle and Time
                    SwitchListTile(
                      title: const Text(
                        'Lunch',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Time: ${_formatTimeOfDay(_lunchTime)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: _isMealReminderEnabled && _isLunchEnabled
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                      ),
                      value: _isLunchEnabled,
                      onChanged: _isMealReminderEnabled
                          ? (value) => _toggleMealTypeNotification(
                              NotificationConstants.lunch, value)
                          : null,
                      activeColor: primaryPink,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                    ),

                    // Time setting button for lunch
                    if (_isMealReminderEnabled && _isLunchEnabled)
                      ListTile(
                        title: const Text(
                          'Set Lunch Time',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(Icons.access_time, color: primaryPink),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 0),
                        dense: true,
                        onTap: () => _selectMealReminderTime(
                            context, NotificationConstants.lunch),
                      ),

                    Divider(color: Colors.grey.withOpacity(0.2)),

                    // Dinner Toggle and Time
                    SwitchListTile(
                      title: const Text(
                        'Dinner',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Time: ${_formatTimeOfDay(_dinnerTime)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: _isMealReminderEnabled && _isDinnerEnabled
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                      ),
                      value: _isDinnerEnabled,
                      onChanged: _isMealReminderEnabled
                          ? (value) => _toggleMealTypeNotification(
                              NotificationConstants.dinner, value)
                          : null,
                      activeColor: primaryPink,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                    ),

                    // Time setting button for dinner
                    if (_isMealReminderEnabled && _isDinnerEnabled)
                      ListTile(
                        title: const Text(
                          'Set Dinner Time',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(Icons.access_time, color: primaryPink),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 0),
                        dense: true,
                        onTap: () => _selectMealReminderTime(
                            context, NotificationConstants.dinner),
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
                        'Notifications help you stay consistent in logging activities and maintaining your daily streak',
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              // End of info card
            ],
          ),
        ),
      ),
    );
  }
}

// coverage-ignore:end
