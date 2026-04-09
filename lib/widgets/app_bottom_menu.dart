import 'package:flutter/material.dart';

class AppBottomMenu extends StatelessWidget {
  final int currentIndex;
  final bool isCardActive;
  final Function(int) onTap;

  const AppBottomMenu({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isCardActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370, // Increased to fit 6 wider items
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
          const SizedBox(width: 8),
          _buildItem(1, 'Окружение', Icons.people_outline),
          const SizedBox(width: 8),
          _buildItem(2, 'Чаты', Icons.chat_bubble_outline),
          const SizedBox(width: 8),
          _buildItem(3, 'Поиск', Icons.search_outlined),
          const SizedBox(width: 8),
          _buildItem(4, 'Визитка', Icons.badge_outlined),
          const SizedBox(width: 8),
          _buildItem(5, 'Настройки', Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildItem(int index, String label, IconData iconData) {
    bool isSelected = currentIndex == index;
    if (index == 4 && isCardActive) {
      isSelected = true;
    }
    const activeColor = Color(0xFFFF8E30);
    const inactiveColor = Color(0xFFC6C6C6);
    final color = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52, // Increased from 44 to prevent wrapping
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
                fontSize: 9, // Increased from 8
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}
