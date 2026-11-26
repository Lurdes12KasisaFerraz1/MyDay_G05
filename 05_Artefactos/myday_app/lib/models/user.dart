class User {
  User({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.course,
    required this.avatarPath,
    this.entriesCount = 0,
    this.followers = 0,
    this.following = 0,
    this.streakDays = 0,
  });

  final String name;
  final String email;
  String password;
  final String phone;
  final String course;
  final String avatarPath;
  int entriesCount;
  int followers;
  int following;
  int streakDays;

  /// Tentativas de login falhadas seguidas. Volta a 0 quando entra.
  int failedLoginAttempts = 0;

  String get firstName => name.split(' ').first;
}
