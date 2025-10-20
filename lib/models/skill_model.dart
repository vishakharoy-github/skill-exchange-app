import 'package:intl/intl.dart'; // For date formatting

class Skill {
  final String id;
  final String name;
  final String category;
  final String description;
  final String createdBy;
  final int proficiencyLevel; // 1-5
  final List<String> tags;
  final DateTime createdAt;

  Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.createdBy,
    this.proficiencyLevel = 3,
    required this.tags,
    required this.createdAt,
  });

  factory Skill.fromMap(String id, Map<String, dynamic> map) {
    return Skill(
      id: id,
      name: map['name'],
      category: map['category'],
      description: map['description'],
      createdBy: map['createdBy'],
      proficiencyLevel: map['proficiencyLevel'] ?? 3,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'createdBy': createdBy,
      'proficiencyLevel': proficiencyLevel,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(), // Store as string for Realtime Database
    };
  }
}