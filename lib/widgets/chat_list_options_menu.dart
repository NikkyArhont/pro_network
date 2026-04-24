import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatListOptionsMenu {
  static void show(
    BuildContext context, 
    Offset tapPosition, {
    required ChatModel chat,
    required String currentUserId,
    required VoidCallback onPin,
    required VoidCallback onMute,
    required VoidCallback onMarkNew,
    required VoidCallback onClear,
    required VoidCallback onDelete,
  }) {
    final bool isPinned = chat.isPinnedByUser(currentUserId);
    final bool isMarkedUnread = chat.isMarkedUnreadByUser(currentUserId);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ChatListOptionsMenu',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: tapPosition.dx,
              top: tapPosition.dy,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {}, // Prevent dismissal when clicking menu
                  child: Container(
                    width: 261,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: [
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
                          isPinned ? 'Открепить' : 'Закрепить',
                          icon: Icons.push_pin_outlined,
                          isFirst: true,
                          onTap: onPin,
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          'Выкл. уведомления',
                          icon: Icons.notifications_off_outlined,
                          onTap: onMute,
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          isMarkedUnread ? 'Пометить как прочит.' : 'Пометить как новое',
                          isNewMark: true,
                          onTap: onMarkNew,
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          'Очистить',
                          icon: Icons.cleaning_services_outlined,
                          onTap: onClear,
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          'Удалить',
                          icon: Icons.delete_outline,
                          isLast: true,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildMenuItem(
    BuildContext context, 
    String title, {
    IconData? icon, 
    bool isFirst = false, 
    bool isLast = false,
    bool isNewMark = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) onTap();
      },
      child: Container(
        width: 261,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            Container(
              width: 25,
              height: 25,
              child: isNewMark 
                ? Stack(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFF8E30),
                            shape: OvalBorder(
                              side: BorderSide(
                                width: 1.50,
                                color: const Color(0xFF334D50), // Цвет фона меню для эффекта выреза
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : (icon != null ? Icon(icon, color: Colors.white, size: 20) : null),
            ),
            const SizedBox(width: 10),
            Text(
              title,
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

  static Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: const Color(0xFFC6C6C6).withOpacity(0.5),
    );
  }
}
