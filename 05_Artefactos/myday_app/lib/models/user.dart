class User {
  User({
    required this.name,
    required this.email,
    required this.password,
    required this.course,
    required this.avatarPath,
    this.entriesCount = 0,
    this.followers = 0,
    this.following = 0,
    this.streakDays = 0,
  });

  final String name;
  final String email;
  final String password;
  final String course;
  final String avatarPath;
  int entriesCount;
  int followers;
  int following;
  int streakDays;

  String get firstName => name.split(' ').first;
}
