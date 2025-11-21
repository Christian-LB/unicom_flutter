import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isCustomer => _user?.role == 'customer';
  AuthProvider() {
    _loadUserFromStorage();
  }
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('auth_token');
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _user = User.fromJson(userData);
        if (token != null && token.isNotEmpty) {
          ApiService.setAuthToken(token);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      final token = ApiService.authToken;
      if (token != null && token.isNotEmpty) {
        await prefs.setString('auth_token', token);
      }
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('auth_token');
      ApiService.setAuthToken(null);
    } catch (e) {
      debugPrint('Error clearing user from storage: $e');
    }
  }
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await ApiService.login(email, password);
      final userData = response['user'] as Map<String, dynamic>;
      final token = response['token'] as String?;
      _user = User.fromJson(userData);
      if (token != null && token.isNotEmpty) {
        ApiService.setAuthToken(token);
      }
      await _saveUserToStorage(_user!);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? company,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        company: company,
        phone: phone,
      );
      final userData = response['user'] as Map<String, dynamic>;
      _user = User.fromJson(userData);
      await _saveUserToStorage(_user!);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }
  Future<void> logout() async {
    _user = null;
    await _clearUserFromStorage();
    notifyListeners();
  }
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  void clearError() {
    _clearError();
  }
}
