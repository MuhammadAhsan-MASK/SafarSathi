import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../../../core/seed_data.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Restaurant>> getRestaurants() async* {
    if (!SeedData.useSeedData) {
      try {
        await for (final snapshot in _firestore.collection('restaurants').snapshots()) {
          yield snapshot.docs
              .map((doc) => Restaurant.fromFirestore(doc))
              .where((r) => r.isVerified)
              .toList();
        }
      } catch (_) {
        yield [];
      }
      return;
    }

    yield SeedData.initialRestaurants;

    try {
      await for (final snapshot in _firestore.collection('restaurants').snapshots()) {
        final firestoreRestaurants = snapshot.docs
            .map((doc) => Restaurant.fromFirestore(doc))
            .where((r) => r.isVerified)
            .toList();
        yield _mergeRestaurants(SeedData.initialRestaurants, firestoreRestaurants);
      }
    } catch (_) {
      yield SeedData.initialRestaurants;
    }
  }

  Stream<List<Restaurant>> getRestaurantsByVendor(String vendorId) {
    return _firestore
        .collection('restaurants')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    });
  }

  Future<void> addRestaurant(Restaurant restaurant) async {
    final data = restaurant.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('restaurants').add(data);
  }

  Future<void> deleteRestaurant(String id) async {
    await _firestore.collection('restaurants').doc(id).delete();
  }

  Stream<List<Restaurant>> searchRestaurants(String query) async* {
    final lowerQuery = query.trim().toLowerCase();

    bool matches(Restaurant r) {
      if (!r.isVerified) return false;
      if (lowerQuery.isEmpty) return true;
      return r.name.toLowerCase().contains(lowerQuery) ||
             r.location.toLowerCase().contains(lowerQuery) ||
             r.cuisine.toLowerCase().contains(lowerQuery) ||
             (r.description?.toLowerCase().contains(lowerQuery) ?? false);
    }

    // Immediately yield matching from in-memory authentic catalog
    final localMatches = SeedData.initialRestaurants.where(matches).toList();
    yield localMatches;

    // Next try Firestore
    try {
      await for (final snapshot in _firestore.collection('restaurants').snapshots()) {
        final firestoreRestaurants = snapshot.docs
            .map((doc) => Restaurant.fromFirestore(doc))
            .where((r) => r.isVerified)
            .toList();
        final combined = _mergeRestaurants(SeedData.initialRestaurants, firestoreRestaurants);
        final filtered = combined.where(matches).toList();

        // If local/firestore found items, yield them
        if (filtered.isNotEmpty || lowerQuery.isEmpty) {
          yield filtered;
        } else {
          // If empty, try optional scraper API as secondary source
          final apiResults = await _tryApiSearch(query);
          if (apiResults.isNotEmpty) {
            yield apiResults;
          } else {
            yield filtered;
          }
        }
      }
    } catch (_) {
      yield localMatches;
    }
  }

  Future<List<Restaurant>> _tryApiSearch(String query) async {
    const baseUrl = 'http://10.0.2.2:8000';
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/restaurants?city=$query')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List restaurantsJson = data['restaurants'] ?? [];
        return restaurantsJson.map((jsonItem) => Restaurant(
          id: jsonItem['id'].toString(),
          name: jsonItem['name'].toString(),
          cuisine: jsonItem['rating'] != null ? 'Rating: ${jsonItem['rating']}' : 'General',
          price: 1200,
          location: data['city'] ?? query,
          vendorId: 'foodpanda',
          typePrices: {},
          imageUrl: (jsonItem['image_url'] != null && jsonItem['image_url'].toString().isNotEmpty) 
              ? jsonItem['image_url'] 
              : null,
          websiteUrl: (jsonItem['website_url'] ?? jsonItem['url'])?.toString(),
        )).toList();
      }
    } catch (_) {}
    return [];
  }

  List<Restaurant> _mergeRestaurants(List<Restaurant> priorityList, List<Restaurant> secondaryList) {
    final Map<String, Restaurant> map = {};
    for (var r in secondaryList) {
      map[r.id] = r;
    }
    for (var r in priorityList) {
      map[r.id] = r;
    }
    return map.values.toList();
  }
}
