import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pro_network/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );

  /// Returns a stream of notifications for a specific user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('notifications')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList();
        });
  }

  /// Sends a notification to a user
  Future<void> sendNotification({
    required String toUserId,
    String? fromUserId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? extraData,
  }) async {
    await _firestore.collection('notifications').add({
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'extraData': extraData,
    });
  }

  /// Marks a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Deletes a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }
}
