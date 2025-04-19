import 'package:flutter/material.dart';
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'package:pockeat/features/notifications/domain/model/notification_model.dart';
import 'package:pockeat/features/notifications/domain/model/notification_channel.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = getIt<NotificationService>();
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime =
      const TimeOfDay(hour: 19, minute: 0); // Default: 19:00

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      if (_isReminderEnabled) {
        await _scheduleReminder();
      }
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      _isReminderEnabled = value;
    });

    if (value) {
      await _scheduleReminder();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _scheduleReminder() async {
    await _notificationService.scheduleLocalNotification(
      NotificationModel(
        title: 'Pengingat Kalori Harian',
        body: 'Mengingatkan Anda untuk melacak kalori harian',
        payload: 'daily_calorie_tracking',
        scheduledTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _reminderTime.hour,
          _reminderTime.minute,
        ),
      ),
      NotificationChannels.caloriesReminder,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat kalori harian telah diatur'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _scheduleOneMinuteNotification() async {
    await _notificationService.scheduleLocalNotification(
      NotificationModel(
        title: 'Notifikasi Test',
        body: 'Ini adalah notifikasi yang dijadwalkan 1 menit dari sekarang',
        payload: 'test_notification',
        scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
      ),
      NotificationChannels.caloriesReminder,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi akan muncul dalam 1 menit'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hours = tod.hour.toString().padLeft(2, '0');
    final minutes = tod.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Notifikasi',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Kirim notifikasi test dalam 1 menit',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _scheduleOneMinuteNotification,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Kirim Notifikasi 1 menit'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Pengingat Kalori Harian',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Aktifkan pengingat harian untuk melacak kalori Anda tepat waktu',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24.0),
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Pengingat Kalori Harian'),
                        subtitle: const Text(
                          'Dapatkan notifikasi untuk mengingatkan pelacakan kalori harian',
                        ),
                        value: _isReminderEnabled,
                        onChanged: _toggleReminder,
                        secondary: const Icon(Icons.notifications_active),
                      ),
                      const Divider(),
                      ListTile(
                        enabled: _isReminderEnabled,
                        title: const Text('Waktu Pengingat'),
                        subtitle: Text(
                          'Diatur untuk ${_formatTimeOfDay(_reminderTime)} setiap hari',
                        ),
                        trailing: TextButton(
                          onPressed: _isReminderEnabled
                              ? () => _selectTime(context)
                              : null,
                          child: Text(
                            _formatTimeOfDay(_reminderTime),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: _isReminderEnabled
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        leading: const Icon(Icons.access_time),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Pengingat akan muncul pada waktu yang ditentukan setiap hari untuk mengingatkan Anda melacak kalori harian.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
