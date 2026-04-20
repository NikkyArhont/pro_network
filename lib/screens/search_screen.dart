import 'package:flutter/material.dart';
import 'package:pro_network/widgets/tag_selector_sheet.dart';
import 'package:pro_network/widgets/profile_type_selector_sheet.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/services/business_card_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_network/services/chat_service.dart';
import 'package:pro_network/screens/conversation_screen.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  final BusinessCardService _cardService = BusinessCardService();
  
  List<String> _selectedTags = [];
  String _selectedProfileType = 'all';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final Map<String, bool> _chatLoadingStates = {};

  @override
  void initState() {
    super.initState();
    _performSearch(); // Initial search for all
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    
    final query = _searchController.text;
    
    try {
      List<Map<String, dynamic>> users = [];
      List<Map<String, dynamic>> cards = [];

      final List<Future> futures = [];
      
      // Conditionally add futures based on profile type
      if (_selectedProfileType == 'all' || _selectedProfileType == 'user') {
        futures.add(_userService.searchUsers(query, _currentUserId, tags: _selectedTags));
      } else {
        futures.add(Future.value([]));
      }

      if (_selectedProfileType == 'all' || _selectedProfileType == 'card') {
        futures.add(_cardService.searchCards(query: query, currentUserId: _currentUserId, tags: _selectedTags));
      } else {
        futures.add(Future.value([]));
      }

      final results = await Future.wait(futures);

      if (_selectedProfileType == 'all' || _selectedProfileType == 'user') {
        users = (results[0] as List).map((u) {
          return Map<String, dynamic>.from(u)..['searchDisplayType'] = 'user';
        }).toList();
      }
      
      if (_selectedProfileType == 'all' || _selectedProfileType == 'card') {
        // results index changes if we skip users
        final cardsIdx = 1;
        cards = (results[cardsIdx] as List).map((c) {
          return Map<String, dynamic>.from(c)..['searchDisplayType'] = 'card';
        }).toList();
      }

      setState(() {
        _searchResults = [...users, ...cards];
        _isLoading = false;
      });
      print('DEBUG: [SearchScreen] Total results displayed: ${_searchResults.length} (Type: $_selectedProfileType)');
    } catch (e) {
      print('Search error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Field
                Container(
                  width: double.infinity,
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C3135),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF557578), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF637B7E), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _performSearch(),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Поиск контактов',
                            hintStyle: TextStyle(color: Color(0xFF637B7E), fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10, bottom: 12),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Selected Tags Chips
                if (_selectedTags.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _selectedTags.map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildTagChip(tag),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                // Filters Horizontal List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterBadge('1-й', isActive: false),
                      _buildFilterBadge('2-й', isActive: true),
                      _buildFilterBadge('3-й', isActive: false),
                      _buildFilterBadge(
                        'Теги',
                        isActive: _selectedTags.isNotEmpty,
                        onTap: () {
                          TagSelectorSheet.show(
                            context,
                            initialTags: _selectedTags,
                            onSave: (tags) {
                              setState(() {
                                _selectedTags = tags;
                              });
                              _performSearch();
                            },
                          );
                        },
                      ),
                      _buildFilterBadge(
                        'Тип профиля',
                        isActive: _selectedProfileType != 'all',
                        onTap: () {
                          ProfileTypeSelectorSheet.show(
                            context,
                            selectedType: _selectedProfileType,
                            onSelect: (type) {
                              setState(() {
                                _selectedProfileType = type;
                              });
                              _performSearch();
                            },
                          );
                        },
                      ),
                      _buildFilterBadge('Город', isActive: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Search Results
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30)))
                else if (_searchResults.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text(
                        'Ничего не найдено',
                        style: TextStyle(color: Color(0xFF637B7E)),
                      ),
                    ),
                  )
                else
                  ..._searchResults.map((data) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSearchResultCard(data),
                  )),
                
                const SizedBox(height: 100), // Spacing for bottom menu
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBadge(String title, {required bool isActive, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF8E30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(color: Color(0xFFFF8E30), fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTags.remove(tag);
              });
              _performSearch();
            },
            child: const Icon(Icons.close, size: 14, color: Color(0xFFFF8E30)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> data) {
    final bool isCard = data['searchDisplayType'] == 'card';
    final String name = isCard 
        ? (data['name']?.toString() ?? 'Без имени') 
        : (data['displayName']?.toString() ?? 'Без имени');
    final String photoUrl = data['photoUrl']?.toString() ?? '';
    final String city = data['city']?.toString() ?? '';
    final String role = isCard 
        ? (data['position']?.toString() ?? 'Специалист') 
        : (data['status']?.toString() ?? 'Пользователь');
    final String category = isCard ? 'Визитка' : 'Пользователь';
    final String otherUserId = data['uid']?.toString() ?? data['userId']?.toString() ?? '';
    
    String tags = '';
    if (isCard && data['tags'] != null) {
      try {
        tags = (List<dynamic>.from(data['tags'])).map((e) => e.toString()).join(' • ');
      } catch (_) {}
    }

    final String avatarUrl = photoUrl.isNotEmpty 
        ? photoUrl 
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=70&background=283F41&color=fff';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF283F41),
                      image: DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      ),
                      shape: const OvalBorder(),
                    ),
                  ),
                  // This was a status icon placeholder in the snippet
                  if (data['status'] == 'active' || isCard)
                    Transform.translate(
                      offset: const Offset(-15, 0),
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFFF8E30),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.share, color: Color(0xFF557578), size: 18),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 5,
                      children: [
                        const Icon(Icons.person_outline, size: 12, color: Color(0xFFC6C6C6)),
                        Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFFC6C6C6),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(color: Color(0xFFC6C6C6)),
                        ),
                        Expanded(
                          child: Text(
                            role,
                            style: const TextStyle(
                              color: Color(0xFFC6C6C6),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (tags.isNotEmpty)
                      Text(
                        tags,
                        style: const TextStyle(
                          color: Color(0xFFC6C6C6),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (city.isNotEmpty)
                      Text(
                        city,
                        style: const TextStyle(
                          color: Color(0xFFC6C6C6),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(
                child: Container(
                  height: 35,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFF557578),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Рекомендую',
                    style: TextStyle(
                      color: Color(0xFF334D50),
                      fontSize: 12,
                      fontFamily: 'Russo One',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 5,
                children: [
                  _buildActionIcon(Icons.thumb_up_outlined, hasBadge: true),
                  _buildActionIcon(Icons.person_outline, hasBadge: true),
                  _buildActionIcon(
                    Icons.chat_bubble_outline, 
                    hasBadge: false,
                    isLoading: _chatLoadingStates[otherUserId] == true,
                    onTap: () async {
                      if (_currentUserId.isEmpty || otherUserId.isEmpty) return;
                      
                      if (_chatLoadingStates[otherUserId] == true) return;
                      setState(() => _chatLoadingStates[otherUserId] = true);
                      
                      try {
                        final chatId = await ChatService().getOrCreatePersonalChat(_currentUserId, otherUserId);
                        
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversationScreen(
                                chatId: chatId,
                                otherParticipant: data,
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _chatLoadingStates[otherUserId] = false);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, {bool hasBadge = false, VoidCallback? onTap, bool isLoading = false}) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: ShapeDecoration(
          color: const Color(0xFF334D50),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFF557578),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFF8E30),
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 18),
            if (hasBadge && !isLoading)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: const ShapeDecoration(
                  color: Color(0xFFFF8E30),
                  shape: OvalBorder(),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
