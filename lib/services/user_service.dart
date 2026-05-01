import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:pro_network/services/notification_service.dart';
import 'package:pro_network/models/notification_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NotificationService _notificationService = NotificationService();

  /// Ensures that a user document exists in Firestore.
  /// If it doesn't exist, it creates one with basic information.
  Future<void> ensureUserExists(User user) async {
    try {
      final DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        print('Creating new user document for UID: ${user.uid}');
        await userDoc.set({
          'uid': user.uid,
          'phoneNumber': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'displayName': '',
          'photoUrl': '',
          'status': 'new',
        });
      } else {
        print('User document already exists for UID: ${user.uid}');
        await userDoc.update({
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error in ensureUserExists: $e');
    }
  }

  /// Original registration method to save user profile.
  Future<void> createUserProfile({
    required String name,
    required String city,
    required String photoUrl, // This is local path at this point
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('UserService: No user to create profile for');
      return;
    }

    print('UserService: Starting profile creation for ${user.uid}...');
    String finalPhotoUrl = '';

    // 1. Upload photo if exists
    if (photoUrl.isNotEmpty) {
      try {
        print('UserService: Attempting photo upload...');
        final ref = _storage.ref().child('avatars').child('${user.uid}.jpg');
        
        if (kIsWeb) {
          final XFile file = XFile(photoUrl);
          final bytes = await file.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg')).timeout(const Duration(seconds: 15));
        } else {
          await ref.putFile(File(photoUrl)).timeout(const Duration(seconds: 15));
        }
        
        finalPhotoUrl = await ref.getDownloadURL().timeout(const Duration(seconds: 10));
        print('UserService: Photo uploaded successfully: $finalPhotoUrl');
      } catch (e) {
        print('UserService: Photo upload failed (continuing without photo): $e');
      }
    }

    // 2. Save document to Firestore
    print('UserService: Saving Firestore document...');
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber,
      'displayName': name,
      'city': city,
      'photoUrl': finalPhotoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    }).timeout(const Duration(seconds: 15), onTimeout: () {
      print('UserService: Firestore operation timed out!');
      throw Exception('Время ожидания сохранения профиля истекло. Проверьте соединение или настройки Firebase.');
    });
    
    print('UserService: Profile created successfully in Firestore.');
  }

  /// Uploads user avatar to Firebase Storage.
  Future<String?> uploadAvatar(String uid, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('avatars').child('$uid.jpg');
      
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(imageFile.path));
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  /// Updates user data in Firestore.
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Gets user data from Firestore.
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && !data.containsKey('uid')) {
        data['uid'] = doc.id;
      }
      return data;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Searches for users matching the query, excluding the current user.
  Future<List<Map<String, dynamic>>> searchUsers(String query, String currentUserId, {List<String>? tags, String? city}) async {
    try {
      // For a real app with many users, we'd use Algolia. 
      // For MVP, we'll search by displayName or city.
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .get();

      print('DEBUG: [UserService] Found ${querySnapshot.docs.length} users in collection "users"');

      final results = querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('uid')) data['uid'] = doc.id;
        return data;
      }).toList();

      return results.where((user) {
        // 1. Tag filtering (OR logic)
        if (tags != null && tags.isNotEmpty) {
          final category = (user['category'] ?? '').toString().toLowerCase();
          final activity = (user['activity'] ?? '').toString().toLowerCase();
          final position = (user['position'] ?? '').toString().toLowerCase();
          
          final hasMatch = tags.any((tag) {
            final t = tag.toLowerCase();
            return category.contains(t) || activity.contains(t) || position.contains(t);
          });
          
          if (!hasMatch) return false;
        }

        // 2. City filtering
        if (city != null && city.isNotEmpty) {
          final userCity = (user['city'] ?? '').toString().toLowerCase();
          if (userCity != city.toLowerCase()) return false;
        }

        // 3. Query filtering
        if (query.isEmpty) return true;

        final lowercaseQuery = query.toLowerCase();
        final name = (user['displayName'] ?? '').toString().toLowerCase();
        final userCityString = (user['city'] ?? '').toString().toLowerCase();

        return name.contains(lowercaseQuery) || userCityString.contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Toggles subscription status (subscribe/unsubscribe)
  Future<void> toggleSubscription(String currentUserId, String targetUserId) async {
    if (currentUserId.isEmpty || targetUserId.isEmpty || currentUserId == targetUserId) return;

    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    return _firestore.runTransaction((transaction) async {
      final currentUserSnapshot = await transaction.get(currentUserRef);
      if (!currentUserSnapshot.exists) return;

      final following = List<String>.from(currentUserSnapshot.data()?['following'] ?? []);
      final bool isCurrentlySubscribed = following.contains(targetUserId);

      if (isCurrentlySubscribed) {
        // Unsubscribe
        transaction.update(currentUserRef, {
          'following': FieldValue.arrayRemove([targetUserId])
        });
        transaction.update(targetUserRef, {
          'followers': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        // Subscribe
        transaction.update(currentUserRef, {
          'following': FieldValue.arrayUnion([targetUserId])
        });
        transaction.update(targetUserRef, {
          'followers': FieldValue.arrayUnion([currentUserId])
        });

        // Send notification
        _notificationService.sendNotification(
          toUserId: targetUserId,
          fromUserId: currentUserId,
          type: NotificationType.connectionAdded,
          title: 'Новая подписка',
          body: 'Вас добавили в СВЯЗИ!',
        );
      }
    }).catchError((error) {
      print('Error toggling subscription: $error');
      throw error;
    });
  }

  /// Returns a stream of current user's following list
  Stream<List<String>> getUserFollowingStream(String currentUserId) {
    if (currentUserId.isEmpty) return Stream.value([]);
    return _firestore.collection('users').doc(currentUserId).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      return List<String>.from(snapshot.data()?['following'] ?? []);
    });
  }

  /// Toggles recommendation status (recommend/un-recommend)
  Future<void> toggleRecommendation(String currentUserId, String targetUserId) async {
    if (currentUserId.isEmpty || targetUserId.isEmpty || currentUserId == targetUserId) return;

    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    return _firestore.runTransaction((transaction) async {
      final targetSnapshot = await transaction.get(targetUserRef);
      if (!targetSnapshot.exists) return;

      final recommenders = List<String>.from(targetSnapshot.data()?['recommenders'] ?? []);
      final bool isCurrentlyRecommended = recommenders.contains(currentUserId);

      if (isCurrentlyRecommended) {
        transaction.update(targetUserRef, {
          'recommenders': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        transaction.update(targetUserRef, {
          'recommenders': FieldValue.arrayUnion([currentUserId])
        });

        // Send notification
        _notificationService.sendNotification(
          toUserId: targetUserId,
          fromUserId: currentUserId,
          type: NotificationType.recommendation,
          title: 'Новая рекомендация',
          body: 'Вас рекомендуют!',
        );
      }
    });
  }

  /// Returns a stream of a user's recommenders
  Stream<List<String>> getUserRecommendersStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      return List<String>.from(snapshot.data()?['recommenders'] ?? []);
    });
  }
}
