import 'package:flutter/material.dart';
import 'package:pro_network/screens/registration/photo_screen.dart';
import 'package:pro_network/widgets/address_selector_sheet.dart';
import 'package:pro_network/widgets/app_text_field.dart';

class CityScreen extends StatefulWidget {
  final Map<String, String> profileData;
  const CityScreen({super.key, required this.profileData});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  final _cityController = TextEditingController();

  void _next() {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите город')));
      return;
    }
    final updatedData = Map<String, String>.from(widget.profileData)
      ..['city'] = _cityController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoScreen(profileData: updatedData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 375,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 59),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3135),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2, // step 2 of 5
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF557578),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const Expanded(flex: 3, child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '2/5',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Где Вы живете?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 48), // Match NameScreen gap
                GestureDetector(
                  onTap: () {
                    AddressSelectorSheet.show(
                      context,
                      title: 'Город',
                      initialValue: _cityController.text,
                      onSelected: (val) {
                        setState(() {
                          _cityController.text = val;
                        });
                      },
                    );
                  },
                  child: AppTextField(
                    controller: _cityController,
                    hintText: 'Введите название города',
                    enabled: false,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    height: 35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334D50),
                      border: Border.all(color: const Color(0xFF557578), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Далее',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
