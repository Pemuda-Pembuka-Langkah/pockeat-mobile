import 'package:pockeat/features/notifications/domain/services/notification_service.dart';

class NotificationInitializer {
  final NotificationService _notificationService = NotificationService();
  
  NotificationInitializer();
  
  Future<void> initialize() async {
    await _notificationService.initialize();
  }
} 