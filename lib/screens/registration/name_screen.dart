import 'package:flutter/material.dart';
import 'package:pro_network/widgets/app_text_field.dart';
import 'package:pro_network/screens/registration/city_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  void _next() {
    if (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните оба поля')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CityScreen(
          profileData: {
            'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
          },
        ),
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
                            flex: 1, // step 1 of 5
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF557578),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const Expanded(flex: 4, child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '1/5',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Как Вас зовут?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 48), // Large vertical gap
                AppTextField(
                  controller: _firstNameController,
                  hintText: 'Введите имя',
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: _lastNameController,
                  hintText: 'Введите фамилию',
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

