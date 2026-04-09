import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_network/screens/auth_choice_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0C3135),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF557578), width: 1),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Вы уверены что хотите выйти?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF557578)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Нет',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF334D50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Выйти',
                            style: TextStyle(
                              color: Color(0xFFFF8E30),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Profile Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 125,
                        height: 125,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF283F41),
                          shape: OvalBorder(),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, size: 80, color: Color(0xFF557578)),
                        ),
                      ),
                      const SizedBox(height: 27),
                      const Text(
                        'Константин Константинопольский',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.business_center_outlined, size: 15, color: Color(0xFFC6C6C6)),
                          const SizedBox(width: 5),
                          const Text(
                            'Генеральный директор в Арматурис',
                            style: TextStyle(
                              color: Color(0xFFC6C6C6),
                              fontSize: 15,
                              height: 1.33,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Страхование • КАСКО',
                        style: TextStyle(
                          color: Color(0xFFC6C6C6),
                          fontSize: 15,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),

                // Settings Items
                _buildSettingsItem(Icons.notifications_none, 'Уведомления'),
                _buildSettingsItem(Icons.info_outline, 'Информация о себе'),
                _buildSettingsItem(Icons.badge_outlined, 'Управление визитками'),
                _buildSettingsItem(Icons.subscriptions_outlined, 'Подписка'),
                _buildSettingsItem(Icons.security_outlined, 'Приватность и безопасность'),
                _buildSettingsItem(Icons.report_problem_outlined, 'Сообщить о проблеме'),
                
                const SizedBox(height: 30),

                // Logout Button
                GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    width: double.infinity,
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFF557578)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Выйти из профиля',
                      style: TextStyle(
                        color: Color(0xFF557578),
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 120), // Bottom padding for menu
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return Container(
      width: double.infinity,
      height: 35,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: ShapeDecoration(
        color: const Color(0xFF334D50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const Icon(Icons.chevron_right, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}
