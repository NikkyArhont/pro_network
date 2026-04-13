import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String text;
  final String imageUrl;
  final DateTime createdAt;
  final List<String> likes;

  Post({
    required this.id,
    required this.userId,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    this.likes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
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
    );
  }
}
