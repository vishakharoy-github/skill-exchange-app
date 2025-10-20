class User {
  final String id;
  final String name;
  final String email;
  final String? title;
  final String? bio;
  final List<String> skills;
  final List<String> interests;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.title,
    this.bio,
    required this.skills,
    required this.interests,
    this.profileImage,
  });

  // Add fromMap factory constructor
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['uid'] ?? map['id'] ?? '',
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      title: map['title'],
      bio: map['bio'],
      skills: List<String>.from(map['skills'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      profileImage: map['profileImage'],
    );
  }

  // Add copyWith method for updates
  User copyWith({
    String? name,
    String? title,
    String? bio,
    List<String>? skills,
    List<String>? interests,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'title': title,
      'bio': bio,
      'skills': skills,
      'interests': interests,
      'profileImage': profileImage,
    };
  }
}