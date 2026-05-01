import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pro_network/services/post_service.dart';
import 'package:pro_network/models/post_model.dart';
import 'package:pro_network/screens/profile_edit_screen.dart';
import 'package:pro_network/screens/create_post_screen.dart';
import 'package:pro_network/widgets/create_content_menu.dart';
import 'package:pro_network/screens/auth_choice_screen.dart';
import 'package:pro_network/screens/user_posts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LayerLink _layerLink = LayerLink();
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );

  // Real-time stream of user data — updates immediately after profile edit
  Stream<Map<String, dynamic>?> _userStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.data());
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
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
                'Вы уверены что хотите выйти?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
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
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
                            (route) => false,
                          );
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
                          'Выйти',
                          style: TextStyle(color: Color(0xFFFF8E30), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: _userStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF8E30)),
              );
            }
            final userData = snapshot.data;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildTopBar(),
                  _buildProfileSection(userData),
                  _buildPostsSection(),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          // Center logo
          Image.asset(
            'assets/images/logoProfile.png',
            height: 24,
            fit: BoxFit.contain,
          ),
          // Edit button
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              );
              // Stream auto-updates, no manual reload needed
            },
            child: Container(
              width: 25,
              height: 25,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.5, color: Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic>? userData) {
    final String name = userData?['displayName'] ?? 'Пользователь';
    final String photoUrl = userData?['photoUrl'] ?? '';
    final String position = userData?['position'] ?? '';
    final String company = userData?['company'] ?? '';
    final String category = userData?['category'] ?? '';
    final String activity = userData?['activity'] ?? '';

    final String avatarUrl = photoUrl.isNotEmpty
        ? photoUrl
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=125&background=283F41&color=fff';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        spacing: 27,
        children: [
          // Avatar
          Container(
            width: 125,
            height: 125,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage(avatarUrl),
                fit: BoxFit.cover,
              ),
              shape: const OvalBorder(),
            ),
          ),
          // Name and info
          Column(
            spacing: 5,
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.30,
                ),
              ),
              if (position.isNotEmpty || company.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    const Icon(Icons.business_center_outlined, size: 15, color: Color(0xFFC6C6C6)),
                    Flexible(
                      child: Text(
                        '${position.isNotEmpty ? position : ''}${position.isNotEmpty && company.isNotEmpty ? ' в ' : ''}${company.isNotEmpty ? company : ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFC6C6C6),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                    ),
                  ],
                ),
              if (category.isNotEmpty || activity.isNotEmpty)
                Text(
                  '${category.isNotEmpty ? category : ''}${category.isNotEmpty && activity.isNotEmpty ? ' • ' : ''}${activity.isNotEmpty ? activity : ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFC6C6C6),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    final String userId = _auth.currentUser?.uid ?? '';

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
      child: Column(
        spacing: 10,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Личная лента',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
              CompositedTransformTarget(
                link: _layerLink,
                child: GestureDetector(
                  onTap: () {
                    CreateContentMenu.show(
                      context, 
                      _layerLink,
                      offset: const Offset(-145, 25), // Align to the right side of the button
                    );
                  },
                  child: Row(
                    spacing: 5,
                    children: [
                      const Text(
                        'Добавить',
                        style: TextStyle(
                          color: Color(0xFFC6C6C6),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                      Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8E30),
                          borderRadius: BorderRadius.circular(8.5),
                        ),
                        child: const Icon(Icons.add, size: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Posts grid
          if (userId.isNotEmpty)
            StreamBuilder<List<Post>>(
              stream: _postService.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30))),
                  );
                }

                // Filter only current user's posts
                final allPosts = snapshot.data ?? [];
                final myPosts = allPosts.where((p) => p.userId == userId).toList();

                if (myPosts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Публикаций пока нет',
                        style: TextStyle(color: Color(0xFF637B7E), fontSize: 14),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: myPosts.length,
                  itemBuilder: (context, index) {
                    final post = myPosts[index];
                    final imageUrl = post.imageUrl;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPostsScreen(
                              posts: myPosts,
                              initialIndex: index,
                              title: 'Личная лента',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C3135),
                          image: imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl.isEmpty
                            ? const Center(
                                child: Icon(Icons.article_outlined, color: Color(0xFF557578), size: 30),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
