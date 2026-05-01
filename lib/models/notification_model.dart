import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  birthday,
  request,
  connectionAdded,
  recommendation,
  system
}

class NotificationModel {
  final String id;
  final String toUserId;
  final String? fromUserId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? extraData;

  NotificationModel({
    required this.id,
    required this.toUserId,
    this.fromUserId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.extraData,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      toUserId: data['toUserId'] ?? '',
      fromUserId: data['fromUserId'],
      type: _typeFromString(data['type']),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      extraData: data['extraData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'extraData': extraData,
    };
  }

  static NotificationType _typeFromString(String? type) {
    switch (type) {
      case 'birthday': return NotificationType.birthday;
      case 'request': return NotificationType.request;
      case 'connectionAdded': return NotificationType.connectionAdded;
      case 'recommendation': return NotificationType.recommendation;
      case 'system': return NotificationType.system;
      default: return NotificationType.system;
    }
  }
}
