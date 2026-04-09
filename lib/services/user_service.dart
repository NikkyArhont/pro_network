import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    if (user == null) return;

    String finalPhotoUrl = '';

    // 1. Upload photo if exists
    if (photoUrl.isNotEmpty) {
      try {
        final ref = _storage.ref().child('avatars').child('${user.uid}.jpg');
        
        if (kIsWeb) {
          // Web upload using XFile to read bytes
          final XFile file = XFile(photoUrl);
          final bytes = await file.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          // Mobile upload
          await ref.putFile(File(photoUrl));
        }
        
        finalPhotoUrl = await ref.getDownloadURL();
      } catch (e) {
        print('Error uploading avatar: $e');
        // Fallback to empty if upload fails
      }
    }

    // 2. Save document to Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber,
      'displayName': name,
      'city': city,
      'photoUrl': finalPhotoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });
  }

  /// Gets user data from Firestore.
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
