import 'enums.dart';
import 'user.dart';

/// Membro de um grupo (tabela utilizador_grupo).
class GroupMember {
  const GroupMember({required this.user, required this.role, required this.joinedAt});

  final User user;
  final GroupRole role;
  final DateTime joinedAt;
}

/// Lembrete partilhado pelo grupo (tabela lembrete com lem_gru_id).
class GroupReminder {
  GroupReminder({required this.title, required this.schedule, this.isActive = true});

  final String title;

  /// Dias e hora, por exemplo "Quintas · 18:00".
  final String schedule;
  bool isActive;
}

/// Grupo de estudo (tabela grupo).
class StudyGroup {
  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.members,
    required this.sharedEntries,
    this.reminder,
  });

  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<GroupMember> members;
  final int sharedEntries;
  final GroupReminder? reminder;

  int get membersCount => members.length;

  User get owner => members.firstWhere((member) => member.role == GroupRole.owner).user;

  /// Fotos mostradas no cartão do grupo (no máximo duas).
  List<String> get memberAvatars => [for (final member in members.take(2)) member.user.avatarPath];

  bool hasMember(User user) => members.any((member) => member.user == user);
}
