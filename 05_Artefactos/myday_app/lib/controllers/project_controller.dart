import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/project.dart';
import '../services/data_service.dart';

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

  void setFilter(EntryVisibility? visibility) {
    _filter = visibility;
    notifyListeners();
  }
}
