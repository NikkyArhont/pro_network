import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;
  final String type; // 'personal', 'saved'
  final List<String> pinnedBy; // List of UIDs who pinned this chat
  final List<String> markedUnreadBy; // List of UIDs who manually marked this as unread
  
  // Dynamically populated useful data for UI
  Map<String, dynamic>? otherUserData;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.type,
    this.pinnedBy = const [],
    this.markedUnreadBy = const [],
    this.otherUserData,
  });

  bool isPinnedByUser(String userId) => pinnedBy.contains(userId);
  bool isMarkedUnreadByUser(String userId) => markedUnreadBy.contains(userId);

  factory ChatModel.fromMap(String id, Map<String, dynamic> data) {
    return ChatModel(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: (data['unreadCount'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, (value as num? ?? 0).toInt()),
      ),
      type: data['type'] ?? 'personal',
      pinnedBy: List<String>.from(data['pinnedBy'] ?? []),
      markedUnreadBy: List<String>.from(data['markedUnreadBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : FieldValue.serverTimestamp(),
      'unreadCount': unreadCount,
      'type': type,
      'pinnedBy': pinnedBy,
      'markedUnreadBy': markedUnreadBy,
    };
  }
}
