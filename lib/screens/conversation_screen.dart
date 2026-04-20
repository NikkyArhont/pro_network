import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';

class ConversationScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherParticipant;

  const ConversationScreen({
    super.key,
    required this.chatId,
    required this.otherParticipant,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final GlobalKey _menuKey = GlobalKey();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _markRead();
    // Re-render when typing to update send button state
    _messageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _markRead() {
    if (_currentUserId != null) {
      _chatService.markAsRead(widget.chatId, _currentUserId!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId == null) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    try {
      // In a real scenario, we might want to pass actual participants list 
      // but for now we know it's a 1-to-1 chat.
      await _chatService.sendMessage(
        widget.chatId,
        _currentUserId!,
        text,
        [_currentUserId!, widget.otherParticipant['uid'] ?? ''],
      );
      
      // Auto scroll to bottom
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при отправке: $e')),
        );
      }
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
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getChatMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30)));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Messages from bottom to top
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;
                    
                    // Logic for date separators
                    bool showDate = false;
                    String dateText = '';
                    
                    if (message.createdAt != null) {
                      final DateTime date = message.createdAt!;
                      final String currentFormattedDate = "${date.day}.${date.month}.${date.year}";
                      
                      // If it's the last message in the list (oldest), or date changed
                      if (index == messages.length - 1) {
                        showDate = true;
                      } else {
                        final prevMessage = messages[index + 1];
                        if (prevMessage.createdAt != null) {
                          final prevDate = prevMessage.createdAt!;
                          final String prevFormattedDate = "${prevDate.day}.${prevDate.month}.${prevDate.year}";
                          if (currentFormattedDate != prevFormattedDate) {
                            showDate = true;
                          }
                        }
                      }
                      
                      if (showDate) {
                        dateText = _formatDateSeparator(date);
                      }
                    }
                    
                    return Column(
                      children: [
                        if (showDate) _buildDateSeparator(dateText),
                        _buildMessageBubble(message, isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: const Color(0xFF01191B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Поиск по сообщениям...',
            hintStyle: TextStyle(color: Color(0xFF7C9597), fontSize: 16),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: const Color(0xFF01191B),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFF557578),
            backgroundImage: widget.otherParticipant['photoUrl'] != null 
                ? NetworkImage(widget.otherParticipant['photoUrl']) 
                : null,
            child: widget.otherParticipant['photoUrl'] == null 
                ? const Icon(Icons.person, color: Colors.white, size: 20) 
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherParticipant['displayName'] ?? 'Пользователь',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'в сети', // Placeholder
                  style: TextStyle(color: Color(0xFF7C9597), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (widget.chatId.startsWith('saved_'))
          IconButton(
            key: _menuKey,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showSavedMenu(context),
          ),
      ],
    );
  }

  void _showSavedMenu(BuildContext context) {
    final RenderBox? renderBox = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    // Calculate global position of the button
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    
    // Create a RelativeRect that points exactly to the button area
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx - 200, // Shift left so menu is aligned by its right edge or under the button
      offset.dy + renderBox.size.height, // Start right below the button
      offset.dx + renderBox.size.width,
      offset.dy,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: Colors.transparent,
      elevation: 0,
      constraints: const BoxConstraints(maxWidth: 222),
      items: [
        PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          enabled: false,
          child: Container(
            width: 222,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 20,
                  offset: Offset(0, 0),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item 1: Search
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  child: Container(
                    width: 222,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: const ShapeDecoration(
                      color: Color(0xFF334D50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Поиск по избранному',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Single thin divider
                Container(
                  width: double.infinity,
                  height: 0.5,
                  color: const Color(0xFFC6C6C6).withOpacity(0.5),
                ),
                // Item 2: Clear
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _confirmClearChat();
                  },
                  child: Container(
                    width: 222,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: const ShapeDecoration(
                      color: Color(0xFF334D50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Очистить избранное',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(top: 10, left: 10, right: 8, bottom: 5),
        decoration: ShapeDecoration(
          color: isMe ? const Color(0xFF557578) : const Color(0xFF7C9597),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
              child: _buildHighlightedText(message.text),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF334D50),
                    fontSize: 8,
                    fontFamily: 'Inter',
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 11,
                    color: const Color(0xFF334D50),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFC6C6C6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334D50),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
        color: const Color(0xFF01191B),
        child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0C3135),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF557578), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.attach_file, color: Color(0xFF3F5659), size: 15),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Введите сообщение',
                    hintStyle: TextStyle(
                      color: Color(0xFF3F5659),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      letterSpacing: 0.10,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
               const SizedBox(width: 15),
              GestureDetector(
                onTap: _sendMessage,
                child: Icon(
                  Icons.send_rounded,
                  color: _messageController.text.trim().isNotEmpty
                      ? const Color(0xFFFF8E30)
                      : const Color(0xFF3F5659),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    if (_searchQuery.isEmpty || !text.toLowerCase().contains(_searchQuery.toLowerCase())) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Inter',
          height: 1.33,
        ),
      );
    }

    final query = _searchQuery.toLowerCase();
    final lowercaseText = text.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;
    int index = lowercaseText.indexOf(query);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add match with highlight
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: const Color(0xFFFF8E30).withOpacity(0.4),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + query.length;
      index = lowercaseText.indexOf(query, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Inter',
          height: 1.33,
        ),
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0C3135),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF557578), width: 1),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Очистить избранное?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Все сообщения будут удалены навсегда.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFC6C6C6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF557578)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Нет',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          try {
                            await _chatService.clearChatMessages(widget.chatId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Избранное очищено')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка при очистке: $e')),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF334D50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Очистить',
                            style: TextStyle(
                              color: Color(0xFFFF8E30),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Сегодня';
    if (d == yesterday) return 'Вчера';
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }
}
