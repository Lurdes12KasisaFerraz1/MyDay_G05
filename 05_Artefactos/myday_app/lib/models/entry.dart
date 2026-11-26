import 'comment.dart';
import 'enums.dart';

class Entry {
  Entry({
    required this.id,
    required this.title,
    required this.text,
    required this.subject,
    required this.project,
    required this.createdAt,
    this.visibility = EntryVisibility.private,
    this.location,
    this.latitude,
    this.longitude,
    this.imagePath,
    this.mediaType,
    this.mediaLabel,
    this.tags = const [],
    this.isFavorite = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  final String id;
  final String title;
  final String text;
  final Subject subject;
  final String project;
  final DateTime createdAt;
  final EntryVisibility visibility;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? imagePath;
  final AttachmentType? mediaType;
  final String? mediaLabel;
  final List<String> tags;
  final List<Comment> comments;
  bool isFavorite;

  bool get hasCoordinates => latitude != null && longitude != null;
}
