import 'package:flutter/material.dart';
import 'package:pro_network/models/post_model.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/services/post_service.dart';
import 'package:pro_network/widgets/post_card.dart';

class UserPostsScreen extends StatelessWidget {
  final List<Post> posts;
  final String title;
  final int initialIndex;

  const UserPostsScreen({
    super.key,
    required this.posts,
    this.title = 'Посты пользователя',
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    final PostService postService = PostService();
    final ScrollController scrollController = ScrollController();

    // Scroll to initial index after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialIndex > 0 && initialIndex < posts.length) {
        // Simple heuristic: each post is roughly 450-500 pixels high
        // For better accuracy we could use a GlobalKey, but this is usually fine for a start
        scrollController.jumpTo(initialIndex * 450.0);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01191B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: posts[index],
            userService: userService,
            postService: postService,
          );
        },
      ),
    );
  }
}
