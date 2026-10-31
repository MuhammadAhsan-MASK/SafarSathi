import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/hotels/models/hotel_model.dart';
import '../features/restaurants/models/restaurant_model.dart';
import '../features/attractions/models/attraction_model.dart';
import 'seed_data.dart';

class FavoriteProvider with ChangeNotifier {
  static const String _storageKey = 'user_favorites';
  final Set<String> _favoriteIds = {};
  bool _isLoaded = false;

  FavoriteProvider() {
    _loadFromPrefs();
  }

  Set<String> get favoriteIds => _favoriteIds;
  int get favoriteCount => _favoriteIds.length;
  bool get isLoaded => _isLoaded;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_storageKey);
      if (savedList != null) {
        _favoriteIds.clear();
        _favoriteIds.addAll(savedList);
      }
    } catch (_) {}
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _favoriteIds.toList());
    } catch (_) {}
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    _saveToPrefs();
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  void removeFavorite(String id) {
    if (_favoriteIds.remove(id)) {
      _saveToPrefs();
      notifyListeners();
    }
  }

  List<Hotel> getFavoriteHotels() {
    final hotels = SeedData.initialHotels;
    return hotels.where((h) => _favoriteIds.contains(h.id)).toList();
  }

  List<Restaurant> getFavoriteRestaurants() {
    final restaurants = SeedData.initialRestaurants;
    return restaurants.where((r) => _favoriteIds.contains(r.id)).toList();
  }

  List<Attraction> getFavoriteAttractions() {
    final attractions = SeedData.initialAttractions;
    return attractions.where((a) => _favoriteIds.contains(a.id)).toList();
  }
}
