import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../models/chat_model.dart';
import 'conversation_screen.dart';
import '../widgets/chat_list_options_menu.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
  Map<String, Map<String, dynamic>> _userCache = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return "Вчера";
    } else {
      return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _loadProfile(String uid) async {
    if (!_userCache.containsKey(uid)) {
      final data = await _userService.getUserData(uid);
      if (data != null && mounted) {
        setState(() {
          _userCache[uid] = data;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF01191B),
        body: Center(child: Text('Пожалуйста, войдите в систему', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _buildSearchHeader(),
              const SizedBox(height: 15),
              _buildFilterTabs(),
              const SizedBox(height: 15),
              Expanded(
                child: StreamBuilder<List<ChatModel>>(
                  stream: _chatService.getUserChatsStream(_currentUserId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Ошибка: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF8E30)),
                      );
                    }

                    final allChats = snapshot.data!;
                    final filteredChats = _applyFilter(allChats);

                    if (filteredChats.isEmpty) {
                      return const Center(
                        child: Text('Чатов не найдено', style: TextStyle(color: Color(0xFF637B7E))),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        print('DEBUG UI: Chat ${chat.id} has unreadCount: ${chat.unreadCount}');
                        return _buildChatRow(chat);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ChatModel> _applyFilter(List<ChatModel> chats) {
    if (_searchQuery.isEmpty) return chats;
    final lowerQuery = _searchQuery.toLowerCase();
    
    return chats.where((chat) {
      if (chat.type == 'saved') {
        return 'избранное'.contains(lowerQuery);
      } else {
        final otherUids = chat.participants.where((uid) => uid != _currentUserId).toList();
        if (otherUids.isNotEmpty) {
          final uid = otherUids.first;
          final userData = _userCache[uid];
          final name = (userData?['displayName'] ?? '').toString().toLowerCase();
          return name.contains(lowerQuery);
        }
        return false;
      }
    }).toList();
  }

  Widget _buildChatRow(ChatModel chat) {
    if (chat.type == 'saved') {
      return _buildChatItem(
        title: 'Избранное',
        subtitle: chat.lastMessage.isEmpty ? 'Личное пространство' : chat.lastMessage,
        time: _formatTime(chat.lastMessageTime),
        isFavorite: true,
        icon: Icons.bookmark_border,
        unreadCount: chat.unreadCount[_currentUserId] ?? 0,
        isPinned: chat.isPinnedByUser(_currentUserId!),
        isMarkedUnread: chat.isMarkedUnreadByUser(_currentUserId!),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationScreen(
                chatId: chat.id,
                otherParticipant: {
                  'displayName': 'Избранное',
                  'uid': _currentUserId,
                },
              ),
            ),
          );
        },
        onLongPress: null, // No menu for saved messages as per request
      );
    } else {
      final otherUids = chat.participants.where((uid) => uid != _currentUserId).toList();
      if (otherUids.isEmpty) return const SizedBox.shrink();
      
      final uid = otherUids.first;
      final userData = _userCache[uid];

      if (userData == null) {
        _loadProfile(uid); // Load asynchronously
      }

      return GestureDetector(
        onLongPressStart: (details) {
          ChatListOptionsMenu.show(
            context, 
            details.globalPosition,
            chat: chat,
            currentUserId: _currentUserId!,
            onPin: () => _pinChat(chat),
            onMute: () => _muteChatNotifications(chat),
            onMarkNew: () => _markChatAsNew(chat),
            onClear: () => _confirmClearChat(chat),
            onDelete: () => _confirmDeleteChat(chat),
          );
        },
        child: _buildChatItem(
          title: userData?['displayName'] ?? 'Загрузка...',
          subtitle: chat.lastMessage.isEmpty ? 'Новый чат' : chat.lastMessage,
          time: _formatTime(chat.lastMessageTime),
          imageUrl: userData?['photoUrl'],
          unreadCount: chat.unreadCount[_currentUserId] ?? 0,
          isPinned: chat.isPinnedByUser(_currentUserId!),
          isMarkedUnread: chat.isMarkedUnreadByUser(_currentUserId!),
          onTap: () {
            if (userData != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    chatId: chat.id,
                    otherParticipant: userData,
                  ),
                ),
              );
            }
          },
        ),
      );
    }
  }

  Widget _buildSearchHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 35,
            decoration: ShapeDecoration(
              color: const Color(0xFF0C3135),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFF557578)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Поиск по чатам',
                hintStyle: TextStyle(color: Color(0xFF637B7E), fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 12),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(color: Color(0xFF334D50), shape: BoxShape.circle),
          child: const Icon(Icons.edit_note, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildTab('Личные', isActive: true),
      ],
    );
  }

  Widget _buildTab(String title, {bool isActive = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isActive ? const Border(bottom: BorderSide(color: Colors.white, width: 1)) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFFC6C6C6),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required String title,
    required String subtitle,
    required String time,
    String? imageUrl,
    IconData? icon,
    bool isFavorite = false,
    int unreadCount = 0,
    bool isPinned = false,
    bool isMarkedUnread = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar Section
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF283F41),
                            shape: OvalBorder(),
                          ),
                          child: ClipOval(
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(imageUrl, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white))
                                : Icon(icon ?? Icons.person, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Info & Counter Section
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: 0.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: Color(0xFFC6C6C6),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Time and Unread Counter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              time,
                              style: const TextStyle(
                                color: Color(0xFF557578),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                             const SizedBox(height: 13),
                             Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 if (isPinned)
                                   const Padding(
                                     padding: EdgeInsets.only(right: 5),
                                     child: Icon(Icons.push_pin, color: Color(0xFF557578), size: 12),
                                   ),
                                 if (unreadCount > 0)
                                   Container(
                                     height: 13,
                                     padding: const EdgeInsets.symmetric(horizontal: 4),
                                     decoration: ShapeDecoration(
                                       color: const Color(0xFF557578),
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(21),
                                       ),
                                     ),
                                     alignment: Alignment.center,
                                     child: Text(
                                       unreadCount.toString(),
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontSize: 9,
                                         fontFamily: 'Inter',
                                         fontWeight: FontWeight.w400,
                                       ),
                                     ),
                                   )
                                 else if (isMarkedUnread)
                                   Container(
                                     width: 10,
                                     height: 10,
                                     decoration: const BoxDecoration(
                                       color: Color(0xFFFF8E30),
                                       shape: BoxShape.circle,
                                     ),
                                   ),
                               ],
                             ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFC6C6C6),
              thickness: 0.5,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _pinChat(ChatModel chat) async {
    if (_currentUserId == null) return;
    
    final bool currentlyPinned = chat.isPinnedByUser(_currentUserId!);
    try {
      await _chatService.togglePinChat(chat.id, _currentUserId!, !currentlyPinned);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(currentlyPinned ? 'Чат откреплен' : 'Чат закреплен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _muteChatNotifications(ChatModel chat) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция "Уведомления" будет доступна скоро')),
    );
  }

  void _markChatAsNew(ChatModel chat) async {
    if (_currentUserId == null) return;
    
    final bool currentlyMarked = chat.isMarkedUnreadByUser(_currentUserId!);
    try {
      await _chatService.toggleMarkAsUnread(chat.id, _currentUserId!, !currentlyMarked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(currentlyMarked ? 'Отметка снята' : 'Чат помечен как новый')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _confirmClearChat(ChatModel chat) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => _buildConfirmationDialog(
        title: 'Очистить историю?',
        content: 'Все сообщения в этом чате будут удалены.',
        confirmLabel: 'Очистить',
        onConfirm: () async {
          await _chatService.clearChatMessages(chat.id);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('История очищена')));
        },
      ),
    );
  }

  void _confirmDeleteChat(ChatModel chat) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => _buildConfirmationDialog(
        title: 'Удалить чат?',
        content: 'Чат и вся история переписки будут удалены навсегда.',
        confirmLabel: 'Удалить',
        onConfirm: () async {
          await _chatService.deleteChat(chat.id);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Чат удален')));
        },
      ),
    );
  }

  Widget _buildConfirmationDialog({
    required String title,
    required String content,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 14),
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
                      child: const Text('Нет', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF334D50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(confirmLabel, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
