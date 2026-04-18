import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );

  /// Get a stream of all chats for a specific user, ordered by lastMessageTime
  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => ChatModel.fromMap(doc.id, doc.data())).toList();

      // Client-side sort to avoid requiring composite index in Firebase
      chats.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      // We will ensure "saved" chat and sorting happens.
      // We look for the saved messages chat.
      final savedChatIndex = chats.indexWhere((c) => c.type == 'saved');
      
      ChatModel savedChat;
      if (savedChatIndex != -1) {
        savedChat = chats.removeAt(savedChatIndex);
      } else {
        // Create an empty, virtual "saved" chat for display purposes until one is actually created in DB
        savedChat = ChatModel(
          id: 'saved_$userId',
          participants: [userId],
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          unreadCount: {userId: 0},
          type: 'saved',
        );
      }
      
      // Inject savedChat at the very top (index 0)
      chats.insert(0, savedChat);
      
      return chats;
    });
  }

  /// Get messages for a specific chat
  Stream<List<MessageModel>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true) // usually descending for chat UIs
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Ensure a saved/favorites chat exists in the database
  Future<String> ensureSavedChatExists(String userId) async {
    final query = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .where('type', isEqualTo: 'saved')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }

    final newChatRef = _firestore.collection('chats').doc();
    await newChatRef.set({
      'participants': [userId],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': {userId: 0},
      'type': 'saved',
    });

    return newChatRef.id;
  }

  // Create a personal chat or get existing one
  Future<String> getOrCreatePersonalChat(String currentUserId, String otherUserId) async {
    // Note: this query only checks if an array has exactly these participants, 
    // arrayContains handles one. For dual we need to fetch and filter or use arrayContainsAny if limits apply.
    // In NoSQL it's often easier to generate a predictable ID like 'personal_uid1_uid2' 
    // but doing it carefully (sorting UIDs to always be identical regardless of who creates it).
    
    final sortedUids = [currentUserId, otherUserId]..sort();
    final expectedChatId = 'personal_${sortedUids[0]}_${sortedUids[1]}';

    final chatDoc = await _firestore.collection('chats').doc(expectedChatId).get();
    
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(expectedChatId).set({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {currentUserId: 0, otherUserId: 0},
        'type': 'personal',
      });
    }

    return expectedChatId;
  }

  /// Send a message to a chat
  Future<void> sendMessage(String chatId, String senderId, String text, List<String> participants) async {
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    final batch = _firestore.batch();

    final messageData = {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    };
    
    batch.set(messageRef, messageData);

    // Prepare update data for the chat document
    final uniqueParticipants = participants.toSet().toList();
    final isSaved = uniqueParticipants.length == 1 && uniqueParticipants.first == senderId;

    Map<String, dynamic> chatUpdate = {
      'participants': uniqueParticipants,
      'type': isSaved ? 'saved' : 'personal',
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    };

    // Increment unread count for other participants
    for (var participant in uniqueParticipants) {
      if (participant != senderId) {
        chatUpdate['unreadCount.$participant'] = FieldValue.increment(1);
      }
    }

    final chatRef = _firestore.collection('chats').doc(chatId);
    // Use set with merge: true to handle cases where the chat document doesn't exist yet
    batch.set(chatRef, chatUpdate, SetOptions(merge: true));

    await batch.commit();
  }

  /// Mark chat as read for a specific user
  Future<void> markAsRead(String chatId, String userId) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final doc = await chatRef.get();
    if (doc.exists) {
      await chatRef.update({
        'unreadCount.$userId': 0,
      });
    }
  }

  /// Delete all messages in a chat and reset its metadata
  Future<void> clearChatMessages(String chatId) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');
    
    // Get all messages (limited to 500 for safety in a single batch)
    final snapshot = await messagesRef.get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // Reset chat metadata
    batch.update(chatRef, {
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
