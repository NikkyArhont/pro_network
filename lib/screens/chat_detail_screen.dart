import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String title;
  final String? imageUrl;
  final bool isSaved;
  final List<String> participants;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.title,
    this.imageUrl,
    this.isSaved = false,
    required this.participants,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _markRead();
  }

  void _markRead() {
    if (_currentUserId != null) {
      _chatService.markAsRead(widget.chatId, _currentUserId!);
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    _messageController.clear();
    
    try {
      // If it's a virtual "saved" chat ID, we might need to ensure its existence first
      String effectiveChatId = widget.chatId;
      if (widget.isSaved && widget.chatId.startsWith('saved_')) {
        effectiveChatId = await _chatService.ensureSavedChatExists(_currentUserId!);
      }

      await _chatService.sendMessage(
        effectiveChatId,
        _currentUserId!,
        text,
        widget.participants,
      );
      
      // Auto-scroll to bottom happens naturally with reverse order list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0C3135),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF334D50),
              shape: BoxShape.circle,
            ),
            child: widget.isSaved 
              ? const Icon(Icons.bookmark_border, color: Colors.white, size: 20)
              : (widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                  ? ClipOval(child: Image.network(widget.imageUrl!, fit: BoxFit.cover))
                  : const Icon(Icons.person, color: Colors.white, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!widget.isSaved)
                  const Text(
                    'в сети', // Dummy for now
                    style: TextStyle(
                      color: Color(0xFF557578),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<MessageModel>>(
      stream: _chatService.getChatMessagesStream(widget.chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30)));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              widget.isSaved ? 'Здесь будут ваши заметки' : 'Начните общение первым',
              style: const TextStyle(color: Color(0xFF557578)),
            ),
          );
        }

        final messages = snapshot.data!;
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          reverse: true, // Newest messages at the bottom
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == _currentUserId;
            return _buildMessageBubble(message, isMe);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF0C3135) : const Color(0xFF1B3B3E),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.createdAt != null 
                    ? DateFormat('HH:mm').format(message.createdAt!)
                    : '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0C3135),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF01191B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF334D50)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Сообщение...',
                  hintStyle: TextStyle(color: Color(0xFF557578)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFF8E30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
