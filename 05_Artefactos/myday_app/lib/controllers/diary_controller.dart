import 'package:flutter/foundation.dart';

import '../models/comment.dart';
import '../models/entry.dart';
import '../models/enums.dart';
import '../models/project.dart';
import '../models/streak_reward.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../utils/app_images.dart';
import '../utils/date_formatter.dart';

class DiaryController extends ChangeNotifier {
  DiaryController(this._dataService, this._locationService);

  final DataService _dataService;
  final LocationService _locationService;

  static const List<StreakReward> rewards = [
    StreakReward(days: 3, title: 'Arranque', description: '3 dias seguidos'),
    StreakReward(days: 7, title: 'Uma semana', description: '7 dias seguidos'),
    StreakReward(days: 14, title: 'Duas semanas', description: '14 dias seguidos'),
    StreakReward(days: 30, title: 'Mês de ouro', description: '30 dias seguidos'),
    StreakReward(days: 60, title: 'Imparável', description: '60 dias seguidos'),
    StreakReward(days: 100, title: 'Lenda do MyDay', description: '100 dias seguidos'),
  ];

  List<Entry> get entries => _dataService.entries;

  List<Entry> get entriesWithLocation => entries.where((entry) => entry.hasCoordinates).toList();

  List<Entry> get todayEntries => _entriesOn(DateTime.now());

  List<Entry> get yesterdayEntries {
    return _entriesOn(DateTime.now().subtract(const Duration(days: 1)));
  }

  List<String> get projectNames {
    return _dataService.projects.map((project) => project.name).toList();
  }

  int get entriesThisWeek {
    final weekStart = _startOfWeek(DateTime.now());
    return entries.where((entry) => !entry.createdAt.isBefore(weekStart)).length;
  }

  /// Sete valores (segunda a domingo) que indicam os dias com registos.
  List<bool> get weekActivity {
    final weekStart = _startOfWeek(DateTime.now());
    return List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      return entries.any((entry) => DateFormatter.isSameDay(entry.createdAt, day));
    });
  }

  Entry addEntry({
    required String title,
    required String text,
    required Subject subject,
    required String project,
    required EntryVisibility visibility,
    required List<String> tags,
    String? location,
    double? latitude,
    double? longitude,
    String? imagePath,
    AttachmentType? mediaType,
  }) {
    final entry = Entry(
      id: _dataService.nextEntryId(),
      title: title.trim(),
      text: text.trim(),
      subject: subject,
      project: project,
      createdAt: DateTime.now(),
      visibility: visibility,
      location: location,
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath ?? AppImages.forSubject(subject),
      mediaType: mediaType,
      mediaLabel: mediaType?.label,
      tags: tags,
    );
    _dataService.addEntry(entry);
    notifyListeners();
    return entry;
  }

  /// Coordenadas atuais do GPS, para guardar no registo e mostrar no mapa.
  Future<({double latitude, double longitude})> currentLocation() async {
    final position = await _locationService.currentPosition();
    return (latitude: position.latitude, longitude: position.longitude);
  }

  List<Entry> entriesOn(DateTime day) => _entriesOn(day);

  List<Entry> entriesForProject(String projectName) {
    return entries.where((entry) => entry.project == projectName).toList();
  }

  Project? projectNamed(String name) {
    for (final project in _dataService.projects) {
      if (project.name == name) return project;
    }
    return null;
  }

  /// Dias (sem horas) em que existe pelo menos um registo.
  Set<DateTime> get activeDays => {for (final entry in entries) _dateOnly(entry.createdAt)};

  /// Dias seguidos com registos até hoje. Se hoje ainda não há registo, a
  /// sequência conta até ontem, para não se perder a meio do dia.
  int get currentStreak {
    final days = activeDays;
    var day = _dateOnly(DateTime.now());
    if (!days.contains(day)) day = _previousDay(day);

    var streak = 0;
    while (days.contains(day)) {
      streak++;
      day = _previousDay(day);
    }
    return streak;
  }

  int get bestStreak {
    final days = activeDays.toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final day in days) {
      run = previous != null && _previousDay(day) == previous ? run + 1 : 1;
      if (run > best) best = run;
      previous = day;
    }
    return best;
  }

  /// Próxima recompensa por desbloquear, ou null se já tem todas.
  StreakReward? get nextReward {
    for (final reward in rewards) {
      if (reward.days > currentStreak) return reward;
    }
    return null;
  }

  void toggleFavorite(Entry entry) {
    entry.isFavorite = !entry.isFavorite;
    notifyListeners();
  }

  void addComment(Entry entry, User author, String text) {
    if (text.trim().isEmpty) return;
    entry.comments.add(
      Comment(
        authorName: author.name,
        authorAvatar: author.avatarPath,
        text: text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  List<Entry> _entriesOn(DateTime day) {
    return entries.where((entry) => DateFormatter.isSameDay(entry.createdAt, day)).toList();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  // Construído a partir do dia e não com Duration, para não falhar nas
  // mudanças de hora (dias com 23 ou 25 horas).
  DateTime _previousDay(DateTime day) => DateTime(day.year, day.month, day.day - 1);

  DateTime _startOfWeek(DateTime date) {
    final day = _dateOnly(date);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
