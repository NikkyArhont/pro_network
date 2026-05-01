import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String text;
  final String imageUrl;
  final DateTime createdAt;
  final List<String> likes;
  final String postType;
  final DateTime? expiresAt;
  final String? cardId;

  Post({
    required this.id,
    required this.userId,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    this.likes = const [],
    this.postType = 'standard',
    this.expiresAt,
    this.cardId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'postType': postType,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'cardId': cardId,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map, String docId) {
    return Post(
      id: docId,
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
      postType: map['postType'] ?? 'standard',
      expiresAt: map['expiresAt'] != null ? (map['expiresAt'] as Timestamp).toDate() : null,
      cardId: map['cardId'],
    );
  }
}
