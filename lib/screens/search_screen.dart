import 'package:flutter/material.dart';
import 'package:pro_network/widgets/tag_selector_sheet.dart';
import 'package:pro_network/widgets/profile_type_selector_sheet.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/services/business_card_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                          onChanged: _onSearchChanged,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Введите специалиста или услугу',
                            hintStyle: TextStyle(color: Color(0xFF637B7E), fontSize: 14),
                            border: InputBorder.none,
                            filled: false,
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
    
    final String rawName = isCard ? (data['name']?.toString() ?? '') : (data['displayName']?.toString() ?? 'Без имени');
    final String name = rawName.isEmpty ? 'Без имени' : rawName;
    final String photoUrl = data['photoUrl']?.toString() ?? '';
    final String city = data['city']?.toString() ?? '';
    final String role = isCard ? (data['position']?.toString() ?? '') : (data['status']?.toString() ?? 'Пользователь');
    final String company = isCard ? (data['company']?.toString() ?? '') : '';
    
    String tags = '';
    if (isCard && data['tags'] != null) {
      try {
        tags = (List<dynamic>.from(data['tags'])).map((e) => e.toString()).join(' • ');
      } catch (_) {
        tags = '';
      }
    }
    
    final String recommendationText = isCard ? 'Рекомендую' : 'Профиль специалиста';

    final String avatarUrl = photoUrl.isNotEmpty 
        ? photoUrl 
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=70&background=283F41&color=fff';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (data['status'] == 'active' || isCard)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8E30),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 15),
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.share, color: Color(0xFF557578), size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCard 
                        ? (company.isNotEmpty ? '$role • $company' : role)
                        : (city.isNotEmpty ? '$role • $city' : role),
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tags,
                        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                      ),
                    ],
                    if (isCard && city.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        city,
                        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Actions Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF557578)),
                  ),
                  child: Center(
                    child: Text(
                      recommendationText.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF334D50),
                        fontSize: 10,
                        fontFamily: 'Russo One',
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildIconButton(Icons.person_add_alt_1),
              const SizedBox(width: 8),
              _buildIconButton(Icons.message_outlined),
              const SizedBox(width: 8),
              _buildIconButton(Icons.phone_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF334D50),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF557578)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
