import 'package:flutter/material.dart';

class PostOptionsMenu extends StatelessWidget {
  final VoidCallback onUnsubscribe;
  final VoidCallback onMute;
  final VoidCallback onReport;

  const PostOptionsMenu({
    super.key,
    required this.onUnsubscribe,
    required this.onMute,
    required this.onReport,
  });

  static void show(
    BuildContext context, 
    LayerLink layerLink, {
    required VoidCallback onUnsubscribe,
    required VoidCallback onMute,
    required VoidCallback onReport,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PostOptionsMenu',
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
                offset: const Offset(0, 10),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {}, // Prevent dismissal when clicking the menu itself
                    child: PostOptionsMenu(
                      onUnsubscribe: onUnsubscribe,
                      onMute: onMute,
                      onReport: onReport,
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
      width: 209,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item 1: Отписаться
          _buildItem(
            text: 'Отписаться',
            icon: Icons.person_remove_outlined,
            isTop: true,
            onTap: () {
              Navigator.pop(context);
              onUnsubscribe();
            },
          ),
          
          // Dividers
          _buildDivider(),
          _buildDivider(),

          // Item 2: Выкл. уведомления
          _buildItem(
            text: 'Выкл. уведомления',
            icon: Icons.notifications_off_outlined,
            onTap: () {
              Navigator.pop(context);
              onMute();
            },
          ),

          // Divider
          _buildDivider(),

          // Item 3: Пожаловаться
          _buildItem(
            text: 'Пожаловаться',
            icon: Icons.report_gmailerrorred_outlined,
            isBottom: true,
            onTap: () {
              Navigator.pop(context);
              onReport();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String text,
    required IconData icon,
    bool isTop = false,
    bool isBottom = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 209,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        clipBehavior: Clip.antiAlias,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            strokeAlign: BorderSide.strokeAlignCenter,
            color: Color(0xFFC6C6C6),
          ),
        ),
      ),
    );
  }
}
