import 'package:flutter/material.dart';

class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Color(0xFF01191B),
          ),
          child: Stack(
            children: [
              // Content Area
              Padding(
                padding: const EdgeInsets.only(top: 138, left: 10, right: 10, bottom: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Countries Section
                    _buildSection(
                      title: 'Страны',
                      children: [
                        _buildRow('Россия', '11202', Colors.white, Colors.white),
                        _buildDivider(),
                        _buildRow('Казахстан', '2345', const Color(0xFF30C6E0), Colors.white),
                        _buildDivider(),
                        _buildRow('Испания', '131', const Color(0xFFA41517), Colors.white),
                      ],
                      showMore: true,
                    ),
                    const SizedBox(height: 5),
                    // Activity Direction Section
                    _buildSection(
                      title: 'Направление деятельности',
                      children: [
                        _buildActivityRow('Услуги', '11202'),
                        _buildDivider(),
                        _buildActivityRow('Торговля', '2345'),
                        _buildDivider(),
                        _buildActivityRow('Производство', '131'),
                        _buildDivider(),
                        _buildActivityRow('Инвестиции', '131'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Employment Status Section
                    _buildSection(
                      title: 'Статус занятости',
                      children: [
                        _buildSimpleRow('Работает на себя', '131'),
                        _buildDivider(),
                        _buildSimpleRow('В найме', '11202'),
                        _buildDivider(),
                        _buildSimpleRow('Временно не работает', '131'),
                      ],
                      showMore: true,
                    ),
                  ],
                ),
              ),

              // Header
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: Container(
                  height: 130, // Increased to cover status bar and title
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Окружение',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.15,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                '13678',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.15,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(Icons.people_outline, color: Colors.white.withOpacity(0.7), size: 18),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Circles Tabs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleTab('1 круг', '888', true),
                          _buildCircleTab('2 круг', '81345', false),
                          _buildCircleTab('3 круг', '124588', false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children, bool showMore = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.5,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
          if (showMore) ...[
            const SizedBox(height: 15),
            const Text(
              'Еще',
              style: TextStyle(
                color: Color(0xFFABABAB),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String name, String count, Color flagColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 21,
                height: 15,
                decoration: BoxDecoration(
                  color: flagColor,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFF5F5F5), width: 0.5),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          Text(
            count,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String name, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.business_center_outlined, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRow(String name, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: const Color(0xFFABABAB).withOpacity(0.2),
    );
  }

  Widget _buildCircleTab(String title, String count, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radio_button_checked,
            size: 14,
            color: isActive ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: isActive ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: isActive ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
