import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_network/screens/auth_choice_screen.dart';
import 'package:pro_network/screens/profile_edit_screen.dart';
import 'package:pro_network/screens/card_management_screen.dart';
import 'package:pro_network/screens/notification_settings_screen.dart';
import 'package:pro_network/screens/report_problem_screen.dart';
import 'package:pro_network/screens/subscription_screen.dart';
import 'package:pro_network/screens/privacy_security_screen.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final data = await _userService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                        decoration: ShapeDecoration(
                          color: const Color(0xFF283F41),
                          shape: const OvalBorder(),
                          image: _userData?['photoUrl'] != null && _userData!['photoUrl'].toString().isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_userData!['photoUrl']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _userData?['photoUrl'] == null || _userData!['photoUrl'].toString().isEmpty
                            ? const Center(
                                child: Icon(Icons.person, size: 80, color: Color(0xFF557578)),
                              )
                            : null,
                      ),
                      const SizedBox(height: 27),
                      Text(
                        _userData?['displayName'] ?? 'Пользователь',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                          Flexible(
                            child: Text(
                              _userData != null 
                                  ? '${_userData!['position'] ?? ''} в ${_userData!['company'] ?? ''}'.trim()
                                  : 'Должность не указана',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFC6C6C6),
                                fontSize: 15,
                                height: 1.33,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _userData?['category'] ?? 'Категория не указана',
                        style: const TextStyle(
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
                _buildSettingsItem(
                  Icons.notifications_none, 
                  'Уведомления',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                  ),
                ),
                _buildSettingsItem(
                  Icons.info_outline, 
                  'Информация о себе',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                    );
                    _loadUserData(); // Reload when coming back
                  },
                ),
                _buildSettingsItem(
                  Icons.badge_outlined, 
                  'Управление визитками',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CardManagementScreen()),
                  ),
                ),
                _buildSettingsItem(
                  Icons.subscriptions_outlined, 
                  'Подписка',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  ),
                ),
                _buildSettingsItem(
                  Icons.security_outlined, 
                  'Приватность и безопасность',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PrivacySecurityScreen()),
                  ),
                ),
                _buildSettingsItem(
                  Icons.report_problem_outlined, 
                  'Сообщить о проблеме',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportProblemScreen()),
                  ),
                ),
                
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

  Widget _buildSettingsItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
