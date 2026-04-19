import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api'; // Use 10.0.2.2 for Android Emulator
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '894245854280-feiipvk04fljhm6qj1hp1q9svgk1a84l.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // 1. Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. Get ID Token
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('Failed to get ID Token from Google');

      // 3. Exchange for Backend JWT
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

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
