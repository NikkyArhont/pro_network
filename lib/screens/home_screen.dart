import 'package:flutter/material.dart';
import 'package:pro_network/screens/feed_screen.dart';
import 'package:pro_network/screens/search_screen.dart';
import 'package:pro_network/screens/chats_screen.dart';
import 'package:pro_network/screens/contacts_screen.dart';
import 'package:pro_network/screens/profile_screen.dart';
import 'package:pro_network/screens/settings_screen.dart';
import 'package:pro_network/widgets/app_bottom_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),       // 0: Главная
    ContactsScreen(),   // 1: Окружение
    ChatsScreen(),      // 2: Чаты
    SearchScreen(),     // 3: Поиск
    ProfileScreen(),    // 4: Визитка (Profile for now)
    SettingsScreen(),   // 5: Настройки
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: Stack(
        children: [
          // Screen content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // Floating Bottom Menu
          Positioned(
            left: 0,
            right: 0,
            bottom: 24, // Space from bottom of screen
            child: Center(
              child: AppBottomMenu(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

