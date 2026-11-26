import 'enums.dart';

class Project {
  const Project({
    required this.name,
    required this.coverImage,
    required this.visibility,
    required this.entriesCount,
    required this.lastActivity,
  });

  final String name;
  final String coverImage;
  final EntryVisibility visibility;
  final int entriesCount;
  final String lastActivity;
}

class StudyGroup {
  const StudyGroup({
    required this.name,
    required this.memberAvatars,
    required this.membersCount,
    required this.sharedEntries,
  });

  final String name;
  final List<String> memberAvatars;
  final int membersCount;
  final int sharedEntries;
}
