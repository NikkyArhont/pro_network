import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../models/chat_model.dart';
import 'conversation_screen.dart';

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
        }
      );
    } else {
      final otherUids = chat.participants.where((uid) => uid != _currentUserId).toList();
      if (otherUids.isEmpty) return const SizedBox.shrink();
      
      final uid = otherUids.first;
      final userData = _userCache[uid];

      if (userData == null) {
        _loadProfile(uid); // Load asynchronously
      }

      return _buildChatItem(
        title: userData?['displayName'] ?? 'Загрузка...',
        subtitle: chat.lastMessage.isEmpty ? 'Новый чат' : chat.lastMessage,
        time: _formatTime(chat.lastMessageTime),
        imageUrl: userData?['photoUrl'],
        unreadCount: chat.unreadCount[_currentUserId] ?? 0,
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
        }
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: Color(0xFF557578), shape: BoxShape.circle),
                  child: ClipOval(
                    child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover, 
                          errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white))
                      : Icon(icon ?? Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      Text(subtitle, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(time, style: const TextStyle(color: Color(0xFF557578), fontSize: 12)),
                    if (unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF557578), borderRadius: BorderRadius.circular(10)),
                        child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 9)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFC6C6C6), thickness: 0.5, height: 1),
        ],
      ),
    );
  }
}
