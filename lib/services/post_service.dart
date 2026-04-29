import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:camera/camera.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // Создание нового поста
  Future<bool> createPost(XFile file, String text) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final String postId = _uuid.v4();
      final String fileName = 'posts/${user.uid}/$postId.jpg';
      
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

      // 2. Создание метаданных в Firestore
      final post = Post(
        id: postId,
        userId: user.uid,
        text: text,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('posts').doc(postId).set(post.toMap());
      return true;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  // Получение ленты постов (всех в системе)
  Stream<List<Post>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Механика лайка
  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _firestore.collection('posts').doc(postId);
    final doc = await docRef.get();
    
    if (doc.exists) {
      final List<dynamic> likes = doc.data()?['likes'] ?? [];
      if (likes.contains(userId)) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    }
  }

  // --- Комментарии ---

  Future<bool> addComment(String postId, String text, {String? replyToCommentId}) async {
    final user = _auth.currentUser;
    if (user == null || text.trim().isEmpty) return false;

    try {
      final String commentId = _uuid.v4();
      final comment = Comment(
        id: commentId,
        postId: postId,
        userId: user.uid,
        text: text.trim(),
        createdAt: DateTime.now(),
        replyToCommentId: replyToCommentId,
      );

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toMap());
      return true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false) // старые сверху
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Comment.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    final docRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
        
    final doc = await docRef.get();
    
    if (doc.exists) {
      final List<dynamic> likes = doc.data()?['likes'] ?? [];
      if (likes.contains(userId)) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }
}
