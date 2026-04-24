import 'package:flutter/material.dart';

class ChatOptionsMenu {
  static void show(BuildContext context, LayerLink layerLink, {
    required VoidCallback onImagePick,
    required VoidCallback onFilePick,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ChatOptionsMenu',
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
                targetAnchor: Alignment.topLeft,
                followerAnchor: Alignment.bottomLeft,
                offset: const Offset(0, -10), // Just above the icon
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {}, // Prevent dismissal when clicking the menu itself
                    child: Container(
                      width: 208,
                      decoration: const BoxDecoration(
                        boxShadow: [
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
                          _buildMenuItem(
                            context,
                            'Фотография',
                            icon: Icons.image_outlined,
                            isFirst: true,
                            onTap: onImagePick,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            'Документ / Файл',
                            icon: Icons.file_present_outlined,
                            isLast: true,
                            onTap: onFilePick,
                          ),
                        ],
                      ),
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

  static Widget _buildMenuItem(
    BuildContext context, 
    String title, {
    required IconData icon, 
    bool isFirst = false, 
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) onTap();
      },
      child: Container(
        width: 208,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: ShapeDecoration(
          color: const Color(0xFF334D50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(10) : Radius.zero,
              topRight: isFirst ? const Radius.circular(10) : Radius.zero,
              bottomLeft: isLast ? const Radius.circular(10) : Radius.zero,
              bottomRight: isLast ? const Radius.circular(10) : Radius.zero,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: const Color(0xFFC6C6C6).withOpacity(0.5),
    );
  }
}
