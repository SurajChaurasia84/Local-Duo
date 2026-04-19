import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:5000/api'; // Use localhost with 'adb reverse tcp:5000 tcp:5000' for physical devices over USB
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Using Web Client ID as more robust serverClientId for Android backend communication
    serverClientId: '894245854280-eu8d5rlu93oseu5lkbbirrc54ui7fmvh.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      debugPrint('Step 1: Starting Google Sign In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Step 1: User cancelled Google Sign In');
        return null;
      }
      debugPrint('Step 1: Google User: ${googleUser.email}');

      debugPrint('Step 2: Getting Authentication...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      debugPrint('Step 2: idToken received: ${idToken != null}');

      if (idToken == null) throw Exception('Failed to get ID Token from Google');

      debugPrint('Step 3: Sending to backend: $_baseUrl/auth/google-login');
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Step 3: Backend responded with status: ${response.statusCode}');
      return _handleAuthResponse(response);
    } catch (e) {
      debugPrint('Google AuthService Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      debugPrint('Signup Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      debugPrint('Login Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _handleAuthResponse(http.Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final String token = data['token'];
      
      // Save JWT Securely
      await _storage.write(key: _tokenKey, value: token);
      return data;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Authentication failed');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
