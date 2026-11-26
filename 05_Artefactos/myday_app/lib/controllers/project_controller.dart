import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/project.dart';
import '../models/study_group.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../utils/app_exception.dart';
import '../utils/text_search.dart';

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

  /// Cria um projeto novo. O nome é obrigatório, tem no máximo 40 caracteres
  /// (prj_nome) e não pode repetir o de outro projeto.
  Project createProject({
    required String name,
    required String description,
    required Subject subject,
    required EntryVisibility visibility,
    required String coverImage,
  }) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw const AppException('Dá um nome ao projeto.', title: 'Falta o nome');
    }
    final exists = _dataService.projects.any(
      (project) => TextSearch.normalize(project.name) == TextSearch.normalize(cleanName),
    );
    if (exists) {
      throw const AppException('Já tens um projeto com este nome.', title: 'Projeto repetido');
    }

    final project = Project(
      name: cleanName,
      coverImage: coverImage,
      visibility: visibility,
      subject: subject,
      description: description.trim(),
    );
    _dataService.addProject(project);
    notifyListeners();
    return project;
  }

  List<Project> searchProjects(String query) {
    return _dataService.projects
        .where((project) => TextSearch.matches(query, [project.name, project.description, project.subject.label]))
        .toList();
  }

  List<StudyGroup> searchGroups(String query) {
    return groups.where((group) => TextSearch.matches(query, [group.name, group.description])).toList();
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
