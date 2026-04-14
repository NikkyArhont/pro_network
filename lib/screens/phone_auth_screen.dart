import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_network/widgets/app_text_field.dart';
import 'package:pro_network/services/auth_service.dart';
import 'package:pro_network/screens/code_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  final bool isLogin;
  final Map<String, String>? profileData;

  const PhoneAuthScreen({
    super.key,
    required this.isLogin,
    this.profileData,
  });

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  final List<String> _testNumbers = [
    '79000000000',
    '79111111111',
    '79222222222',
    '79333333333',
  ];

  void _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _isLoading = true);

    // Normalize phone number for comparison and Firebase
    String normalizedPhone = phone;
    if (!normalizedPhone.startsWith('+')) {
      normalizedPhone = '+$normalizedPhone';
    }

    // Check if it's a test number (strip '+' for comparison)
    String cleanPhone = normalizedPhone.replaceAll('+', '');
    bool isTestNumber = _testNumbers.contains(cleanPhone);

    if (isTestNumber) {
      print('DEBUG: [Auth] Using Firebase Phone Auth for test number: $normalizedPhone');
      _authService.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        onCodeSent: (verificationId) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CodeScreen(
                verificationId: verificationId,
                isLogin: widget.isLogin,
                profileData: widget.profileData,
                phoneNumber: normalizedPhone,
                isExternal: false,
              ),
            ),
          );
        },
        onError: (err) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        },
      );
    } else {
      print('DEBUG: [Auth] Using External API Auth for real number: $normalizedPhone');
      
      final result = await _authService.sendExternalCode(normalizedPhone);
      
      setState(() => _isLoading = false);
      
      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CodeScreen(
              verificationId: '', // Not needed for external
              isLogin: widget.isLogin,
              profileData: widget.profileData,
              phoneNumber: normalizedPhone,
              isExternal: true,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Ошибка отправки SMS')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 375, // Target width from design constraints
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Авторизация',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C3135),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1, // Represents 1 out of 2 steps
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF557578),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '1/2',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  hintText: '+7 (900) 000-00-00',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),
                const Spacer(),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF557578)))
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: const Color(0xFF557578), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Восстановить доступ',
                            style: TextStyle(
                              color: Color(0xFF557578),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _sendCode,
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
                            'Получить код',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
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

