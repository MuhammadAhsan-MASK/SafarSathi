import 'package:cloud_firestore/cloud_firestore.dart';
import '../../hotels/models/hotel_model.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../transport/models/transport_model.dart';

class BudgetMatcherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Hotel>> getAffordableHotels(String destination, double maxPricePerNight) async {
    try {
      final snapshot = await _firestore.collection('hotels').get();
      final allHotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      
      final results = allHotels.where((h) {
        final matchDest = h.location.toLowerCase().contains(destination.toLowerCase()) || 
                          destination.toLowerCase().contains(h.location.toLowerCase().split(',').first);
        final matchBudget = (h.price > 0 ? h.price : 4000.0) <= maxPricePerNight;
        // Priority to budget. If location doesn't strictly match but budget does, it might still show as fallback.
        return matchDest && matchBudget;
      }).toList();

      // Fallback if no exact destination matches but we have cheap hotels (for demo purposes)
      if (results.isEmpty) {
         return allHotels.where((h) => h.price <= maxPricePerNight).toList();
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<Restaurant>> getAffordableRestaurants(String destination, double maxPricePerMeal) async {
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      final allRests = snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
      
      final results = allRests.where((r) {
        final matchDest = r.location.toLowerCase().contains(destination.toLowerCase()) || 
                          destination.toLowerCase().contains(r.location.toLowerCase().split(',').first);
        final matchBudget = (r.price > 0 ? r.price : 800.0) <= maxPricePerMeal;
        return matchDest && matchBudget;
      }).toList();

      if (results.isEmpty) {
         return allRests.where((r) => r.price <= maxPricePerMeal).toList();
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<TransportOption>> getAffordableTransport(String destination, double maxFare) async {
    try {
      final snapshot = await _firestore.collection('transport').get();
      final allTrans = snapshot.docs.map((doc) => TransportOption.fromFirestore(doc)).toList();
      
      // For transport, route is like "ISD -> LHR". It's harder to string match exactly without complex parsing.
      // We rely heavily on the budget filter.
      final results = allTrans.where((t) {
        final matchDest = t.route.toLowerCase().contains(destination.toLowerCase().substring(0, destination.length > 3 ? 3 : destination.length));
        final matchBudget = t.fare <= maxFare;
        return matchDest && matchBudget;
      }).toList();

      if (results.isEmpty) {
        return allTrans.where((t) => t.fare <= maxFare).toList()..sort((a,b) => a.fare.compareTo(b.fare));
      }
      return results;
    } catch (e) {
      return [];
    }
  }
}
