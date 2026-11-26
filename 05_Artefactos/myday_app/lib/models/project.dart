import 'enums.dart';

class Project {
  const Project({
    required this.name,
    required this.coverImage,
    required this.visibility,
    required this.entriesCount,
    required this.lastActivity,
    required this.description,
  });

  final String name;
  final String coverImage;
  final EntryVisibility visibility;
  final int entriesCount;
  final String lastActivity;
  final String description;
}
