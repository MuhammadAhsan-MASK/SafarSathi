import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_trip_model.dart';

class SavedTripsService {
  static const String _storageKey = 'safar_saved_trips';
  static const String _mockCleanupFlag = 'safar_khata_mock_cleaned_v1';
  static final SavedTripsService _instance = SavedTripsService._internal();

  factory SavedTripsService() => _instance;
  SavedTripsService._internal();

  final ValueNotifier<List<SavedTrip>> tripsNotifier = ValueNotifier<List<SavedTrip>>([]);

  static const Set<String> _legacyMockTripIds = {
    'trip_murree_hills',
    'trip_hunza_autumn',
    'trip_swat_valley',
  };

  Future<List<SavedTrip>> getSavedTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // One-time cleanup of previously seeded mock trips & sample khata data
      final cleaned = prefs.getBool(_mockCleanupFlag) ?? false;
      if (!cleaned) {
        final rawJson = prefs.getString(_storageKey);
        if (rawJson != null && rawJson.isNotEmpty) {
          final List<dynamic> list = jsonDecode(rawJson);
          final filtered = list
              .map((m) => SavedTrip.fromMap(Map<String, dynamic>.from(m)))
              .where((t) => !_legacyMockTripIds.contains(t.id))
              .toList();
          await _persistTrips(prefs, filtered);
        }
        for (final id in _legacyMockTripIds) {
          await prefs.remove('safar_split_people_$id');
          await prefs.remove('safar_split_expenses_$id');
          await prefs.remove('safar_split_settled_$id');
        }
        await prefs.remove('safar_split_people');
        await prefs.remove('safar_split_expenses');
        await prefs.remove('safar_split_settled');
        await prefs.setBool(_mockCleanupFlag, true);
      }

      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonString);
        final trips = list.map((m) => SavedTrip.fromMap(Map<String, dynamic>.from(m))).toList();
        tripsNotifier.value = trips;
        return trips;
      }

      tripsNotifier.value = [];
      return [];
    } catch (e) {
      debugPrint('Error getting saved trips: $e');
      tripsNotifier.value = [];
      return [];
    }
  }

  Future<SavedTrip?> getCurrentTrip() async {
    final trips = await getSavedTrips();
    if (trips.isEmpty) return null;
    return trips.firstWhere((t) => t.isCurrent, orElse: () => trips.first);
  }

  Future<void> saveTrip(SavedTrip trip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trips = await getSavedTrips();
      final index = trips.indexWhere((t) => t.id == trip.id);

      List<SavedTrip> updatedTrips;
      if (index >= 0) {
        updatedTrips = List.from(trips);
        updatedTrips[index] = trip;
      } else {
        updatedTrips = [trip, ...trips];
      }

      if (trip.isCurrent) {
        updatedTrips = updatedTrips.map((t) {
          if (t.id != trip.id) {
            return t.copyWith(isCurrent: false);
          }
          return t;
        }).toList();
      }

      await _persistTrips(prefs, updatedTrips);
      tripsNotifier.value = updatedTrips;
    } catch (e) {
      debugPrint('Error saving trip: $e');
    }
  }

  Future<void> setCurrentTrip(String tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trips = await getSavedTrips();
      final updatedTrips = trips.map((t) {
        return t.copyWith(isCurrent: t.id == tripId);
      }).toList();

      await _persistTrips(prefs, updatedTrips);
      tripsNotifier.value = updatedTrips;
    } catch (e) {
      debugPrint('Error setting current trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trips = await getSavedTrips();
      final updatedTrips = trips.where((t) => t.id != tripId).toList();

      if (updatedTrips.isNotEmpty && !updatedTrips.any((t) => t.isCurrent)) {
        updatedTrips[0] = updatedTrips[0].copyWith(isCurrent: true);
      }

      await prefs.remove('safar_split_people_$tripId');
      await prefs.remove('safar_split_expenses_$tripId');
      await prefs.remove('safar_split_settled_$tripId');

      await _persistTrips(prefs, updatedTrips);
      tripsNotifier.value = updatedTrips;
    } catch (e) {
      debugPrint('Error deleting trip: $e');
    }
  }

  Future<void> _persistTrips(SharedPreferences prefs, List<SavedTrip> trips) async {
    final list = trips.map((t) => t.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }
}
