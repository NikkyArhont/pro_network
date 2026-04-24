import 'package:flutter/material.dart';

class ChatUserOptionsMenu {
  static void show(BuildContext context, GlobalKey menuKey, {
    required VoidCallback onDelete,
  }) {
    final RenderBox? renderBox = menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx - 200, 
      offset.dy + renderBox.size.height,
      offset.dx + renderBox.size.width,
      offset.dy,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ChatUserOptionsMenu',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx - 180,
                top: offset.dy + renderBox.size.height + 5,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {},
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
                          // 1. Добавить в связи
                          _buildMenuItem(
                            context,
                            'Добавить в связи',
                            icon: Icons.person_add_outlined,
                            isFirst: true,
                          ),
                          _buildDivider(),
                          // 2. Поиск по чату
                          _buildMenuItem(
                            context,
                            'Поиск по чату',
                            icon: Icons.search,
                          ),
                          _buildDivider(),
                          // 3. Выкл. уведомления
                          _buildMenuItem(
                            context,
                            'Выкл. уведомления',
                            icon: Icons.notifications_off_outlined,
                          ),
                          _buildDivider(),
                          // 4. Пожаловаться
                          _buildMenuItem(
                            context,
                            'Пожаловаться',
                            icon: Icons.info_outline,
                          ),
                          _buildDivider(),
                          // 5. Заблокировать
                          _buildMenuItem(
                            context,
                            'Заблокировать',
                            icon: Icons.block,
                          ),
                          _buildDivider(),
                          // 6. Удалить чат
                          _buildMenuItem(
                            context,
                            'Удалить чат',
                            icon: Icons.delete_outline,
                            isLast: true,
                            textColor: const Color(0xFFFF8E30),
                            onTap: onDelete,
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
    Color textColor = Colors.white,
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
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
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
