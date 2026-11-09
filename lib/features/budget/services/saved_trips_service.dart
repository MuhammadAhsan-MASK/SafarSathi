import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_trip_model.dart';

class SavedTripsService {
  static const String _storageKey = 'safar_saved_trips';
  static final SavedTripsService _instance = SavedTripsService._internal();

  factory SavedTripsService() => _instance;
  SavedTripsService._internal();

  final ValueNotifier<List<SavedTrip>> tripsNotifier = ValueNotifier<List<SavedTrip>>([]);

  List<SavedTrip> _curatedDefaults() {
    final now = DateTime.now();
    return [
      SavedTrip(
        id: 'trip_murree_hills',
        title: 'Murree Hills Getaway',
        destination: 'Murree',
        origin: 'Islamabad',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 2)),
        budget: 38000,
        travelers: 3,
        companions: ['Ali', 'Hamza', 'Ahsan'],
        notes: 'Weekend mountain retreat via Murree Expressway with dining at Mall Road & Patriata chairlift.',
        isCurrent: true,
      ),
      SavedTrip(
        id: 'trip_hunza_autumn',
        title: 'Hunza Autumn Expedition',
        destination: 'Hunza',
        origin: 'Islamabad',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 16)),
        budget: 95000,
        travelers: 4,
        companions: ['Ali', 'Hamza', 'Ahsan', 'Bilal'],
        notes: 'Golden autumn tour covering Karimabad, Attabad Lake, Passu Cones, and Baltit Fort.',
        isCurrent: false,
      ),
      SavedTrip(
        id: 'trip_swat_valley',
        title: 'Swat Valley River Tour',
        destination: 'Swat',
        origin: 'Peshawar',
        startDate: now.add(const Duration(days: 25)),
        endDate: now.add(const Duration(days: 29)),
        budget: 48000,
        travelers: 3,
        companions: ['Kamran', 'Farhan', 'Me'],
        notes: 'Explore Malam Jabba, Kalam, and Mahodand Lake trout spots.',
        isCurrent: false,
      ),
    ];
  }

  Future<List<SavedTrip>> getSavedTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonString);
        final trips = list.map((m) => SavedTrip.fromMap(Map<String, dynamic>.from(m))).toList();
        if (trips.isNotEmpty) {
          tripsNotifier.value = trips;
          return trips;
        }
      }

      // Initialize with curated defaults
      final defaults = _curatedDefaults();
      await _persistTrips(prefs, defaults);
      tripsNotifier.value = defaults;
      return defaults;
    } catch (e) {
      debugPrint('Error getting saved trips: $e');
      final fallback = _curatedDefaults();
      tripsNotifier.value = fallback;
      return fallback;
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
        // Update existing
        updatedTrips = List.from(trips);
        updatedTrips[index] = trip;
      } else {
        // Add new trip to the beginning
        updatedTrips = [trip, ...trips];
      }

      // If marked current, unset current for others
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

      // Ensure at least one is current if any remain
      if (updatedTrips.isNotEmpty && !updatedTrips.any((t) => t.isCurrent)) {
        updatedTrips[0] = updatedTrips[0].copyWith(isCurrent: true);
      }

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
