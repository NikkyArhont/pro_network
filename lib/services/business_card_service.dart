import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_network/models/business_card_draft.dart';

class BusinessCardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads an image to Firebase Storage and returns the download URL.
  Future<String?> _uploadImage(XFile? xFile, String storagePath) async {
    try {
      if (xFile == null) return null;

      final bytes = await xFile.readAsBytes();
      final ref = _storage.ref().child(storagePath);
      
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Creates a new business card in Firestore.
  /// First uploads images, then saves metadata.
  Future<bool> createBusinessCard(BusinessCardDraft draft) async {
    try {
      print('Starting business card creation process...');
      final User? user = _auth.currentUser;
      if (user == null) {
        print('Error: User not authorized');
        throw Exception('Пользователь не авторизован');
      }

      final String userId = user.uid;
      final CollectionReference cardsRef = _firestore.collection('business_cards');
      final DocumentReference cardDoc = cardsRef.doc(); // Auto-generate ID
      final String cardId = cardDoc.id;
      print('Generated cardId: $cardId for userId: $userId');

      String? photoUrl;
      String? postPhotoUrl;

      // 1. Upload main photo
      if (draft.photoFile != null) {
        print('Uploading main photo...');
        photoUrl = await _uploadImage(
          draft.photoFile,
          'business_cards/$userId/$cardId/photo.jpg',
        );
        print('Main photo uploaded: $photoUrl');
      }

      // 2. Upload post photo
      if (draft.postPhotoFile != null) {
        print('Uploading post photo...');
        postPhotoUrl = await _uploadImage(
          draft.postPhotoFile,
          'business_cards/$userId/$cardId/post_photo.jpg',
        );
        print('Post photo uploaded: $postPhotoUrl');
      }

      // 3. Save to Firestore
      print('Saving metadata to Firestore...');
      final Map<String, dynamic> data = draft.toMap(
        userId: userId,
        photoUrl: photoUrl,
        postPhotoUrl: postPhotoUrl,
      );

      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['id'] = cardId;
      data['isActive'] = false; // New cards are inactive by default
      data['activeUntil'] = null;

      await cardDoc.set(data).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Firestore request timed out');
      });
      print('Business card saved successfully!');
      return true;
    } catch (e) {
      print('CATASTROPHIC ERROR in createBusinessCard: $e');
      return false;
    }
  }

  /// Gets all business cards for the current user.
  Future<List<Map<String, dynamic>>> getMyCards() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('business_cards')
          .where('userId', isEqualTo: user.uid)
          // .orderBy('createdAt', descending: true) // Temporarily disabled while index is building
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Force ID to be the document ID for reliability
        print('DEBUG: Card found in Firestore with ID: ${doc.id}');
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching cards: $e');
      return [];
    }
  }

  /// Activates a card for 30 days.
  Future<bool> activateCard(String cardId) async {
    try {
      final activeUntil = DateTime.now().add(const Duration(days: 30));
      await _firestore.collection('business_cards').doc(cardId).update({
        'isActive': true,
        'activeUntil': Timestamp.fromDate(activeUntil),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error activating card: $e');
      return false;
    }
  }

  /// Updates an existing business card.
  Future<bool> updateCard(String cardId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('business_cards').doc(cardId).update(data);
      return true;
    } catch (e) {
      print('Error updating card: $e');
      return false;
    }
  }

  /// Deletes a business card from Firestore.
  Future<bool> deleteCard(String cardId) async {
    try {
      await _firestore.collection('business_cards').doc(cardId).delete();
      return true;
    } catch (e) {
      print('Error deleting card: $e');
      return false;
    }
  }
}
