import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Use your real actual ip
    static const String _baseUrl =
      'http://10.194.251.185:5000/api'; 

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      print('Register response: ${response.statusCode}');
      print('Register body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Save token
        await _saveToken(data['token']);
        await _saveUserData(data['user']);

        return {
          'success': true,
          'user': data['user'],
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username
        }),
      );

      print('Login response: ${response.statusCode}');
      print('Login body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token
        await _saveToken(data['token']);
        await _saveUserData(data['user']);

        return {
          'success': true,
          'user': data['user'],
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'token');

      if (token == null) {
        return {
          'success': false,
          'error': 'No token found',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Get profile response: ${response.statusCode}');
      print('Get profile body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update stored user data
        await _saveUserData(data['user']);

        return {
          'success': true,
          'user': data['user'],
        };
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await logout();
        return {
          'success': false,
          'error': 'Session expired',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      print('Get profile error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      print('Forgot password response: ${response.statusCode}');
      print('Forgot password body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Reset email sent',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to send reset email',
        };
      }
    } catch (e) {
      print('Forgot password error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await _secureStorage.read(key: 'token');

      if (token != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear all stored data
      await _secureStorage.delete(key: 'token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'token');
    if (token == null) return false;

    // Verify token is still valid by getting user profile
    final result = await getCurrentUser();
    return result['success'] == true;
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Get auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
  }

  // Private helper methods
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }
}
