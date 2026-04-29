import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_network/models/post_model.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/services/post_service.dart';
import 'package:pro_network/widgets/comments_bottom_sheet.dart';
import 'package:pro_network/widgets/post_options_menu.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final UserService userService;
  final PostService postService;

  const PostCard({
    super.key,
    required this.post,
    required this.userService,
    required this.postService,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LayerLink _layerLink = LayerLink();

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} д. назад';
    if (diff.inHours > 0) return '${diff.inHours} ч. назад';
    if (diff.inMinutes > 0) return '${diff.inMinutes} мин. назад';
    return 'только что';
  }

  Future<void> _handleUnsubscribe(String currentUserId) async {
    try {
      await widget.userService.toggleSubscription(currentUserId, widget.post.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы отписались от пользователя'),
            backgroundColor: Color(0xFF334D50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при отписке: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser?.uid ?? '';
    final bool isLiked = widget.post.likes.contains(currentUserId);

    return FutureBuilder<Map<String, dynamic>?>(
      future: widget.userService.getUserData(widget.post.userId),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final String rawName = userData?['displayName'] ?? '';
        final String name = rawName.isEmpty ? 'User' : rawName;
        final String jobTitle = userData?['jobTitle'] ?? 'Пользователь';
        final String company = userData?['company'] ?? '';
        final String photoUrl = userData?['photoUrl'] ?? '';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 30),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: photoUrl.isNotEmpty 
                                ? NetworkImage(photoUrl) 
                                : NetworkImage("https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=50&background=random"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            company.isNotEmpty ? '$jobTitle • $company' : jobTitle,
                            style: const TextStyle(color: Color(0xFFABABAB), fontSize: 12),
                          ),
                          Text(
                            userData?['description'] ?? '',
                            style: const TextStyle(color: Color(0xFFABABAB), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (widget.post.userId != currentUserId)
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz, color: Color(0xFF515353)),
                        onPressed: () => PostOptionsMenu.show(
                          context, 
                          _layerLink,
                          onUnsubscribe: () => _handleUnsubscribe(currentUserId),
                          onMute: () {
                            print('Mute tapped');
                          },
                          onReport: () {
                            print('Report tapped');
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                height: 266,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(widget.post.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                widget.post.text,
                style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.33),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => widget.postService.toggleLike(widget.post.id, currentUserId),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border, 
                          size: 20, 
                          color: isLiked ? Colors.red : const Color(0xFFC6C6C6)
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.post.likes.length}',
                        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFC6C6C6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.remove_red_eye_outlined, size: 10, color: Color(0xFFC6C6C6)),
                            const SizedBox(width: 5),
                            const Text(
                              '0',
                              style: TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () => CommentsBottomSheet.show(context, widget.post.id),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: const Icon(Icons.mode_comment_outlined, size: 18, color: Color(0xFFC6C6C6)),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatTimeAgo(widget.post.createdAt),
                    style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
