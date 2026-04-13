import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewers;

  Story({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
    this.viewers = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewers': viewers,
    };
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      expiresAt: (json['expiresAt'] as Timestamp).toDate(),
      viewers: List<String>.from(json['viewers'] ?? []),
    );
  }
}
