import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyLoginTime = 'login_time';

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return null;
    }
  }

  /// Get user name
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName);
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return null;
    }
  }

  /// Get login time
  Future<DateTime?> getLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTimeString = prefs.getString(_keyLoginTime);
      if (loginTimeString != null) {
        return DateTime.parse(loginTimeString);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting login time: $e');
      return null;
    }
  }

  /// Login user
  Future<bool> login({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setString(_keyUserName, name);
      await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());
      
      debugPrint('User logged in successfully: $email');
      return true;
    } catch (e) {
      debugPrint('Error logging in user: $e');
      return false;
    }
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyLoginTime);
      
      debugPrint('User logged out successfully');
      return true;
    } catch (e) {
      debugPrint('Error logging out user: $e');
      return false;
    }
  }

  /// Clear all user data
  Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }

  /// Update user name
  Future<bool> updateUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserName, name);
      return true;
    } catch (e) {
      debugPrint('Error updating user name: $e');
      return false;
    }
  }

  /// Update user email
  Future<bool> updateUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserEmail, email);
      return true;
    } catch (e) {
      debugPrint('Error updating user email: $e');
      return false;
    }
  }

  /// Check if login session is still valid (e.g., not expired)
  Future<bool> isSessionValid() async {
    try {
      final isLoggedIn = await this.isLoggedIn();
      if (!isLoggedIn) return false;

      final loginTime = await getLoginTime();
      if (loginTime == null) return false;

      // Check if login was within last 30 days
      final daysSinceLogin = DateTime.now().difference(loginTime).inDays;
      return daysSinceLogin < 30;
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return false;
    }
  }

  /// Get user info as a map
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final userId = await getUserId();
      final email = await getUserEmail();
      final name = await getUserName();
      final loginTime = await getLoginTime();

      if (userId == null || email == null || name == null) {
        return null;
      }

      return {
        'userId': userId,
        'email': email,
        'name': name,
        'loginTime': loginTime?.toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting user info: $e');
      return null;
    }
  }

  /// Initialize auth service
  Future<void> initialize() async {
    try {
      // Check if user is logged in and session is valid
      final isValid = await isSessionValid();
      if (!isValid) {
        await logout();
      }
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
    }
  }
}
