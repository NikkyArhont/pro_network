import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pro_network/services/business_card_service.dart';
import 'package:pro_network/screens/create_card_screen.dart';
import 'package:pro_network/screens/view_card_screen.dart';
import 'package:pro_network/screens/edit_card_screen.dart';
import 'package:pro_network/models/business_card_draft.dart';

class CardManagementScreen extends StatefulWidget {
  const CardManagementScreen({super.key});

  @override
  State<CardManagementScreen> createState() => _CardManagementScreenState();
}

class _CardManagementScreenState extends State<CardManagementScreen> {
  final BusinessCardService _cardService = BusinessCardService();
  late Future<List<Map<String, dynamic>>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    setState(() {
      _cardsFuture = _cardService.getMyCards();
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is Timestamp) {
      final dateTime = date.toDate();
      return DateFormat('dd.02.yyyy').format(dateTime); // Using .02. as in your design mock, or actual month
    }
    return '';
  }

  // Actual date formatting for production
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

  Future<void> _activateCard(String cardId) async {
    final success = await _cardService.activateCard(cardId);
    if (success) {
      _loadCards();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Визитка успешно активирована на 30 дней!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _cardsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30)));
                      }
                      
                      if (snapshot.hasError) {
                        return Center(child: Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                      }

                      final cards = snapshot.data ?? [];
                      
                      if (cards.isEmpty) {
                        return const Center(
                          child: Text(
                            'У вас пока нет визиток',
                            style: TextStyle(color: Color(0xFF637B7E), fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          return _buildCardItem(cards[index]);
                        },
                      );
                    },
                  ),
                ),
                _buildAddButton(),
              ],
            ),
          ),
          // Bottom home indicator mock
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 21,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Container(
                  width: 139,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Text(
              'Управление визитками',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.50,
                letterSpacing: 0.15,
              ),
            ),
          ),
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card) {
    final bool isActive = card['isActive'] ?? false;
    final String cardId = card['id'] ?? '';
    final String photoUrl = card['photoUrl'] ?? '';
    final String name = card['name'] ?? 'Без имени';
    // Split name into first and last if needed, or use as is
    final List<String> names = name.split(' ');
    final String firstName = names.isNotEmpty ? names[0] : '';
    final String lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
    
    final String position = card['position'] ?? '';
    final String company = card['company'] ?? '';
    final String category = card['category'] ?? '';
    final String direction = card['activityDirection'] ?? '';

    return GestureDetector(
      onTap: () {
        final draft = BusinessCardDraft.fromMap(card);
        print('DEBUG: Opening ViewCardScreen with cardId: $cardId');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewCardScreen(card: draft, cardId: cardId),
          ),
        ).then((_) => _loadCards());
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: const Color(0xFF0C3135),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : const NetworkImage("https://placehold.co/70x70"),
                      fit: BoxFit.cover,
                    ),
                    shape: const OvalBorder(),
                  ),
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            firstName,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400, height: 1.33),
                          ),
                          // Small Edit icon placeholder as in design
                          GestureDetector(
                            onTap: () {
                              final draft = BusinessCardDraft.fromMap(card);
                              print('DEBUG: Opening EditCardScreen from List with cardId: $cardId');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditCardScreen(card: draft, cardId: cardId),
                                ),
                              ).then((_) => _loadCards());
                            },
                            child: Container(
                              width: 25, height: 25,
                              padding: const EdgeInsets.all(4),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 1, color: Colors.white),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Icon(Icons.edit, size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        lastName,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400, height: 1.33),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.business_center_outlined, size: 12, color: Color(0xFFC6C6C6)),
                          const SizedBox(width: 5),
                          Text(
                            '$position $company',
                            style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12, height: 1.33),
                          ),
                        ],
                      ),
                      Text(
                        '$category • $direction',
                        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12, height: 1.33),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            if (isActive)
              Text(
                'Активна до ${_formatActualDate(card['activeUntil'])}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.10,
                ),
              )
            else
              GestureDetector(
                onTap: () => _activateCard(cardId),
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
                  child: const Text(
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
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCardScreen()),
          );
          _loadCards();
        },
        child: Container(
          width: double.infinity,
          height: 35,
          decoration: ShapeDecoration(
            color: const Color(0xFF334D50),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFF557578)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Добавить визитку',
                style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 0.10),
              ),
              const SizedBox(width: 10),
              Container(
                width: 17, height: 17,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF8E30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
