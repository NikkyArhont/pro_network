import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import '../models/story_model.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // Загрузка сторис
  Future<bool> uploadStory(XFile file) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final String storyId = _uuid.v4();
      final String fileName = 'stories/${user.uid}/$storyId.jpg';
      
      // 1. Загрузка в Firebase Storage
      final Reference ref = _storage.ref().child(fileName);
      
      final UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(
          bytes, 
          SettableMetadata(contentType: 'image/jpeg')
        );
      } else {
        uploadTask = ref.putFile(
          File(file.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      
      final TaskSnapshot snapshot = await uploadTask;
      final String imageUrl = await snapshot.ref.getDownloadURL();

      // 2. Создание записи в Firestore
      final DateTime now = DateTime.now();
      final story = Story(
        id: storyId,
        userId: user.uid,
        imageUrl: imageUrl,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
        viewers: [],
      );

      await _firestore.collection('stories').doc(storyId).set(story.toJson());
      return true;
    } catch (e) {
      print('Error uploading story: $e');
      return false;
    }
  }

  // Получение потока активных сторис
  Stream<List<Story>> getStoriesStream() {
    return _firestore
        .collection('stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Story.fromJson(doc.data())).toList();
    });
  }

  // Отметка о просмотре
  Future<void> markAsViewed(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('stories').doc(storyId).update({
      'viewers': FieldValue.arrayUnion([user.uid]),
    });
  }
}
