import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/story_model.dart';
import '../services/story_service.dart';
import '../services/user_service.dart';

class StoryViewScreen extends StatefulWidget {
  final List<Story> stories;
  final String userName;

  const StoryViewScreen({
    super.key,
    required this.stories,
    required this.userName,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with SingleTickerProviderStateMixin {
  final StoryService _storyService = StoryService();
  final UserService _userService = UserService();
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  Map<String, dynamic>? _authorData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Инициализация анимации для прогресс-бара (15 секунд)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _loadAuthorData();
    _markCurrentStoryAsViewed();
    _animationController.forward();
  }

  Future<void> _loadAuthorData() async {
    final uid = widget.stories[_currentIndex].userId;
    final data = await _userService.getUserData(uid);
    if (mounted) {
      setState(() {
        _authorData = data;
      });
    }
  }

  void _markCurrentStoryAsViewed() {
    final currentStory = widget.stories[_currentIndex];
    _storyService.markAsViewed(currentStory.id);
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(dt.year, dt.month, dt.day);
    
    final timeStr = DateFormat('HH:mm').format(dt);
    if (dateToCheck == today) {
      return 'сегодня в $timeStr';
    } else {
      return '${DateFormat('dd.MM').format(dt)} в $timeStr';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          // Логика тапов
          onTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < screenWidth * 0.3) {
              _previousStory();
            } else {
              _nextStory();
            }
          },
          // Пауза при удержании
          onLongPressStart: (_) => _animationController.stop(),
          onLongPressEnd: (_) => _animationController.forward(),
          child: Stack(
            children: [
              // 1. Status Bar
              Positioned(
                left: 0, top: 0, right: 0,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('9:41', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          const Icon(Icons.signal_cellular_alt, color: Colors.white, size: 18),
                          const SizedBox(width: 5),
                          const Icon(Icons.wifi, color: Colors.white, size: 18),
                          const SizedBox(width: 5),
                          Transform.rotate(angle: 1.57 * 2, child: const Icon(Icons.battery_full, color: Colors.white, size: 20)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // 2. MAIN STORY AREA (Page View)
              Positioned(
                left: 10,
                top: 50,
                right: 10,
                bottom: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Отключаем стандартный свайп для управления тапами
                    itemCount: widget.stories.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                      _loadAuthorData();
                      _markCurrentStoryAsViewed();
                      _animationController.reset();
                      _animationController.forward();
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.stories[index].imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(color: Colors.orange));
                        },
                      );
                    },
                  ),
                ),
              ),

              // 3. ANIMATED PROGRESS INDICATORS
              Positioned(
                left: 20,
                top: 65,
                right: 20,
                child: Row(
                  children: List.generate(widget.stories.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF557578),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                double widthFactor = 0.0;
                                if (index < _currentIndex) {
                                  widthFactor = 1.0;
                                } else if (index == _currentIndex) {
                                  widthFactor = _animationController.value;
                                }
                                
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: constraints.maxWidth * widthFactor,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF97B0B2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 4. USER INFO HEADER
              Positioned(
                left: 25,
                top: 85,
                right: 20,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: (_authorData?['photoUrl']?.isNotEmpty == true)
                              ? NetworkImage(_authorData!['photoUrl'])
                              : const NetworkImage("https://ui-avatars.com/api/?name=User&size=50"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _authorData?['displayName'] ?? widget.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            _formatDateTime(widget.stories[_currentIndex].createdAt),
                            style: const TextStyle(
                              color: Color(0xFFFF8E30),
                              fontSize: 11,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 5. BOTTOM REPLY AREA
              Positioned(
                left: 10,
                right: 10,
                bottom: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C3135),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF557578), width: 1),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Ответить сообщением',
                              style: TextStyle(color: Color(0xFF557578), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.favorite_border, color: Colors.white, size: 25),
                    const SizedBox(width: 15),
                    const Icon(Icons.send_outlined, color: Colors.white, size: 25),
                    const SizedBox(width: 5),
                  ],
                ),
              ),

              // 6. BOTTOM INDICATOR
              Positioned(
                left: 0, right: 0, bottom: 10,
                child: Center(
                  child: Container(
                    width: 139, height: 5,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
