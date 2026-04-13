import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Введите специалиста или услугу',
                            hintStyle: TextStyle(color: Color(0xFF637B7E), fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Filters Horizontal List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterBadge('1-й', isActive: false),
                      _buildFilterBadge('2-й', isActive: true),
                      _buildFilterBadge('3-й', isActive: false),
                      _buildFilterBadge('Теги', isActive: true),
                      _buildFilterBadge('Тип профиля', isActive: false),
                      _buildFilterBadge('Москва', isActive: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Search Results
                _buildSearchResultCard(
                  name: 'Елена Дубровская',
                  photoUrl: 'https://ui-avatars.com/api/?name=Elena+Dubrovskaya&size=70',
                  status: 'Самозанятый (-ая)',
                  role: 'Дизайнер',
                  tags: 'Дизайн • UX/UI',
                  city: 'Москва',
                  recommendationText: 'Рекомендую',
                ),
                const SizedBox(height: 10),
                _buildSearchResultCard(
                  name: 'Анастасия Нагайнова',
                  photoUrl: 'https://ui-avatars.com/api/?name=Anastasia+Nagainova&size=70',
                  status: 'Самозанятый (-ая)',
                  role: 'Дизайнер',
                  tags: 'Дизайн • UX/UI',
                  city: 'Москва',
                  recommendationText: 'Рекомендуют Твои Друзья',
                ),
                const SizedBox(height: 10),
                _buildSearchResultCard(
                  name: 'Елена Дубровская',
                  photoUrl: 'https://ui-avatars.com/api/?name=Elena+Dubrovskaya+2&size=70',
                  status: 'Самозанятый (-ая)',
                  role: 'Дизайнер',
                  tags: 'Дизайн • UX/UI',
                  city: 'Москва',
                  recommendationText: 'Рекомендуют Друзья Друзей',
                ),
                
                const SizedBox(height: 100), // Spacing for bottom menu
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBadge(String title, {required bool isActive}) {
    return Container(
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
    );
  }

  Widget _buildSearchResultCard({
    required String name,
    required String photoUrl,
    required String status,
    required String role,
    required String tags,
    required String city,
    required String recommendationText,
  }) {
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
              // Avatar with online status Stack
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // If we need the small orange dot from the design
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
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.share, color: Color(0xFF557578), size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$status • $role',
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tags,
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      city,
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                    ),
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
