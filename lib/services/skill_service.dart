import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skill_exchange_app/models/skill_model.dart';

class SkillService with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<List<Skill>> getAllSkills() async {
    try {
      final snapshot = await _database.child('skills').get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> skillsMap = snapshot.value as Map;
        final skills = skillsMap.entries.map((entry) {
          final Map<String, dynamic> skillData = Map<String, dynamic>.from(entry.value as Map);
          return Skill.fromMap(entry.key.toString(), skillData);
        }).toList();

        debugPrint('✅ Loaded ${skills.length} skills');
        return skills;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Get all skills error: $e');
      rethrow;
    }
  }

  Future<void> addSkill(Skill skill) async {
    try {
      final newSkillRef = _database.child('skills').push();
      await newSkillRef.set(skill.toMap());
      debugPrint('✅ Skill added successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Add skill error: $e');
      rethrow;
    }
  }

  Future<List<Skill>> getSkillsByCategory(String category) async {
    try {
      final snapshot = await _database.child('skills').get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> skillsMap = snapshot.value as Map;
        final skills = skillsMap.entries.map((entry) {
          final Map<String, dynamic> skillData = Map<String, dynamic>.from(entry.value as Map);
          return Skill.fromMap(entry.key.toString(), skillData);
        }).where((skill) => skill.category == category).toList();

        debugPrint('✅ Loaded ${skills.length} skills for category: $category');
        return skills;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Get skills by category error: $e');
      rethrow;
    }
  }
}