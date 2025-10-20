import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;

class UserService with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache to prevent multiple database calls
  app_model.User? _currentUserCache;
  String? _currentUserId;
  bool _isClearingCache = false;

  // Add the missing methods here:

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      updates['updatedAt'] = ServerValue.timestamp;
      await _database.child('users').child(userId).update(updates);

      // Invalidate cache
      _currentUserCache = null;
      _currentUserId = null;

      debugPrint('✅ User profile updated successfully');
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('❌ Update user profile error: $e');
      rethrow;
    }
  }

  Future<void> updateUserBio(String userId, String bio) async {
    try {
      await _database.child('users').child(userId).update({
        'bio': bio,
        'updatedAt': ServerValue.timestamp,
      });

      // Invalidate cache
      _currentUserCache = null;
      _currentUserId = null;

      debugPrint('✅ User bio updated successfully');
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('❌ Update user bio error: $e');
      rethrow;
    }
  }

  Future<app_model.User?> getUserById(String? userId) async {
    if (userId == null) return null;

    try {
      final snapshot = await _database.child('users').child(userId).get();
      if (snapshot.exists) {
        final Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        userData['uid'] = userId;
        return app_model.User.fromMap(userData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get user by ID error: $e');
      return null;
    }
  }

  // ... rest of your existing UserService methods (getAllUsers, getCurrentUser, etc.)

  Future<void> updateUserSkills(List<String> skills) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _database.child('users').child(userId).update({
        'skills': skills,
        'updatedAt': ServerValue.timestamp,
      });

      // Invalidate cache without immediate notifyListeners
      _currentUserCache = null;
      _currentUserId = null;

      debugPrint('✅ User skills updated successfully');
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('❌ Update user skills error: $e');
      rethrow;
    }
  }

  Future<List<app_model.User>> getAllUsers() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      final snapshot = await _database.child('users').get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> usersMap = snapshot.value as Map;
        final List<app_model.User> users = [];

        for (var entry in usersMap.entries) {
          final userData = entry.value;

          if (userData is Map && userData['email'] != null) {
            final Map<String, dynamic> userDataMap = Map<String, dynamic>.from(userData);
            userDataMap['uid'] = entry.key.toString();

            if (userDataMap['skills'] == null || userDataMap['skills'] is! List) {
              userDataMap['skills'] = [];
            }
            if (userDataMap['interests'] == null || userDataMap['interests'] is! List) {
              userDataMap['interests'] = [];
            }

            final user = app_model.User.fromMap(userDataMap);

            if (user.id != currentUserId) {
              users.add(user);
            }
          }
        }

        debugPrint('✅ Loaded ${users.length} users');
        return users;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Get all users error: $e');
      rethrow;
    }
  }

  Future<app_model.User?> getCurrentUser() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _clearCacheSilently();
        return null;
      }

      // Return cached user if it's the same user and cache exists
      if (_currentUserCache != null && _currentUserId == userId) {
        debugPrint('✅ Returning cached user data for: $userId');
        return _currentUserCache;
      }

      final snapshot = await _database.child('users').child(userId).get();

      if (!snapshot.exists) {
        debugPrint('🔄 No user data found for: $userId, checking all users...');

        final allUsersSnapshot = await _database.child('users').get();
        if (allUsersSnapshot.exists) {
          final Map<dynamic, dynamic> usersMap = allUsersSnapshot.value as Map;

          for (var entry in usersMap.entries) {
            final userData = entry.value;

            if (userData is Map && userData['email'] != null) {
              if (userData['email'] == _auth.currentUser?.email ||
                  entry.key.toString() == userId) {

                debugPrint('✅ Found user data at key: ${entry.key}');
                final Map<String, dynamic> foundUserData = Map<String, dynamic>.from(userData);
                foundUserData['uid'] = userId;

                if (foundUserData['skills'] == null || foundUserData['skills'] is! List) {
                  foundUserData['skills'] = [];
                }
                if (foundUserData['interests'] == null || foundUserData['interests'] is! List) {
                  foundUserData['interests'] = [];
                }

                _currentUserCache = app_model.User.fromMap(foundUserData);
                _currentUserId = userId;
                return _currentUserCache;
              }
            }
          }
        }

        // Create new user data if not found
        debugPrint('🔄 Creating new user data structure for: $userId');
        final currentUser = _auth.currentUser;
        if (currentUser == null) return null;

        Map<String, dynamic> defaultData = {
          'uid': userId,
          'email': currentUser.email ?? '',
          'name': currentUser.displayName ?? currentUser.email?.split('@').first ?? 'User',
          'bio': 'Enthusiastic IT Student | Passionate about learning new skills',
          'profileImage': 'https://i.postimg.cc/wjlhzZ6c/vishakhaprofessionalphoto.jpg',
          'skills': [],
          'interests': [],
          'createdAt': ServerValue.timestamp,
        };

        await _database.child('users').child(userId).set(defaultData);

        _currentUserCache = app_model.User.fromMap(defaultData);
        _currentUserId = userId;

        debugPrint('✅ Created proper user data structure for: $userId');
        return _currentUserCache;
      }

      // User exists in proper structure
      final Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
      userData['uid'] = userId;

      if (userData['skills'] == null || userData['skills'] is! List) {
        userData['skills'] = [];
      }
      if (userData['interests'] == null || userData['interests'] is! List) {
        userData['interests'] = [];
      }

      _currentUserCache = app_model.User.fromMap(userData);
      _currentUserId = userId;

      debugPrint('✅ Loaded user data from proper structure: $userId');
      return _currentUserCache;
    } catch (e) {
      debugPrint('❌ Get current user error: $e');
      _clearCacheSilently();
      return null;
    }
  }

  // Safe cache clearing without notifyListeners
  void _clearCacheSilently() {
    if (_isClearingCache) return;

    _isClearingCache = true;
    debugPrint('🔄 Clearing user service cache silently...');
    _currentUserCache = null;
    _currentUserId = null;
    _isClearingCache = false;
  }

  // Clear cache method with safe notification
  void _clearCache() {
    if (_isClearingCache) return;

    _isClearingCache = true;
    debugPrint('🔄 Clearing user service cache...');
    _currentUserCache = null;
    _currentUserId = null;
    _isClearingCache = false;
    _safeNotifyListeners();
  }

  // Public method to clear cache (called from auth service)
  void clearUserCache() {
    _clearCache();
  }

  Future<void> updateUserInterests(List<String> interests) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _database.child('users').child(userId).update({
        'interests': interests,
        'updatedAt': ServerValue.timestamp,
      });

      // Invalidate cache without immediate notifyListeners
      _currentUserCache = null;
      _currentUserId = null;

      debugPrint('✅ User interests updated successfully');
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('❌ Update user interests error: $e');
      rethrow;
    }
  }

  // Safe method to notify listeners that won't crash during build
  void _safeNotifyListeners() {
    if (_isClearingCache) return;

    try {
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Could not notify listeners (likely during build): $e');
      // Schedule notification for next frame
      Future.delayed(Duration.zero, () {
        if (!_isClearingCache) {
          notifyListeners();
        }
      });
    }
  }

  // Method to manually refresh user data (call this when switching users)
  Future<void> refreshUserData() async {
    debugPrint('🔄 Manually refreshing user data...');
    _clearCacheSilently();

    // Force reload by calling getCurrentUser again
    await getCurrentUser();
    _safeNotifyListeners();
  }
}