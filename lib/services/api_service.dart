import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/issue.dart';
import 'auth_service.dart';
import 'image_service.dart';

class ApiService {
  final AuthService _authService = AuthService();
  static const String _baseUrl = 'http://localhost:5000/api';
  
  // Cache keys
  static const String _cacheKeyFeed = 'cache_all_issues';
  static const String _cacheKeyUserReports = 'cache_user_issues';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Saves data to local storage for offline fallback
  Future<void> _saveToCache(String key, List<Issue> issues) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(issues.map((i) => i.toJson()).toList());
      await prefs.setString(key, encodedData);
    } catch (e) {
      debugPrint('Cache Save Error: $e');
    }
  }

  /// Loads data from local storage when network fails
  Future<List<Issue>> _loadFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedData = prefs.getString(key);
      if (encodedData != null) {
        final List<dynamic> data = jsonDecode(encodedData);
        return data.map((json) => Issue.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Cache Load Error: $e');
    }
    return [];
  }

  Future<List<Issue>> getIssues() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/issues'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final issues = data.map((json) => Issue.fromJson(json)).toList();
        
        // Success: Update cache
        await _saveToCache(_cacheKeyFeed, issues);
        return issues;
      } else {
        throw Exception('Failed to load issues');
      }
    } catch (e) {
      // Failure: Try to return cached data
      final cached = await _loadFromCache(_cacheKeyFeed);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<Issue>> getNearbyIssues(double lat, double lng, {int radius = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/issues/nearby?lat=$lat&lng=$lng&radius=$radius'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Issue.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load nearby issues');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Issue>> getUserIssues() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/issues/user'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final issues = data.map((json) => Issue.fromJson(json)).toList();
        
        // Success: Update cache
        await _saveToCache(_cacheKeyUserReports, issues);
        return issues;
      } else {
        throw Exception('Failed to load user issues');
      }
    } catch (e) {
      // Failure: Return cached data
      final cached = await _loadFromCache(_cacheKeyUserReports);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<bool> createIssue(Issue issue) async {
    try {
      final token = await _authService.getToken();
      final uri = Uri.parse('$_baseUrl/issues/create');
      
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['report_id'] = issue.id;
      request.fields['category'] = 'general';
      request.fields['description'] = issue.caption;
      request.fields['latitude'] = issue.latitude.toString();
      request.fields['longitude'] = issue.longitude.toString();
      request.fields['address'] = issue.location;
      request.fields['cityCode'] = 'GEN';

      final compressedBytes = await ImageService.compressToTarget(issue.imagePath);
      
      final file = http.MultipartFile.fromBytes(
        'image',
        compressedBytes,
        filename: 'report_image.jpg',
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('ApiService.createIssue Error: $e');
      return false;
    }
  }

  Future<bool> deleteIssue(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/issues/delete/$id'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.deleteIssue Error: $e');
      return false;
    }
  }
}
