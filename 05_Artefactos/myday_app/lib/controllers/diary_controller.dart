import 'package:flutter/foundation.dart';

import '../models/comment.dart';
import '../models/entry.dart';
import '../models/enums.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../utils/app_images.dart';
import '../utils/date_formatter.dart';

class DiaryController extends ChangeNotifier {
  DiaryController(this._dataService, this._locationService);

  final DataService _dataService;
  final LocationService _locationService;

  List<Entry> get entries => _dataService.entries;

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
      imagePath: imagePath ?? AppImages.forSubject(subject),
      mediaType: mediaType,
      mediaLabel: mediaType?.label,
      tags: tags,
    );
    _dataService.addEntry(entry);
    notifyListeners();
    return entry;
  }

  /// Coordenadas atuais do GPS, em texto, para guardar no registo.
  Future<String> currentLocation() async {
    final position = await _locationService.currentPosition();
    return '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
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

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
