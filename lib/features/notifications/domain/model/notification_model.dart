import 'package:uuid/uuid.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? payload;
  final DateTime scheduledTime;
  final bool isRead;

  NotificationModel({
    String? id,
    required this.title,
    required this.body,
    this.payload,
    required this.scheduledTime,
    this.isRead = false,
  }) : id = id ?? const Uuid().v4();

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? payload,
    DateTime? scheduledTime,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      payload: map['payload'],
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['scheduledTime']),
      isRead: map['isRead'] ?? false,
    );
  }
} 