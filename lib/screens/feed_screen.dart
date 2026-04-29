import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/services/story_service.dart';
import 'package:pro_network/models/story_model.dart';
import 'package:pro_network/screens/create_story_screen.dart';
import 'package:pro_network/screens/story_view_screen.dart';
import 'package:pro_network/screens/create_post_screen.dart';
import 'package:pro_network/models/post_model.dart';
import 'package:pro_network/services/post_service.dart';
import 'package:pro_network/screens/profile_screen.dart';
import 'package:pro_network/widgets/create_content_menu.dart';
import 'package:pro_network/widgets/comments_bottom_sheet.dart';
import 'package:pro_network/widgets/post_card.dart';
import 'package:pro_network/services/user_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final UserService _userService = UserService();
  final StoryService _storyService = StoryService();
  final PostService _postService = PostService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey _addButtonKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  
  late Stream<List<String>> _followingStream;
  late Stream<List<Post>> _postsStream;

  @override
  void initState() {
    super.initState();
    _followingStream = _userService.getUserFollowingStream(_auth.currentUser?.uid ?? '');
    _postsStream = _postService.getPostsStream();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final data = await _userService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            _userData = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading user data in FeedScreen: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          color: const Color(0xFFFF8E30),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: StreamBuilder<List<String>>(
              stream: _followingStream,
              builder: (context, followingSnapshot) {
                final followingList = followingSnapshot.data ?? [];
                
                return Column(
                  children: [
                    _buildMainProfileHeader(),
                    _buildStoriesSection(followingList),
                    _buildCategoryTabs(),
                    
                    // LIVE POSTS FEED
                    StreamBuilder<List<Post>>(
                      stream: _postsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: Colors.orange),
                          ));
                        }
                        
                        final String currentUserId = _auth.currentUser?.uid ?? '';
                        final allPosts = snapshot.data ?? [];
                        final posts = allPosts.where((post) {
                          return post.userId == currentUserId || followingList.contains(post.userId);
                        }).toList();
                        
                        if (posts.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                              child: Text(
                                'У вас пока нет подписок. Перейдите в поиск, чтобы найти интересных людей!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF637B7E), fontSize: 14),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: posts[index],
                              userService: _userService,
                              postService: _postService,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainProfileHeader() {
    if (_isLoading) {
      return _buildSkeletonHeader();
    }

    final String nameData = _userData?['displayName'] ?? '';
    final String fullName = nameData.isEmpty ? 'User' : nameData;
    final String photoUrl = _userData?['photoUrl'] ?? '';
    final String position = _userData?['position'] ?? '';
    final String company = _userData?['company'] ?? '';
    final String category = _userData?['category'] ?? '';
    final String activity = _userData?['activity'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: photoUrl.isNotEmpty 
                          ? NetworkImage(photoUrl) 
                          : NetworkImage("https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&size=70&background=random"),
                      fit: BoxFit.cover,
                    ),
                    shape: const OvalBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const ShapeDecoration(
                                color: Color(0xFFFF8E30),
                                shape: OvalBorder(),
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (position.isNotEmpty || company.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.business_center_outlined, size: 15, color: Color(0xFFC6C6C6)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${position}${position.isNotEmpty && company.isNotEmpty ? ' ' : ''}${company}',
                              style: const TextStyle(
                                color: Color(0xFFC6C6C6),
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 2),
                    if (category.isNotEmpty || activity.isNotEmpty)
                      Text(
                        '${category}${category.isNotEmpty && activity.isNotEmpty ? ' • ' : ''}${activity}',
                        style: const TextStyle(
                          color: Color(0xFFC6C6C6),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              // TODO: Implement "My Connections" or similar logic
              print('Svayzi button tapped');
            },
            child: Image.asset(
              'assets/images/svayziButton.png',
              width: double.infinity,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70, height: 70,
                decoration: const BoxDecoration(color: Color(0xFF1A4549), shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 15, decoration: BoxDecoration(color: const Color(0xFF1A4549), borderRadius: BorderRadius.circular(5))),
                    const SizedBox(height: 10),
                    Container(width: 100, height: 10, decoration: BoxDecoration(color: const Color(0xFF1A4549), borderRadius: BorderRadius.circular(5))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(width: double.infinity, height: 35, decoration: BoxDecoration(color: const Color(0xFF1A4549), borderRadius: BorderRadius.circular(10))),
        ],
      ),
    );
  }

  Widget _buildStoriesSection(List<String> followingList) {
    final String userPhotoUrl = _userData?['photoUrl'] ?? '';
    final String currentUserId = _auth.currentUser?.uid ?? '';

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: StreamBuilder<List<Story>>(
        stream: _storyService.getStoriesStream(),
        builder: (context, snapshot) {
          // Получаем список сторис, группируем их по пользователям
          final stories = snapshot.data ?? [];
          
          // Сторис текущего пользователя
          final myStories = stories.where((s) => s.userId == currentUserId).toList();
          
          // Словарь для сторис других пользователей
          final Map<String, List<Story>> groupedStories = {};
          for (var story in stories) {
            if (story.userId == currentUserId) continue;
            // Фильтруем по подпискам
            if (!followingList.contains(story.userId)) continue;
            
            if (!groupedStories.containsKey(story.userId)) {
              groupedStories[story.userId] = [];
            }
            groupedStories[story.userId]!.add(story);
          }

          final uniqueUserIds = groupedStories.keys.toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            children: [
              // "You" Story with Add Button
              _buildUserStoryItem(userPhotoUrl, myStories),
              const SizedBox(width: 12),
              
              // Другие сторис из базы
              ...uniqueUserIds.map((uid) {
                final userStories = groupedStories[uid]!;
                // Проверяем, есть ли хотя бы одна непросмотренная сторис у этого пользователя
                final bool isUnread = userStories.any((s) => !s.viewers.contains(currentUserId));
                
                return _buildOtherStoryItemFromFirebase(uid, userStories, isUnread);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOtherStoryItemFromFirebase(String userId, List<Story> userStories, bool isUnread) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userService.getUserData(userId),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final String rawName = userData?['displayName'] ?? '';
        final String name = rawName.isEmpty ? 'User' : rawName.split(' ')[0];
        final String photoUrl = userData?['photoUrl'] ?? '';

        return GestureDetector(
          onTap: () {
            if (userStories.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryViewScreen(
                    stories: userStories,
                    userName: userData?['displayName'] ?? name,
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUnread ? const Color(0xFFFF8E30) : const Color(0xFFABABAB),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: photoUrl.isNotEmpty 
                            ? NetworkImage(photoUrl) 
                            : NetworkImage("https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=50&background=random"),
                        fit: BoxFit.cover,
                      ),
                      shape: const OvalBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserStoryItem(String photoUrl, List<Story> myStories) {
    final bool hasStories = myStories.isNotEmpty;
    final String currentUserId = _auth.currentUser?.uid ?? '';
    final bool isUnread = myStories.any((s) => !s.viewers.contains(currentUserId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 53,
          height: 53,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (hasStories) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryViewScreen(
                          stories: myStories,
                          userName: 'Вы',
                        ),
                      ),
                    );
                  } else {
                    CreateContentMenu.show(context, _layerLink);
                  }
                },
                child: Container(
                  width: 50,
                  height: 50,
                  padding: hasStories ? const EdgeInsets.all(2) : null,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: hasStories ? Border.all(
                      color: isUnread ? const Color(0xFFFF8E30) : const Color(0xFFABABAB),
                      width: 2,
                    ) : null,
                  ),
                  child: Container(
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: photoUrl.isNotEmpty 
                            ? NetworkImage(photoUrl) 
                            : NetworkImage("https://ui-avatars.com/api/?name=${Uri.encodeComponent(_userData?['displayName'] ?? 'User')}&size=50&background=random"),
                        fit: BoxFit.cover,
                      ),
                      shape: const OvalBorder(),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: GestureDetector(
                    key: _addButtonKey,
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('!!! ADD BUTTON TAPPED !!!');
                      CreateContentMenu.show(context, _layerLink);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3), // Увеличиваем зону касания
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFF8E30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.50),
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Вы',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }



  Widget _buildOtherStoryItem(String name, String photoUrl, bool isUnread) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnread ? const Color(0xFFFF8E30) : const Color(0xFFABABAB),
                width: 2,
              ),
            ),
            child: Container(
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage(photoUrl),
                  fit: BoxFit.cover,
                ),
                shape: const OvalBorder(),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          _buildTab('Лента', isActive: true),
          const SizedBox(width: 15),
          _buildTab('Новости'),
          const SizedBox(width: 15),
          _buildTab('Предложения'),
        ],
      ),
    );
  }

  Widget _buildTab(String title, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: isActive 
        ? const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
          )
        : null,
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFFC6C6C6),
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

}
