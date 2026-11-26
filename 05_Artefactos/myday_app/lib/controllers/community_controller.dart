import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/post.dart';
import '../services/data_service.dart';

class CommunityController extends ChangeNotifier {
  CommunityController(this._dataService);

  final DataService _dataService;

  CommunityFeed _feed = CommunityFeed.following;
  String _search = '';

  CommunityFeed get feed => _feed;
  String get weeklyChallenge => _dataService.weeklyChallenge;

  List<Post> get posts {
    final query = _search.toLowerCase();
    return _dataService.posts.where((post) {
      final matchesFeed = post.feed == _feed;
      final matchesSearch = query.isEmpty ||
          post.title.toLowerCase().contains(query) ||
          post.authorName.toLowerCase().contains(query) ||
          post.project.toLowerCase().contains(query);
      return matchesFeed && matchesSearch;
    }).toList();
  }

  void setFeed(CommunityFeed feed) {
    _feed = feed;
    notifyListeners();
  }

  void search(String text) {
    _search = text.trim();
    notifyListeners();
  }

  void toggleFavorite(Post post) {
    post.isFavorite = !post.isFavorite;
    notifyListeners();
  }
}
