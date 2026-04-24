import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;

  const CommentsBottomSheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(postId: postId),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  String? _replyToCommentId;
  String? _replyToUserName;
  
  final Map<String, Map<String, dynamic>> _userCache = {};
  bool _isSending = false;

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }
    final data = await _userService.getUserData(userId);
    if (data != null && mounted) {
      setState(() {
        _userCache[userId] = data;
      });
      return data;
    }
    return {};
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    final success = await _postService.addComment(
      widget.postId,
      text,
      replyToCommentId: _replyToCommentId,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
        if (success) {
          _textController.clear();
          _replyToCommentId = null;
          _replyToUserName = null;
          _focusNode.unfocus();
        }
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при отправке комментария')),
        );
      }
    }
  }

  void _handleReply(String commentId, String userName) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUserName = userName;
    });
    _focusNode.requestFocus();
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} д.';
    if (diff.inHours > 0) return '${diff.inHours} ч.';
    if (diff.inMinutes > 0) return '${diff.inMinutes} мин.';
    return 'только что';
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handling keyboard overlapping
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
          bottom: 20,
        ),
        decoration: const ShapeDecoration(
          color: Color(0xFF11292B),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFF0C3135)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(0xCC000000),
              blurRadius: 20,
              offset: Offset(0, -20),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'Комментарии',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // StreamBuilder for Comments
            Expanded(
              child: StreamBuilder<List<Comment>>(
                stream: _postService.getCommentsStream(widget.postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30)));
                  }

                  final comments = snapshot.data ?? [];
                  
                  if (comments.isEmpty) {
                    return const Center(
                      child: Text(
                        'Здесь пока нет комментариев.\Будьте первым!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF637B7E), fontSize: 14),
                      ),
                    );
                  }

                  // Организация веток комментариев:
                  final parentComments = comments.where((c) => c.replyToCommentId == null).toList();
                  final List<Comment> displayList = [];
                  
                  for (var parent in parentComments) {
                    displayList.add(parent);
                    final children = comments.where((c) => c.replyToCommentId == parent.id).toList();
                    displayList.addAll(children);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${comments.length} комментариев',
                            style: const TextStyle(
                              color: Color(0xFFC6C6C6),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Divider(color: Color(0xFFC6C6C6), height: 1),
                      const SizedBox(height: 10),

                      // List
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final comment = displayList[index];
                            final isReply = comment.replyToCommentId != null;
                            
                            // To know which comment ID to reply to. Replies to replies attach to the parent.
                            final replyTargetId = isReply ? comment.replyToCommentId! : comment.id;

                            return _buildCommentItem(comment, replyTargetId, isReply);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Reply Indicator
            if (_replyToUserName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color: Color(0xFF0C3135),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ответ: $_replyToUserName',
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyToCommentId = null;
                          _replyToUserName = null;
                        });
                      },
                      child: const Icon(Icons.close, size: 16, color: Color(0xFFC6C6C6)),
                    ),
                  ],
                ),
              ),

            // Input field
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: ShapeDecoration(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF557578),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                   Expanded(
                     child: TextField(
                       controller: _textController,
                       focusNode: _focusNode,
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 14,
                         fontFamily: 'Inter',
                         fontWeight: FontWeight.w400,
                       ),
                       maxLines: 4,
                       minLines: 1,
                       decoration: const InputDecoration(
                         hintText: 'Оставьте комментарий...',
                         hintStyle: TextStyle(color: Color(0xFF637B7E)),
                         border: InputBorder.none,
                         isDense: true,
                         contentPadding: EdgeInsets.zero,
                         filled: true,
                         fillColor: Colors.transparent,
                       ),
                     ),
                   ),
                   const SizedBox(width: 10),
                   GestureDetector(
                     onTap: _handleSend,
                     child: _isSending 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Color(0xFFFF8E30), strokeWidth: 2)
                          )
                        : const Icon(Icons.send, color: Color(0xFFFF8E30), size: 20),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // Home Indicator
            Center(
              child: Container(
                width: 139,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, String replyTargetId, bool isReply) {
    final String currentUserId = _auth.currentUser?.uid ?? '';
    final bool isLiked = comment.likes.contains(currentUserId);
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(comment.userId),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {};
        final rawName = userData['displayName'] ?? '';
        final name = rawName.isEmpty ? 'User' : rawName;
        final photoUrl = userData['photoUrl'] ?? '';

        return Padding(
          padding: EdgeInsets.only(left: isReply ? 30.0 : 0.0, bottom: 20.0),
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
                        _formatTimeAgo(comment.createdAt),
                        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                      ),
                    ],
                  ),
                  const Icon(Icons.more_horiz, color: Color(0xFF515353), size: 16),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.text,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _postService.toggleCommentLike(widget.postId, comment.id, currentUserId),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : const Color(0xFF949494),
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${comment.likes.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () => _handleReply(replyTargetId, name),
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
      }
    );
  }
}
