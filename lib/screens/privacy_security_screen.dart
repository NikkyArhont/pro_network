import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pro_network/screens/privacy_options_screen.dart';
import 'package:pro_network/screens/feed_privacy_screen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool findByPhone = false;
  bool preventScreenshots = true;
  String messagePermission = 'Мои связи';
  String feedVisibility = 'Некоторые';
  String userPhone = 'Загрузка...';
  String userEmail = 'Загрузка...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get phone from Auth
      setState(() {
        userPhone = user.phoneNumber ?? 'Не указан';
        userEmail = user.email ?? 'Не указана';
      });

      // Try to get more accurate/updated data from Firestore
      try {
        final doc = await FirebaseFirestore.instanceFor(
          app: FirebaseFirestore.instance.app,
          databaseId: 'pronetwork',
        ).collection('users').doc(user.uid).get();
        
        if (doc.exists && mounted) {
          final data = doc.data();
          setState(() {
            if (data?['phoneNumber'] != null) userPhone = data!['phoneNumber'];
            if (data?['email'] != null) userEmail = data!['email'];
          });
        }
      } catch (e) {
        print('Error loading user data in PrivacyScreen: $e');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF01191B),
      body: Stack(
        children: [
          // Header / Status Bar Area
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 54,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
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
                      SizedBox(width: 7),
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

          // Back Button and Title
          Positioned(
            left: 10,
            top: 59,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Приватность и безопасность',
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
                      child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Positioned.fill(
            top: 99,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy Section
                  Text(
                    'Приватность',
                    style: TextStyle(
                      color: Color(0xFFFF8E30),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF0C3135),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildToggleItem(
                          'Найти меня по номеру телефона',
                          findByPhone,
                          (val) => setState(() => findByPhone = val),
                          isFirst: true,
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          'Запретить скриншот и пересылку моих сообщений, постов и историй',
                          preventScreenshots,
                          (val) => setState(() => preventScreenshots = val),
                          subtitle: true,
                        ),
                        _buildDivider(),
                        _buildValueItem(
                          'Кто может писать мне сообщения',
                          messagePermission,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrivacyOptionsScreen(
                                title: 'Кто может писать мне',
                                currentOption: messagePermission,
                                onOptionSelected: (val) => setState(() => messagePermission = val),
                              ),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildValueItem(
                          'Кто видит мою ленту',
                          feedVisibility,
                          isLast: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FeedPrivacyScreen(
                                currentOption: feedVisibility,
                                onOptionSelected: (val) => setState(() => feedVisibility = val),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Login and Security Section
                  Text(
                    'Вход и безопасность',
                    style: TextStyle(
                      color: Color(0xFFFF8E30),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildSecurityItem(
                    Icons.phone_android_outlined,
                    'Телефон',
                    userPhone,
                  ),
                  SizedBox(height: 15),
                  _buildSecurityItem(
                    Icons.email_outlined,
                    'Почта',
                    userEmail,
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

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Color(0xFFABABAB).withOpacity(0.3),
      margin: EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildToggleItem(String title, bool value, Function(bool) onChanged, {bool isFirst = false, bool subtitle = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: BoxConstraints(minHeight: subtitle ? 55 : 37),
      decoration: BoxDecoration(
        color: Color(0xFF0C3135),
        borderRadius: isFirst ? BorderRadius.vertical(top: Radius.circular(10)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 40,
              height: 25,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Color(0xFF3F5659),
                borderRadius: BorderRadius.circular(76),
              ),
              child: AnimatedAlign(
                duration: Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    color: value ? Color(0xFFFF8E30) : Color(0xFF7C9597),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(String title, String value, {bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 37,
        decoration: BoxDecoration(
          color: Color(0xFF0C3135),
          borderRadius: isLast ? BorderRadius.vertical(bottom: Radius.circular(10)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Color(0xFFFF8E30),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: 5),
                  Icon(Icons.chevron_right, color: Color(0xFFFF8E30), size: 14),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFFF8E30), size: 25),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFFC6C6C6),
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.white, size: 20),
      ],
    );
  }
}
