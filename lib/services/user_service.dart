import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;

class UserService with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserSkills(List<String> skills) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _database.child('users').child(userId).update({
        'skills': skills,
        'updatedAt': ServerValue.timestamp,
      });

      debugPrint('✅ User skills updated successfully');
      notifyListeners();
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
        final users = usersMap.entries.map((entry) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          final Map<String, dynamic> userData = Map<String, dynamic>.from(entry.value as Map);
          userData['uid'] = entry.key.toString();
          return app_model.User.fromMap(userData);
        }).where((user) => user.uid != currentUserId).toList();

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
      if (userId == null) return null;

      final snapshot = await _database.child('users').child(userId).get();
      if (!snapshot.exists) return null;

      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      final Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
      userData['uid'] = userId;

      debugPrint('✅ Loaded current user data');
      return app_model.User.fromMap(userData);
    } catch (e) {
      debugPrint('❌ Get current user error: $e');
      return null;
    }
  }

  Future<void> updateUserInterests(List<String> interests) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _database.child('users').child(userId).update({
        'interests': interests,
        'updatedAt': ServerValue.timestamp,
      });

      debugPrint('✅ User interests updated successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Update user interests error: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      updates['updatedAt'] = ServerValue.timestamp;
      await _database.child('users').child(userId).update(updates);

      debugPrint('✅ User profile updated successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Update user profile error: $e');
      rethrow;
    }
  }
}