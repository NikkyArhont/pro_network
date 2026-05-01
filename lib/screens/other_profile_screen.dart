import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pro_network/services/post_service.dart';
import 'package:pro_network/models/post_model.dart';
import 'package:pro_network/services/chat_service.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/screens/conversation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pro_network/screens/user_posts_screen.dart';

class OtherProfileScreen extends StatefulWidget {
  final String userId;

  const OtherProfileScreen({super.key, required this.userId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  bool _isChatLoading = false;
  bool _isSubLoading = false;
  bool _isRecLoading = false;
  String _selectedInfoTab = 'Описание'; // Описание, Контакты, Прайс
  String _selectedFeedTab = 'Новости'; // Новости, Предложения

  late Stream<Map<String, dynamic>?> _userDataStream;
  late Stream<List<String>> _followingStream;
  late Stream<List<String>> _recommendersStream;
  late Stream<List<Post>> _postsStream;

  @override
  void initState() {
    super.initState();
    _userDataStream = _firestore
        .collection('users')
        .doc(widget.userId)
        .snapshots()
        .map((snap) => snap.data());
    _followingStream = _userService.getUserFollowingStream(_currentUserId);
    _recommendersStream = _userService.getUserRecommendersStream(widget.userId);
    _postsStream = _postService.getPostsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<Map<String, dynamic>?>(
          stream: _userDataStream,
          builder: (context, snapshot) {
            final name = snapshot.data?['displayName'] ?? '';
            return Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _userDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30)));
          }
          final userData = snapshot.data ?? {};
          return StreamBuilder<List<String>>(
            stream: _followingStream,
            builder: (context, followingSnapshot) {
              final followingList = followingSnapshot.data ?? [];
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    children: [
                      _buildHeaderCard(userData, followingList),
                      const SizedBox(height: 15),
                      _buildInfoCard(userData),
                      const SizedBox(height: 10),
                      _buildFeedCard(userData, followingList),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> userData, List<String> followingList) {
    final String name = userData['displayName'] ?? 'Пользователь';
    final String photoUrl = userData['photoUrl'] ?? '';
    final String city = userData['city'] ?? 'Город не указан';
    final String status = userData['status'] ?? 'Пользователь';
    final String position = userData['position'] ?? 'Специалист';
    
    String tagString = '';
    if (userData['tags'] != null) {
      try {
        tagString = (List<dynamic>.from(userData['tags'])).join(' • ');
      } catch (_) {}
    }

    final String avatarUrl = photoUrl.isNotEmpty 
        ? photoUrl 
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=100&background=283F41&color=fff';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: ShapeDecoration(
                  color: const Color(0xFF283F41),
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  ),
                  shape: const OvalBorder(),
                ),
              ),
              const SizedBox(width: 15),
              // Main Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Color(0xFFC6C6C6)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$status • $position',
                            style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (tagString.isNotEmpty)
                      Text(
                        tagString,
                        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      city,
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<List<String>>(
                stream: _recommendersStream,
                builder: (context, snapshot) {
                  final recCount = snapshot.data?.length ?? 0;
                  return Expanded(
                    child: Container(
                      height: 35,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFF557578)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        recCount > 0 ? 'Рекомендуют: $recCount' : 'Рекомендуют Друзья Друзей',
                        style: const TextStyle(
                          color: Color(0xFF334D50),
                          fontSize: 11,
                          fontFamily: 'Russo One',
                        ),
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(width: 10),
              StreamBuilder<List<String>>(
                stream: _recommendersStream,
                builder: (context, snapshot) {
                  final recommenders = snapshot.data ?? [];
                  final isRecommended = recommenders.contains(_currentUserId);
                  return Row(
                    spacing: 5,
                    children: [
                      _buildActionSquareButton(
                        icon: isRecommended ? Icons.thumb_up : Icons.thumb_up_outlined,
                        hasBadge: isRecommended,
                        isLoading: _isRecLoading,
                        onTap: _toggleRecommendation,
                      ),
                      _buildActionSquareButton(
                        icon: followingList.contains(widget.userId) ? Icons.person_remove : Icons.person_add_outlined,
                        hasBadge: followingList.contains(widget.userId),
                        isLoading: _isSubLoading,
                        onTap: () => _toggleSubscription(followingList),
                      ),
                      _buildActionSquareButton(
                        icon: Icons.chat_bubble_outline,
                        hasBadge: false,
                        isLoading: _isChatLoading,
                        onTap: () => _startChat(userData),
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> userData) {
    final String description = userData['description'] ?? 'Информация пока не добавлена.';
    List<String> tags = [];
    if (userData['tags'] != null) {
      try {
        tags = List<String>.from(userData['tags']);
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Row(
            children: [
              _buildTab('Описание', _selectedInfoTab, () => setState(() => _selectedInfoTab = 'Описание')),
              const SizedBox(width: 15),
              _buildTab('Контакты', _selectedInfoTab, () => setState(() => _selectedInfoTab = 'Контакты')),
              const SizedBox(width: 15),
              _buildTab('Прайс', _selectedInfoTab, () => setState(() => _selectedInfoTab = 'Прайс')),
            ],
          ),
          const SizedBox(height: 15),
          
          if (_selectedInfoTab == 'Описание') ...[
            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => _buildTagPill(tag)).toList(),
              ),
            ],
          ] else if (_selectedInfoTab == 'Контакты') ...[
             const Center(
               child: Padding(
                 padding: EdgeInsets.symmetric(vertical: 20),
                 child: Text('Контакты пока скрыты или не заполнены', style: TextStyle(color: Color(0xFFC6C6C6))),
               ),
             ),
          ] else if (_selectedInfoTab == 'Прайс') ...[
             const Center(
               child: Padding(
                 padding: EdgeInsets.symmetric(vertical: 20),
                 child: Text('Прайс-лист пуст', style: TextStyle(color: Color(0xFFC6C6C6))),
               ),
             ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedCard(Map<String, dynamic> userData, List<String> followingList) {
    final bool isSubscribed = followingList.contains(widget.userId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildTab('Новости', _selectedFeedTab, () => setState(() => _selectedFeedTab = 'Новости')),
                const SizedBox(width: 15),
                _buildTab('Предложения', _selectedFeedTab, () => setState(() => _selectedFeedTab = 'Предложения')),
              ],
            ),
            GestureDetector(
              onTap: () => _toggleSubscription(followingList),
              child: Row(
                children: [
                  Text(
                    isSubscribed ? 'Вы подписаны' : 'Подписаться', 
                    style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSubscribed ? const Color(0xFF557578) : const Color(0xFFFF8E30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSubscribed ? Icons.check : Icons.add, 
                      size: 12, 
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (_selectedFeedTab == 'Новости')
          _buildPostsGrid()
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: ShapeDecoration(
              color: const Color(0xFF0C3135),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Center(
              child: Text(
                'Предложений пока нет',
                style: TextStyle(color: Color(0xFFC6C6C6)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return StreamBuilder<List<Post>>(
      stream: _postsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: Color(0xFFFF8E30)),
          ));
        }

        final allPosts = snapshot.data ?? [];
        final userPosts = allPosts.where((p) => p.userId == widget.userId).toList();

        if (userPosts.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: ShapeDecoration(
              color: const Color(0xFF0C3135),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Center(
              child: Text(
                'Пользователь еще не делал публикаций.',
                style: TextStyle(color: Color(0xFFC6C6C6)),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: userPosts.length,
          itemBuilder: (context, index) {
            final post = userPosts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPostsScreen(
                      posts: userPosts,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: post.imageUrl.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(post.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF0C3135),
                      child: const Center(
                        child: Icon(Icons.article_outlined, color: Color(0xFF557578)),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildTab(String title, String currentTab, VoidCallback onTap) {
    final bool isActive = title == currentTab;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: isActive ? const Border(bottom: BorderSide(color: Colors.white, width: 2)) : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFC6C6C6),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTagPill(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFC6C6C6)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
      ),
    );
  }

  Widget _buildActionSquareButton({
    required IconData icon, 
    required VoidCallback onTap, 
    bool hasBadge = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: ShapeDecoration(
          color: const Color(0xFF334D50),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFF557578)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 15, height: 15,
                child: CircularProgressIndicator(color: Color(0xFFFF8E30), strokeWidth: 2),
              )
            else
              Icon(icon, color: Colors.white, size: 20),
            
            if (hasBadge && !isLoading)
              Positioned(
                top: 2, right: 2,
                child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8E30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 7, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChat(Map<String, dynamic> userData) async {
    if (_currentUserId.isEmpty || widget.userId.isEmpty) return;
    
    if (_isChatLoading) return;
    setState(() => _isChatLoading = true);
    
    try {
      final chatId = await ChatService().getOrCreatePersonalChat(_currentUserId, widget.userId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              chatId: chatId,
              otherParticipant: userData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка создания чата: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isChatLoading = false);
      }
    }
  }

  Future<void> _toggleSubscription(List<String> followingList) async {
    if (_currentUserId.isEmpty || widget.userId.isEmpty) return;
    if (_isSubLoading) return;
    
    setState(() => _isSubLoading = true);
    
    final isSubscribed = followingList.contains(widget.userId);
    try {
      await _userService.toggleSubscription(_currentUserId, widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSubscribed ? 'Вы отписались' : 'Вы подписались'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubLoading = false);
      }
    }
  }

  Future<void> _toggleRecommendation() async {
    if (_currentUserId.isEmpty || widget.userId.isEmpty) return;
    if (_isRecLoading) return;
    
    setState(() => _isRecLoading = true);
    
    try {
      await _userService.toggleRecommendation(_currentUserId, widget.userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка рекомендации: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecLoading = false);
      }
    }
  }
}
