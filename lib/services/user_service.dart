import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    required String photoUrl,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber,
      'displayName': name,
      'city': city,
      'photoUrl': photoUrl,
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
