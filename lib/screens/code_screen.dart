import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_network/services/auth_service.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/screens/home_screen.dart';
import 'package:pro_network/screens/success_screen.dart';

class CodeScreen extends StatefulWidget {
  final String verificationId;
  final bool isLogin;
  final Map<String, String>? profileData;
  final String phoneNumber;
  final bool isExternal;

  const CodeScreen({
    super.key,
    required this.verificationId,
    required this.isLogin,
    this.profileData,
    required this.phoneNumber,
    this.isExternal = false,
  });

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final TextEditingController _smsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }

  void _verifyCode(String smsCode) async {
    setState(() => _isLoading = true);
    
    UserCredential? userCredential;

    if (widget.isExternal) {
      // 1. Verify code and get JWT via Cloud Function
      final result = await _authService.verifyExternalCode(widget.phoneNumber, smsCode);
      if (result['success'] == true && result['customToken'] != null) {
        // 2. Sign in with Custom Token
        userCredential = await _authService.signInWithCustomToken(result['customToken']);
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Неверный код')),
        );
        return;
      }
    } else {
      // Standard Firebase Phone Auth
      userCredential = await _authService.signInWithCode(widget.verificationId, smsCode);
    }
    
    if (userCredential != null) {
      if (!widget.isLogin && widget.profileData != null) {
        // Registration flow -> save profile -> success screen
        try {
          await _userService.createUserProfile(
            name: widget.profileData!['name']!,
            city: widget.profileData!['city']!,
            photoUrl: widget.profileData!['photoUrl']!,
          );
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SuccessScreen()),
            (route) => false,
          );
        } catch (e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка создания профиля: $e')));
        }
      } else {
        // Login flow -> ensure firestore record exists -> home screen
        await _userService.ensureUserExists(userCredential.user!);
        
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка входа')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF557578), width: 1.5),
      ),
    );

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
                            flex: widget.isLogin ? 2 : 5, 
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF557578),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Expanded(
                             flex: widget.isLogin ? 0 : 0, 
                             child: const SizedBox.shrink()
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isLogin ? '2/2' : '5/5',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Введите код',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Мы отправили код подтверждения на номер ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF637B7E), 
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // PinPut
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _smsController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: defaultPinTheme,
                    showCursor: true,
                    cursor: Container(
                      width: 2,
                      height: 24,
                      color: Colors.white,
                    ),
                    onCompleted: _verifyCode,
                  ),
                ),
                
                const Spacer(),
                
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Logic for resending OTP to be implemented later.
                    },
                    child: const Text(
                      'Отправить код повторно',
                      style: TextStyle(
                        color: Color(0xFF557578),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF557578)))
                else
                  GestureDetector(
                    onTap: () {
                      if (_smsController.text.length == 6) {
                        _verifyCode(_smsController.text);
                      }
                    },
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
                        'Подтвердить',
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
