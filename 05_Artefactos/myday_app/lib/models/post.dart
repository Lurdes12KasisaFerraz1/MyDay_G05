import 'enums.dart';

class Post {
  Post({
    required this.authorName,
    required this.authorAvatar,
    required this.project,
    required this.timeAgo,
    required this.title,
    required this.text,
    required this.imagePath,
    required this.visibility,
    required this.commentsCount,
    required this.feed,
    this.isFavorite = false,
  });

  final String authorName;
  final String authorAvatar;
  final String project;
  final String timeAgo;
  final String title;
  final String text;
  final String imagePath;
  final EntryVisibility visibility;
  final int commentsCount;
  final CommunityFeed feed;
  bool isFavorite;
}
