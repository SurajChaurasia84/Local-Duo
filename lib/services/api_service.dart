import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/issue.dart';
import 'auth_service.dart';
import 'image_service.dart';

class ApiService {
  final AuthService _authService = AuthService();
  static const String _baseUrl = 'http://localhost:5000/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Issue>> getIssues() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/issues'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Issue.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load issues');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Issue>> getNearbyIssues(double lat, double lng, {int radius = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/issues/nearby?lat=$lat&lng=$lng&radius=$radius'),
        headers: await _getHeaders(),
      );

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
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Issue.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user issues');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createIssue(Issue issue) async {
    try {
      final token = await _authService.getToken();
      final uri = Uri.parse('$_baseUrl/issues/create');
      
      final request = http.MultipartRequest('POST', uri);
      
      // Add Headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add Fields
      request.fields['report_id'] = issue.id;
      request.fields['category'] = 'general';
      request.fields['description'] = issue.caption;
      request.fields['latitude'] = issue.latitude.toString();
      request.fields['longitude'] = issue.longitude.toString();
      request.fields['address'] = issue.location;
      request.fields['cityCode'] = 'GEN'; // Could be dynamic later

      // Add Image File
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
}
