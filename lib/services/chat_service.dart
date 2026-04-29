import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;


  /// Get a stream of all chats for a specific user, ordered by lastMessageTime
  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => ChatModel.fromMap(doc.id, doc.data())).toList();

      // 1. Ensure "saved" chat exists in the list (or create a virtual one)
      final savedChatIndex = chats.indexWhere((c) => c.type == 'saved');
      ChatModel savedChat;
      if (savedChatIndex != -1) {
        savedChat = chats.removeAt(savedChatIndex);
      } else {
        savedChat = ChatModel(
          id: 'saved_$userId',
          participants: [userId],
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          unreadCount: {userId: 0},
          type: 'saved',
        );
      }

      // 2. Sort the remaining chats
      chats.sort((a, b) {
        // Priority 1: Pinned status
        final aPinned = a.isPinnedByUser(userId);
        final bPinned = b.isPinnedByUser(userId);
        if (aPinned && !bPinned) return -1;
        if (!aPinned && bPinned) return 1;

        // Priority 2: Time
        final aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      // 3. Put Saved chat at index 0
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
  Future<void> sendMessage(String chatId, String senderId, String text, List<String> participants, {String type = 'text', String? mediaUrl, String? fileName, Map<String, dynamic>? metadata}) async {
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    final batch = _firestore.batch();

    final messageData = {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': type,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      if (metadata != null) 'metadata': metadata,
    };
    
    batch.set(messageRef, messageData);

    // Prepare update data for the chat document
    final uniqueParticipants = participants.where((p) => p.isNotEmpty).toSet().toList();
    if (uniqueParticipants.length < participants.toSet().length) {
      print('WARNING: [ChatService] Some participants were empty strings! Provided: $participants');
    }
    final isSaved = uniqueParticipants.length == 1 && uniqueParticipants.first == senderId;

    String lastMsgText = text;
    if (type == 'image') lastMsgText = '📷 Фотография';
    if (type == 'file') lastMsgText = '📁 Файл: ${fileName ?? ''}';
    if (type == 'audio') lastMsgText = '🎤 Голосовое сообщение';
    if (type == 'video') lastMsgText = '🎥 Видеосообщение';
    if (type == 'story_reply') lastMsgText = 'Ответ на историю: $text';

    Map<String, dynamic> chatUpdate = {
      'participants': uniqueParticipants,
      'type': isSaved ? 'saved' : 'personal',
      'lastMessage': lastMsgText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    };

    // Increment unread count for other participants
    for (var participant in uniqueParticipants) {
      if (participant != senderId) {
        chatUpdate['unreadCount.$participant'] = FieldValue.increment(1);
      }
    }

    final chatRef = _firestore.collection('chats').doc(chatId);
    
    print('DEBUG: Sending message to $chatId. Participants to increment: ${uniqueParticipants.where((p) => p != senderId).toList()}');
    print('DEBUG: Update payload: $chatUpdate');

    // Using update instead of set(merge: true) to ensure dot notation works for Nested Maps
    batch.update(chatRef, chatUpdate);

    await batch.commit();
  }

  /// Upload file and send as message
  Future<void> uploadAndSendMedia({
    required String chatId,
    required String senderId,
    required List<String> participants,
    required String filePath,
    required String fileName,
    required String type, // 'image' or 'file'
    required List<int> bytes, // For web support
  }) async {
    final String extension = p.extension(fileName);
    final String storagePath = 'chats/$chatId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final Reference ref = _storage.ref().child(storagePath);

    UploadTask uploadTask;
    if (kIsWeb) {
      String contentType = 'application/octet-stream';
      if (type == 'image') contentType = 'image/jpeg';
      else if (type == 'audio') contentType = 'audio/m4a';
      else if (type == 'video') contentType = 'video/mp4';
      uploadTask = ref.putData(Uint8List.fromList(bytes), SettableMetadata(contentType: contentType));
    } else {
      uploadTask = ref.putFile(File(filePath));
    }

    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    await sendMessage(
      chatId,
      senderId,
      type == 'image' ? 'Фотография' : (type == 'audio' ? 'Голосовое сообщение' : (type == 'video' ? 'Видеосообщение' : fileName)),
      participants,
      type: type,
      mediaUrl: downloadUrl,
      fileName: fileName,
    );
  }

  /// Mark chat as read for a specific user
  Future<void> markAsRead(String chatId, String userId) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final doc = await chatRef.get();
    if (doc.exists) {
      print('DEBUG: Marking chat $chatId as read for user $userId');
      await chatRef.update({
        'unreadCount.$userId': 0,
        'markedUnreadBy': FieldValue.arrayRemove([userId]),
      });
    }
  }

  /// Delete all messages in a chat and reset its metadata
  Future<void> clearChatMessages(String chatId) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');
    
    // 1. Delete all media from Storage
    await _deleteAllChatMedia(chatId);

    // 2. Get all messages (limited to 500 for safety in a single batch)
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

  /// Delete the entire chat and all its messages
  Future<void> deleteChat(String chatId) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');
    
    // 1. Delete all media from Storage
    await _deleteAllChatMedia(chatId);

    // 2. Delete all messages (up to 500)
    final messagesSnapshot = await messagesRef.get();
    final batch = _firestore.batch();
    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // 2. Delete the chat document itself
    batch.delete(chatRef);
    
    await batch.commit();
  }

  /// Delete all media files in the chat's storage folder
  Future<void> _deleteAllChatMedia(String chatId) async {
    try {
      final storageRef = _storage.ref().child('chats/$chatId');
      final listResult = await storageRef.listAll();
      
      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      print('DEBUG: No media or error deleting media for chat $chatId: $e');
    }
  }

  /// Toggle pin status for a chat
  Future<void> togglePinChat(String chatId, String userId, bool isPinned) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    if (isPinned) {
      await chatRef.update({
        'pinnedBy': FieldValue.arrayUnion([userId]),
      });
    } else {
      await chatRef.update({
        'pinnedBy': FieldValue.arrayRemove([userId]),
      });
    }
  }

  /// Toggle "marked as unread" status
  Future<void> toggleMarkAsUnread(String chatId, String userId, bool isMarked) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    if (isMarked) {
      await chatRef.update({
        'markedUnreadBy': FieldValue.arrayUnion([userId]),
      });
    } else {
      await chatRef.update({
        'markedUnreadBy': FieldValue.arrayRemove([userId]),
      });
    }
  }
}
