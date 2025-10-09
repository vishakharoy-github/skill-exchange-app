class User {
  final String uid;
  final String email;
  final String name;
  final String? profileImage;
  final List<String> skills;
  final List<String> interests;
  final String bio;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.email,
    required this.name,
    this.profileImage,
    required this.skills,
    required this.interests,
    this.bio = '',
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      profileImage: map['profileImage'],
      skills: List<String>.from(map['skills'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      bio: map['bio'] ?? '',
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'skills': skills,
      'interests': interests,
      'bio': bio,
      'createdAt': createdAt.millisecondsSinceEpoch, // Store as timestamp
    };
  }

  // Helper method to parse timestamp from Realtime Database
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    if (timestamp is int) {
      // If it's stored as milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      // If it's stored as ISO string
      return DateTime.parse(timestamp);
    } else {
      // Fallback to current time
      return DateTime.now();
    }
  }
}