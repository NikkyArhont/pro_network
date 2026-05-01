import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:collection';

class EnvironmentCircleData {
  final int count;
  final Map<String, int> topCountries;
  final Map<String, int> topActivities;
  final Map<String, int> topStatuses;

  EnvironmentCircleData({
    required this.count,
    required this.topCountries,
    required this.topActivities,
    required this.topStatuses,
  });
}

class EnvironmentData {
  final int totalCount;
  final Map<int, EnvironmentCircleData> circles;

  EnvironmentData({
    required this.totalCount,
    required this.circles,
  });
}

class EnvironmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );

  /// Synchronizes a list of matched registered user UIDs to the current user's document
  Future<void> syncContacts(String userId, List<String> matchedUids) async {
    if (userId.isEmpty || matchedUids.isEmpty) return;

    try {
      final userRef = _firestore.collection('users').doc(userId);
      // Use set with merge to ensure the document exists and arrayUnion to avoid duplicates
      await userRef.set({
        'syncedContacts': FieldValue.arrayUnion(matchedUids),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing contacts: $e');
    }
  }

  /// Calculates the environment (1st, 2nd, 3rd circles) and aggregates statistics
  Future<EnvironmentData?> calculateEnvironment(String userId) async {
    if (userId.isEmpty) return null;

    try {
      // For MVP, we fetch all users. In production, this needs a Cloud Function
      // or a more optimized approach since fetching thousands of users is expensive.
      final querySnapshot = await _firestore.collection('users').get();
      
      final Map<String, Map<String, dynamic>> allUsers = {};
      final Map<String, List<String>> userConnections = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final uid = doc.id;
        allUsers[uid] = data;
        userConnections[uid] = List<String>.from(data['syncedContacts'] ?? []);
      }

      if (!allUsers.containsKey(userId)) return null;

      // Sets for circles
      final Set<String> circle1 = {};
      final Set<String> circle2 = {};
      final Set<String> circle3 = {};
      final Set<String> visited = {userId};

      // BFS Queue: stores pairs of (uid, depth)
      final Queue<MapEntry<String, int>> queue = Queue();
      queue.add(MapEntry(userId, 0));

      while (queue.isNotEmpty) {
        final current = queue.removeFirst();
        final currentUid = current.key;
        final currentDepth = current.value;

        if (currentDepth >= 3) continue;

        final contacts = userConnections[currentUid] ?? [];
        for (var contactUid in contacts) {
          if (!visited.contains(contactUid) && allUsers.containsKey(contactUid)) {
            visited.add(contactUid);
            final nextDepth = currentDepth + 1;
            
            if (nextDepth == 1) {
              circle1.add(contactUid);
            } else if (nextDepth == 2) {
              circle2.add(contactUid);
            } else if (nextDepth == 3) {
              circle3.add(contactUid);
            }
            
            queue.add(MapEntry(contactUid, nextDepth));
          }
        }
      }

      // Aggregate statistics per circle
      EnvironmentCircleData aggregateCircle(Set<String> circleUids) {
        final Map<String, int> countries = {};
        final Map<String, int> activities = {};
        final Map<String, int> statuses = {};

        for (var uid in circleUids) {
          final user = allUsers[uid]!;
          
          final String location = (user['country'] ?? user['city'] ?? 'Не указано').toString().trim();
          if (location.isNotEmpty) {
            countries[location] = (countries[location] ?? 0) + 1;
          }

          final String activity = (user['activity'] ?? user['category'] ?? 'Другое').toString().trim();
          if (activity.isNotEmpty) {
            activities[activity] = (activities[activity] ?? 0) + 1;
          }

          final String status = (user['employmentStatus'] ?? user['status'] ?? 'Не указан').toString().trim();
          if (status.isNotEmpty) {
            statuses[status] = (statuses[status] ?? 0) + 1;
          }
        }

        Map<String, int> getTop(Map<String, int> map) {
          final sortedKeys = map.keys.toList()..sort((a, b) => map[b]!.compareTo(map[a]!));
          return { for (var k in sortedKeys.take(5)) k : map[k]! };
        }

        return EnvironmentCircleData(
          count: circleUids.length,
          topCountries: getTop(countries),
          topActivities: getTop(activities),
          topStatuses: getTop(statuses),
        );
      }

      final allEnvironmentUids = [...circle1, ...circle2, ...circle3];

      return EnvironmentData(
        totalCount: allEnvironmentUids.length,
        circles: {
          1: aggregateCircle(circle1),
          2: aggregateCircle(circle2),
          3: aggregateCircle(circle3),
        },
      );

    } catch (e) {
      print('Error calculating environment: $e');
      return null;
    }
  }
}
