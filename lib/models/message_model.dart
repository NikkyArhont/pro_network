import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final bool isRead;
  final String type; // 'text', 'image', 'file', 'story_reply'
  final String? mediaUrl;
  final String? fileName;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.isRead,
    this.type = 'text',
    this.mediaUrl,
    this.fileName,
    this.metadata,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> data) {
    return MessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'text',
      mediaUrl: data['mediaUrl'],
      fileName: data['fileName'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isRead': isRead,
      'type': type,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
