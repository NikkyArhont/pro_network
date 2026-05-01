import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_network/models/business_card_draft.dart';
import 'package:pro_network/services/tag_service.dart';
import 'package:pro_network/services/notification_service.dart';
import 'package:pro_network/models/notification_model.dart';

class BusinessCardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TagService _tagService = TagService();
  final NotificationService _notificationService = NotificationService();

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
  Future<String?> createBusinessCard(BusinessCardDraft draft) async {
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

      // 4. Save new tags to global collection
      if (draft.tags.isNotEmpty) {
        await _tagService.saveNewTags(draft.tags);
      }
      print('Business card saved successfully! ID: $cardId');
      return cardId;
    } catch (e) {
      print('CATASTROPHIC ERROR in createBusinessCard: $e');
      return null;
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
      
      // Save tags if they are part of the update
      if (data.containsKey('tags')) {
        final List<String> tags = List<String>.from(data['tags']);
        await _tagService.saveNewTags(tags);
      }
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

  /// Searches for active business cards, excluding the current user's cards.
  Future<List<Map<String, dynamic>>> searchCards({
    required String query,
    required String currentUserId,
    List<String>? tags,
    String? city,
  }) async {
    try {
      Query cardQuery = _firestore
          .collection('business_cards')
          .where('isActive', isEqualTo: true); // Only active cards in general search

      final querySnapshot = await cardQuery.get();
      
      print('DEBUG: [BusinessCardService] Found ${querySnapshot.docs.length} active cards in collection "business_cards"');
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('DEBUG: [BusinessCardService] Card ID: ${doc.id}, Owner ID: ${data['userId']}');
      }

      final results = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      return results.where((card) {
        // 1. Exclude my own cards
        if (card['userId'] == currentUserId) return false;

        // 2. Filter by tags if provided
        if (tags != null && tags.isNotEmpty) {
          final cardTags = List<String>.from(card['tags'] ?? []);
          if (!tags.any((t) => cardTags.contains(t))) return false;
        }

        // 3. Filter by city
        if (city != null && city.isNotEmpty) {
          final cardCity = (card['city'] ?? '').toString().toLowerCase();
          if (cardCity != city.toLowerCase()) return false;
        }

        // 4. Filter by search text
        if (query.isEmpty) return true;
        final lowercaseQuery = query.toLowerCase();
        final name = (card['name'] ?? '').toString().toLowerCase();
        final pos = (card['position'] ?? '').toString().toLowerCase();
        final comp = (card['company'] ?? '').toString().toLowerCase();
        final cardCityString = (card['city'] ?? '').toString().toLowerCase();

        return name.contains(lowercaseQuery) ||
               pos.contains(lowercaseQuery) ||
               comp.contains(lowercaseQuery) ||
               cardCityString.contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('Error searching business cards: $e');
      return [];
    }
  }

  /// Toggles recommendation status for a business card
  Future<void> toggleRecommendation(String currentUserId, String cardId) async {
    if (currentUserId.isEmpty || cardId.isEmpty) return;

    final cardRef = _firestore.collection('business_cards').doc(cardId);

    return _firestore.runTransaction((transaction) async {
      final cardSnapshot = await transaction.get(cardRef);
      if (!cardSnapshot.exists) return;

      final data = cardSnapshot.data() as Map<String, dynamic>;
      final ownerId = data['userId'] as String;
      final recommenders = List<String>.from(data['recommenders'] ?? []);
      final bool isCurrentlyRecommended = recommenders.contains(currentUserId);

      if (isCurrentlyRecommended) {
        transaction.update(cardRef, {
          'recommenders': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        transaction.update(cardRef, {
          'recommenders': FieldValue.arrayUnion([currentUserId])
        });

        // Send notification to the owner of the card
        if (ownerId != currentUserId) {
          _notificationService.sendNotification(
            toUserId: ownerId,
            fromUserId: currentUserId,
            type: NotificationType.recommendation,
            title: 'Рекомендация визитки',
            body: 'Вашу визитку рекомендуют!',
          );
        }
      }
    });
  }

  /// Returns a stream of a card's recommenders
  Stream<List<String>> getCardRecommendersStream(String cardId) {
    if (cardId.isEmpty) return Stream.value([]);
    return _firestore.collection('business_cards').doc(cardId).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      return List<String>.from(snapshot.data()?['recommenders'] ?? []);
    });
  }
}
