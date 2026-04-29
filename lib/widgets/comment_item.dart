import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import './comment_options_menu.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final String postId;
  final String replyTargetId;
  final bool isReply;
  final Function(String, String) onReply;
  final String formatTimeAgo;
  final PostService postService;
  final UserService userService;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    required this.replyTargetId,
    required this.isReply,
    required this.onReply,
    required this.formatTimeAgo,
    required this.postService,
    required this.userService,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser?.uid ?? '';
    final bool isLiked = widget.comment.likes.contains(currentUserId);

    return FutureBuilder<Map<String, dynamic>?>(
      future: widget.userService.getUserData(widget.comment.userId),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {};
        final rawName = userData['displayName'] ?? '';
        final name = rawName.isEmpty ? 'User' : rawName;
        final photoUrl = userData['photoUrl'] ?? '';

        return Padding(
          padding: EdgeInsets.only(left: widget.isReply ? 30.0 : 0.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : NetworkImage("https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=20&background=random"),
                            fit: BoxFit.cover,
                          ),
                          shape: const OvalBorder(),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.formatTimeAgo,
                        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                      ),
                    ],
                  ),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: GestureDetector(
                      onTap: () {
                        CommentOptionsMenu.show(
                          context, 
                          _layerLink,
                          onDelete: () async {
                            final success = await widget.postService.deleteComment(widget.postId, widget.comment.id);
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Комментарий удален')),
                              );
                            }
                          },
                          onBlock: () {
                            // TODO: Implement block logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Пользователь заблокирован (демо)')),
                            );
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.more_horiz, color: Color(0xFF515353), size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment.text,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => widget.postService.toggleCommentLike(widget.postId, widget.comment.id, currentUserId),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : const Color(0xFF949494),
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.comment.likes.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () => widget.onReply(widget.replyTargetId, name),
                          child: const Text(
                            'Ответить',
                            style: TextStyle(color: Color(0xFF949494), fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
