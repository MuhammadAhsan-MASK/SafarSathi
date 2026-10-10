import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Restaurant>> getRestaurants() {
    return _firestore.collection('restaurants').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    });
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
    if (query.isEmpty) {
      yield [];
      return;
    }
    
    // In emulator 10.0.2.2 represents localhost of the host machine
    // For physical device, change this to your computer's local network IP (e.g., 192.168.x.x)
    const baseUrl = 'http://10.0.2.2:8000';
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/restaurants?city=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List restaurantsJson = data['restaurants'] ?? [];
        
        final apiRestaurants = restaurantsJson.map((jsonItem) => Restaurant(
          id: jsonItem['id'].toString(),
          name: jsonItem['name'].toString(),
          cuisine: jsonItem['rating'] != null ? 'Rating: ${jsonItem['rating']}' : 'General',
          price: 1000, // placeholder average price
          location: data['city'] ?? query,
          vendorId: 'foodpanda',
          typePrices: {},
          imageUrl: (jsonItem['image_url'] != null && jsonItem['image_url'].toString().isNotEmpty) 
              ? jsonItem['image_url'] 
              : null,
          websiteUrl: (jsonItem['website_url'] ?? jsonItem['url'])?.toString(),
        )).toList();
        
        yield apiRestaurants;
      } else {
        yield [];
      }
    } catch (e) {
      print('Proxy/Scraper API error: $e');
      yield [];
    }
  }
}
