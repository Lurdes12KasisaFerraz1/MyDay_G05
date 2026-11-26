import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/project.dart';
import '../models/study_group.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../utils/app_exception.dart';

class ProjectController extends ChangeNotifier {
  ProjectController(this._dataService);

  final DataService _dataService;

  /// null significa "Todos".
  EntryVisibility? _filter;

  EntryVisibility? get filter => _filter;

  List<StudyGroup> get groups => _dataService.groups;

  List<Project> get projects {
    final all = _dataService.projects;
    if (_filter == null) return all;
    return all.where((project) => project.visibility == _filter).toList();
  }

  void joinGroup(StudyGroup group, User user) {
    if (user.isGuest) {
      throw const AppException('Precisas de uma conta para entrar num grupo.', title: 'Sem conta');
    }
    if (group.hasMember(user)) return;
    group.members.add(GroupMember(user: user, role: GroupRole.member, joinedAt: DateTime.now()));
    notifyListeners();
  }

  /// O dono não pode sair: o grupo ficaria sem ninguém a geri-lo.
  void leaveGroup(StudyGroup group, User user) {
    if (group.owner == user) {
      throw const AppException('És o dono deste grupo, por isso não podes sair.', title: 'Não é possível sair');
    }
    group.members.removeWhere((member) => member.user == user);
    notifyListeners();
  }

  void toggleReminder(StudyGroup group) {
    final reminder = group.reminder;
    if (reminder == null) return;
    reminder.isActive = !reminder.isActive;
    notifyListeners();
  }

  void setFilter(EntryVisibility? visibility) {
    _filter = visibility;
    notifyListeners();
  }
}
