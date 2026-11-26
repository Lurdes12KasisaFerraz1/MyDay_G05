class Comment {
  const Comment({
    required this.authorName,
    required this.authorAvatar,
    required this.text,
    required this.createdAt,
  });

  final String authorName;
  final String authorAvatar;
  final String text;
  final DateTime createdAt;
}
