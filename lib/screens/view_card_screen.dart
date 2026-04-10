import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pro_network/models/business_card_draft.dart';
import 'package:pro_network/widgets/card_contacts_sheet.dart';
import 'package:pro_network/widgets/card_price_sheet.dart';
import 'package:pro_network/widgets/app_bottom_menu.dart';
import 'package:pro_network/widgets/business_card_dialog.dart';
import 'package:pro_network/screens/create_card_screen.dart';
import 'package:pro_network/screens/home_screen.dart';
import 'package:pro_network/screens/edit_card_screen.dart';
import 'package:pro_network/services/business_card_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewCardScreen extends StatefulWidget {
  final BusinessCardDraft card;
  final String? cardId; // If we need to perform actions

  const ViewCardScreen({super.key, required this.card, this.cardId});

  @override
  State<ViewCardScreen> createState() => _ViewCardScreenState();
}

class _ViewCardScreenState extends State<ViewCardScreen> {
  int _activeTab = 0; // 0: Description, 1: Contacts, 2: Price
  int _newsTab = 0; // 0: News, 1: Proposals
  final BusinessCardService _cardService = BusinessCardService();
  bool _isCardDialogOpen = false;
  bool _isActivating = false;
  late BusinessCardDraft _currentCard;

  @override
  void initState() {
    super.initState();
    print('DEBUG: ViewCardScreen initialized with cardId: ${widget.cardId}');
    _currentCard = widget.card;
  }

  Future<void> _refreshCard() async {
    if (widget.cardId == null) return;
    
    // In a real app, we'd fetch the specific document by ID.
    // For now, let's just reload all cards and find this one, or assume we'll update it.
    final cards = await _cardService.getMyCards();
    final updatedCardMap = cards.firstWhere((c) => c['id'] == widget.cardId, orElse: () => {});
    
    if (updatedCardMap.isNotEmpty) {
      setState(() {
        _currentCard = BusinessCardDraft.fromMap(updatedCardMap);
      });
    }
  }

  Future<void> _activateCard() async {
    if (widget.cardId == null) return;
    
    setState(() => _isActivating = true);
    final success = await _cardService.activateCard(widget.cardId!);
    
    if (mounted) {
      if (success) {
        setState(() {
          _currentCard.isActive = true;
          // Set to 30 days from now for immediate UI update
          _currentCard.activeUntil = Timestamp.fromDate(DateTime.now().add(const Duration(days: 30)));
          _isActivating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Визитка успешно активирована на 30 дней!')),
        );
      } else {
        setState(() => _isActivating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при активации.')),
        );
      }
    }
  }

  String _formatActualDate(dynamic date) {
    if (date == null) return '';
    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return '';
    }
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

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
                        final cardId = cardData['id'] ?? '';
                        print('DEBUG: Switching to cardId: $cardId from dialog');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewCardScreen(card: draft, cardId: cardId),
                          ),
                        ).then((_) => _refreshCard());
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

  void _showContacts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardContactsSheet(card: widget.card),
    );
  }

  void _showPrice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardPriceSheet(card: widget.card),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: Column(
          children: [
            // Top Status Bar Area Placeholder (if needed, but usually SafeArea handles it)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                children: [
                  _buildUserHeader(),
                  const SizedBox(height: 15),
                  _buildTabsAndDescription(),
                  const SizedBox(height: 15),
                  _buildNewsAndGrid(),
                ],
              ),
            ),
            // Floating Bottom Menu
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: AppBottomMenu(
                  currentIndex: -1, // No tab selected on this screen
                  isCardActive: _isCardDialogOpen,
                  onTap: (index) {
                    if (index == 4) {
                      _showCardDialog();
                    } else {
                      // Navigate back to Home and switch to the selected tab
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(initialIndex: index),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: (widget.card.photoFile != null)
                        ? (kIsWeb 
                            ? NetworkImage(widget.card.photoFile!.path) 
                            : FileImage(File(widget.card.photoFile!.path)) as ImageProvider)
                        : const NetworkImage("https://placehold.co/70x70"),
                    fit: BoxFit.cover,
                  ),
                  shape: const OvalBorder(),
                ),
              ),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.card.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // Icons
                        const Row(
                          spacing: 15,
                          children: [
                            Icon(Icons.share, color: Colors.white, size: 20),
                            Icon(Icons.more_horiz, color: Colors.white, size: 20),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Константинопольский', // Placeholder for surname if not in model, or just use name
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      spacing: 5,
                      children: [
                        const Icon(Icons.business_center, color: Color(0xFFC6C6C6), size: 12),
                        Text(
                          widget.card.position,
                          style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                        ),
                        Text(
                          widget.card.company,
                          style: const TextStyle(
                            color: Color(0xFFC6C6C6),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${widget.card.category} • ${widget.card.activityDirection}',
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Activate Button or Expiry Date
          Center(
            child: widget.card.isActive 
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Активна до ${_formatActualDate(widget.card.activeUntil)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.10,
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _isActivating || widget.cardId == null ? null : _activateCard,
                  child: Container(
                    width: 230,
                    height: 35,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF334D50),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 2, color: Color(0xFFFF8E30)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _isActivating 
                      ? const SizedBox(
                          width: 20, height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text(
                          'Активировать',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.10,
                          ),
                        ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // Tabs
          Row(
            spacing: 15,
            children: [
              _buildTabText('Описание', 0, onTap: () => setState(() => _activeTab = 0)),
              _buildTabText('Контакты', 1, onTap: _showContacts),
              _buildTabText('Прайс', 2, onTap: _showPrice),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  print('DEBUG: Opening EditCardScreen from ViewCardScreen with cardId: ${widget.cardId}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCardScreen(
                        card: _currentCard ?? widget.card,
                        cardId: widget.cardId,
                      ),
                    ),
                  ).then((_) => _refreshCard());
                },
                child: const Icon(Icons.edit_note, color: Colors.white, size: 20),
              ),
            ],
          ),
          // Description Text
          Text(
            _currentCard.description,
            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.33),
          ),
          // Tags
          Wrap(
            spacing: 10,
            runSpacing: 5,
            children: _currentCard.tags.map((tag) => _buildTag(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabText(String text, int index, {VoidCallback? onTap}) {
    final bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: isActive ? const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
        ) : null,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFC6C6C6),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFC6C6C6)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
      ),
    );
  }

  Widget _buildNewsAndGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        // Sub-tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 15,
              children: [
                _buildSubTabText('Новости', 0),
                _buildSubTabText('Предложения', 1),
              ],
            ),
            // Add Button
            Row(
              spacing: 5,
              children: [
                const Text('Добавить', style: TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
                Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8E30),
                    borderRadius: BorderRadius.circular(8.5),
                  ),
                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: 9, // Placeholder count
          itemBuilder: (context, index) {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://placehold.co/115x115"),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubTabText(String text, int index) {
    final bool isActive = _newsTab == index;
    return GestureDetector(
      onTap: () => setState(() => _newsTab = index),
      child: Container(
        height: 25,
        decoration: isActive ? const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
        ) : null,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFC6C6C6),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
