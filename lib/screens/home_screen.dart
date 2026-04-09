import 'package:flutter/material.dart';
import 'package:pro_network/screens/feed_screen.dart';
import 'package:pro_network/screens/search_screen.dart';
import 'package:pro_network/screens/chats_screen.dart';
import 'package:pro_network/screens/contacts_screen.dart';
import 'package:pro_network/screens/profile_screen.dart';
import 'package:pro_network/screens/settings_screen.dart';
import 'package:pro_network/screens/create_card_screen.dart';
import 'package:pro_network/widgets/app_bottom_menu.dart';
import 'package:pro_network/widgets/business_card_dialog.dart';
import 'package:pro_network/screens/view_card_screen.dart';
import 'package:pro_network/models/business_card_draft.dart';
import 'package:pro_network/services/business_card_service.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }
  final BusinessCardService _cardService = BusinessCardService();
  bool _isCardDialogOpen = false;

  final List<Widget> _screens = const [
    FeedScreen(),       // 0: Главная
    ContactsScreen(),   // 1: Окружение
    ChatsScreen(),      // 2: Чаты
    SearchScreen(),     // 3: Поиск
    ProfileScreen(),    // 4: Визитка (Profile for now)
    SettingsScreen(),   // 5: Настройки
  ];

  void _showCardDialog() async {
    setState(() {
      _isCardDialogOpen = true;
    });
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              bottom: 100, // Above the menu
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 170), // Aligned with 'Визитка' item
                  child: BusinessCardDialog(
                    cardsFuture: _cardService.getMyCards(),
                    onAddTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateCardScreen()),
                      );
                    },
                    onCardTap: (cardData) {
                      Navigator.pop(context);
                      final draft = BusinessCardDraft.fromMap(cardData);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewCardScreen(card: draft),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );

    if (mounted) {
      setState(() {
        _isCardDialogOpen = false;
      });
    }
  }

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
                isCardActive: _isCardDialogOpen,
                onTap: (index) {
                  if (index == 4) {
                    _showCardDialog();
                  } else {
                    setState(() {
                      _currentIndex = index;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

