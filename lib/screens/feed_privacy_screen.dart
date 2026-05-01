import 'package:flutter/material.dart';

class FeedPrivacyScreen extends StatefulWidget {
  final String currentOption;
  final Function(String) onOptionSelected;

  const FeedPrivacyScreen({
    super.key,
    required this.currentOption,
    required this.onOptionSelected,
  });

  @override
  State<FeedPrivacyScreen> createState() => _FeedPrivacyScreenState();
}

class _FeedPrivacyScreenState extends State<FeedPrivacyScreen> {
  late String _selectedOption;

  final List<String> _options = [
    'Только мои связи',
    'Только я',
    'Некоторые мои связи',
  ];

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentOption;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: Stack(
        children: [
          // Header
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Opacity(
                        opacity: 0.35,
                        child: Container(
                          width: 25,
                          height: 13,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(4.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 21,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Title
          Positioned(
            left: 10,
            top: 59,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Кто видит мою ленту',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                      letterSpacing: 0.15,
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
            ),
          ),

          // Content
          Positioned(
            left: 10,
            top: 108,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: Column(
                children: [
                  // Options Container
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C3135),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_options.length, (index) {
                        final option = _options[index];
                        final isSelected = option == _selectedOption;
                        final isFirst = index == 0;
                        final isLast = index == _options.length - 1;

                        return Column(
                          children: [
                            if (index > 0)
                              Container(
                                height: 1,
                                color: const Color(0xFFABABAB).withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                            GestureDetector(
                              onTap: () {
                                setState(() => _selectedOption = option);
                                widget.onOptionSelected(option);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                height: 37,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.vertical(
                                    top: isFirst ? const Radius.circular(10) : Radius.zero,
                                    bottom: isLast ? const Radius.circular(10) : Radius.zero,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      option,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFFF8E30),
                                          width: 1,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 9,
                                                height: 9,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFFF8E30),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Add Access Section
                  Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334D50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Доступ к ленте',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement add access logic
                          },
                          child: const Text(
                            'Добавить',
                            style: TextStyle(
                              color: Color(0xFFFF8E30),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Indicator
          Positioned(
            left: 0,
            bottom: 8,
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Container(
                width: 139,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
