import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;
  String? _error;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get user => _currentUser;
  String? get error => _error;
  String? get token => _token;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (token != null && userJson != null) {
        _token = token;
        _currentUser = jsonDecode(userJson);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading stored auth: $e');
      await _clearStoredAuth();
    }
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user));

    _token = token;
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    _token = null;
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      _isLoading = false;

      if (result['success'] == true) {
        await _saveAuthData(result['token'], result['user']);
        return true;
      } else {
        _error = result['error'] ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Connection error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.register(
        email: email,
        password: password,
        name: name,
      );

      _isLoading = false;

      if (result['success'] == true) {
        await _saveAuthData(result['token'], result['user']);
        return true;
      } else {
        _error = result['error'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Connection error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> generateOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.generateOtp(email);

      _isLoading = false;

      if (result['success'] == true) {
        return true;
      } else {
        _error = result['error'] ?? 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Connection error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.verifyOtp(
        email: email,
        otp: otp,
      );

      _isLoading = false;

      if (result['success'] == true) {
        return true;
      } else {
        _error = result['error'] ?? 'Invalid OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Connection error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.forgotPassword(email);

      _isLoading = false;

      if (result['success'] == true) {
        return true;
      } else {
        _error = result['error'] ?? 'Failed to send reset email';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Connection error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearStoredAuth();
  }

  
  Future<void> updateProfile(Map<String, dynamic> updated) async {
    try {
      _currentUser = {...?_currentUser, ...updated};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_currentUser));
      notifyListeners();
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
