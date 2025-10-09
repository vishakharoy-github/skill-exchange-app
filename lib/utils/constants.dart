class AppConstants {
  static const List<String> skillCategories = [
    'Technology',
    'Design',
    'Business',
    'Lifestyle',
    'Arts',
    'Languages',
    'Other'
  ];

  static const List<String> proficiencyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert'
  ];
}

class FirestoreCollections {
  static const String users = 'users';
  static const String skills = 'skills';
  static const String messages = 'messages';
  static const String exchanges = 'exchanges';
}

class StoragePaths {
  static const String profileImages = 'profile_images/';
  static const String skillImages = 'skill_images/';
}