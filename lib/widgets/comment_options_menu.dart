import 'package:flutter/material.dart';

class CommentOptionsMenu extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onBlock;

  const CommentOptionsMenu({
    super.key,
    required this.onDelete,
    required this.onBlock,
  });

  static void show(
    BuildContext context, 
    LayerLink layerLink, {
    required VoidCallback onDelete,
    required VoidCallback onBlock,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CommentOptionsMenu',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                offset: const Offset(0, 5),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {},
                    child: CommentOptionsMenu(
                      onDelete: onDelete,
                      onBlock: onBlock,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 194, // Slightly narrower than post menu
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
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
          _buildItem(
            text: 'Удалить комментарий',
            isTop: true,
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          _buildDivider(),
          _buildItem(
            text: 'Заблокировать',
            isBottom: true,
            onTap: () {
              Navigator.pop(context);
              onBlock();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String text,
    bool isTop = false,
    bool isBottom = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: ShapeDecoration(
          color: const Color(0xFF334D50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isTop ? const Radius.circular(10) : Radius.zero,
              topRight: isTop ? const Radius.circular(10) : Radius.zero,
              bottomLeft: isBottom ? const Radius.circular(10) : Radius.zero,
              bottomRight: isBottom ? const Radius.circular(10) : Radius.zero,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: const Color(0xFFC6C6C6).withOpacity(0.5),
    );
  }
}
