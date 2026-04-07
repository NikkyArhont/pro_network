import 'package:flutter/material.dart';
import 'package:pro_network/services/app_start_service.dart';
import 'package:pro_network/screens/auth_choice_screen.dart';
import 'package:pro_network/utils/app_assets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Профессиональные связи',
      'subtitle': 'Создай свое сильное окружение',
      'image': AppAssets.onboarding1,
    },
    {
      'title': 'Находи нужных специалистов',
      'subtitle': 'Выбирай тех, кого рекомендуют твои друзья',
      'image': AppAssets.onboarding2,
    },
    {
      'title': 'Рекомендуй лучших',
      'subtitle': 'Рекомендуй своим друзьям проверенных специалистов',
      'image': AppAssets.onboarding3,
    },
    {
      'title': 'Добавь свою визитку',
      'subtitle': 'Расскажи всем о своей деятельности и получай новых клиентов по рекомендациям',
      'image': AppAssets.onboarding4,
    },
    {
      'title': 'Общение с близкими',
      'subtitle': 'Личное общение и полезные контакты теперь в одном месте',
      'image': AppAssets.onboarding5,
    },
  ];

  void _completeOnboarding() async {
    await AppStartService().completeOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
    );
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Widget _buildSlide(int index) {
    return Stack(
      children: [
        // Image Placeholder covering top portion
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Image.asset(
            _pages[index]['image']!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF0C3135),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Color(0xFF557578),
                    size: 80,
                  ),
                ),
              );
            },
          ),
        ),
        
        // Bottom Gradient
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFF01191B),
                ],
              ),
            ),
          ),
        ),

        // Text Content
        Positioned(
          left: 24,
          right: 24,
          bottom: 140, // Space for progress bar and button
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _pages[index]['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _pages[index]['subtitle']!,
                style: const TextStyle(
                  color: Color(0xFF637B7E), // Muted text
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return _buildSlide(index);
            },
          ),
          
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(
                              right: index < _pages.length - 1 ? 8 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: _currentIndex == index 
                                  ? const Color(0xFF557578) 
                                  : const Color(0xFF0C3135),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    
                    // Button
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        height: 48, // slightly larger standard button height
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334D50),
                          border: Border.all(color: const Color(0xFF557578), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _currentIndex == _pages.length - 1 ? 'Начать' : 'Далее',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
