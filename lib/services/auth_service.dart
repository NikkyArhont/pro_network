import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Service for calling Cloud Functions
  static const String _functionsBaseUrl = 'https://us-central1-mla-project-1.cloudfunctions.net';

  /// (Existing) Firebase Phone Auth
  void verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Ошибка верификации телефона');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// (NEW) Step 1: Send Code via Cloud Function (SMS Aero)
  Future<Map<String, dynamic>> sendExternalCode(String phone) async {
    print('DEBUG: [Auth] Sending code to: $_functionsBaseUrl/sendcode');
    try {
      final response = await http.post(
        Uri.parse('$_functionsBaseUrl/sendcode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      print('DEBUG: [Auth] Response status: ${response.statusCode}');
      print('DEBUG: [Auth] Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('DEBUG: [Auth] Error in sendExternalCode: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// (NEW) Step 2: Verify Code and get JWT Token
  Future<Map<String, dynamic>> verifyExternalCode(String phone, String code) async {
    print('DEBUG: [Auth] Verifying code at: $_functionsBaseUrl/verifycode');
    try {
      final response = await http.post(
        Uri.parse('$_functionsBaseUrl/verifycode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );

      print('DEBUG: [Auth] Response status: ${response.statusCode}');
      print('DEBUG: [Auth] Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('DEBUG: [Auth] Error in verifyExternalCode: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// (NEW) Step 3: Sign in to Firebase with Custom Token
  Future<UserCredential?> signInWithCustomToken(String token) async {
    try {
      return await _auth.signInWithCustomToken(token);
    } catch (e) {
      print('Error signing in with custom token: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithCode(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }
}
