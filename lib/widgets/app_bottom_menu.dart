import 'package:flutter/material.dart';

class AppBottomMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomMenu({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345, // Adjusted to fit 6 items with 12px spacing safely
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.40),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFC6C6C6),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 10,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildItem(0, 'Главная', Icons.home_outlined),
          const SizedBox(width: 12),
          _buildItem(1, 'Окружение', Icons.people_outline),
          const SizedBox(width: 12),
          _buildItem(2, 'Чаты', Icons.chat_bubble_outline),
          const SizedBox(width: 12),
          _buildItem(3, 'Поиск', Icons.search_outlined),
          const SizedBox(width: 12),
          _buildItem(4, 'Визитка', Icons.badge_outlined),
          const SizedBox(width: 12),
          _buildItem(5, 'Настройки', Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildItem(int index, String label, IconData iconData) {
    final isSelected = currentIndex == index;
    final activeColor = const Color(0xFFFF8E30);
    final inactiveColor = const Color(0xFFC6C6C6);
    final color = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44, 
        height: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
