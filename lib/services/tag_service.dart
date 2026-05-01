import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pro_network/utils/constants.dart';

class TagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );

  /// Fetches all tags from Firestore.
  /// If Firestore is empty, returns the default tags from AppConstants.
  Future<List<String>> getAllTags() async {
    try {
      final querySnapshot = await _firestore
          .collection('tags')
          .orderBy('name')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return AppConstants.allTags;
      }

      return querySnapshot.docs.map((doc) => doc.get('name') as String).toList();
    } catch (e) {
      print('Error fetching tags: $e');
      return AppConstants.allTags;
    }
  }

  /// Saves new tags to Firestore if they don't already exist.
  Future<void> saveNewTags(List<String> tags) async {
    if (tags.isEmpty) return;

    try {
      final batch = _firestore.batch();
      final tagsRef = _firestore.collection('tags');

      for (var tag in tags) {
        // Use normalized name as document ID to avoid duplicates
        final normalized = tag.trim();
        if (normalized.isEmpty) continue;
        
        // We can't easily check existence in a batch without reading first,
        // but we can just use doc(normalized).set() with SetOptions(merge: true)
        final docRef = tagsRef.doc(normalized);
        batch.set(docRef, {
          'name': normalized,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Error saving new tags: $e');
    }
  }
}
