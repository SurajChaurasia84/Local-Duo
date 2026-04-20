import 'dart:async';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static const String _healthUrl = 'http://localhost:5000/health';
  
  /// Checks if the backend server is reachable
  static Future<bool> isServerReachable() async {
    try {
      final response = await http.get(Uri.parse(_healthUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Periodically check server status (can be used for auto-refresh)
  static Stream<bool> serverStatusStream() async* {
    while (true) {
      yield await isServerReachable();
      await Future.delayed(const Duration(seconds: 30));
    }
  }
}
