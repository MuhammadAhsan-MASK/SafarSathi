import 'package:flutter/material.dart';

class FavoriteProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  int get favoriteCount => _favoriteIds.length;
}
