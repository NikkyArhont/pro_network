import 'package:flutter/material.dart';
import 'package:pro_network/screens/phone_auth_screen.dart';

class AgreementsScreen extends StatefulWidget {
  final Map<String, String> profileData;
  const AgreementsScreen({super.key, required this.profileData});

  @override
  State<AgreementsScreen> createState() => _AgreementsScreenState();
}

class _AgreementsScreenState extends State<AgreementsScreen> {
  bool _agreePrivacy = false;
  bool _agreeTerms = false;

  void _next() {
    if (!_agreePrivacy || !_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Необходимо принять оба соглашения')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhoneAuthScreen(
          isLogin: false,
          profileData: widget.profileData,
        ),
      ),
    );
  }

  Widget _buildAgreeRow(bool val, Function(bool) onChanged, String prefix, String link) {
    return GestureDetector(
      onTap: () => onChanged(!val),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              color: val ? const Color(0xFFE86B00) : Colors.transparent,
              border: Border.all(color: val ? const Color(0xFFE86B00) : const Color(0xFF557578), width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: val ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: prefix,
                style: const TextStyle(color: Color(0xFF637B7E), fontSize: 13, fontFamily: 'Inter', height: 1.4),
                children: [
                  TextSpan(
                    text: link,
                    style: const TextStyle(color: Color(0xFFE86B00), fontSize: 13, fontFamily: 'Inter', height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _agreePrivacy && _agreeTerms;

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
                            flex: 4, // step 4 of 5
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
                    const SizedBox(width: 8),
                    const Text(
                      '4/5',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Примите условия\nпользования приложением',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Exclamation Icon block
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE86B00).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE86B00),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Agreements Block
                _buildAgreeRow(
                  _agreePrivacy, 
                  (val) => setState(() => _agreePrivacy = val), 
                  'Я принимаю ', 
                  'Политику конфиденциальности'
                ),
                const SizedBox(height: 16),
                _buildAgreeRow(
                  _agreeTerms, 
                  (val) => setState(() => _agreeTerms = val), 
                  'Я принимаю ', 
                  'Пользовательское соглашение'
                ),
                
                const SizedBox(height: 32),

                // Bottom Button
                Opacity(
                  opacity: canProceed ? 1.0 : 0.5,
                  child: GestureDetector(
                    onTap: canProceed ? _next : null,
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
                        'Принять и продолжить',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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
