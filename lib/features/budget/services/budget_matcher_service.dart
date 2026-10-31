import 'package:cloud_firestore/cloud_firestore.dart';
import '../../hotels/models/hotel_model.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../transport/models/transport_model.dart';
import '../../transport/services/transport_service.dart';
import '../../attractions/models/attraction_model.dart';
import '../../../core/seed_data.dart';

class BudgetMatcherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool _matchesCity(String location, String destination) {
    final loc = location.toLowerCase();
    final dest = destination.trim().toLowerCase();
    if (dest.isEmpty) return true;

    if (loc.contains(dest)) return true;
    for (var part in dest.split(RegExp(r'[, -]'))) {
      if (part.trim().length >= 3 && loc.contains(part.trim())) {
        return true;
      }
    }

    // Common city aliases
    if ((dest.contains('isb') || dest.contains('islamabad') || dest.contains('rawalpindi')) &&
        (loc.contains('islamabad') || loc.contains('rawalpindi') || loc.contains('isb'))) {
      return true;
    }
    if ((dest.contains('khi') || dest.contains('karachi')) && (loc.contains('karachi') || loc.contains('khi'))) {
      return true;
    }
    if ((dest.contains('lhr') || dest.contains('lahore')) && (loc.contains('lahore') || loc.contains('lhr'))) {
      return true;
    }
    if (dest.contains('hunza') && (loc.contains('hunza') || loc.contains('karimabad') || loc.contains('attabad'))) {
      return true;
    }
    if (dest.contains('skardu') && (loc.contains('skardu') || loc.contains('shigar') || loc.contains('kachura'))) {
      return true;
    }
    if (dest.contains('swat') && (loc.contains('swat') || loc.contains('saidu') || loc.contains('mingora'))) {
      return true;
    }
    if (dest.contains('murree') && (loc.contains('murree') || loc.contains('bhurban'))) {
      return true;
    }

    return false;
  }

  Future<List<Hotel>> getAffordableHotels(String destination, double maxPricePerNight) async {
    List<Hotel> allHotels = [...SeedData.initialHotels];
    try {
      final snapshot = await _firestore.collection('hotels').get();
      final firestoreHotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      for (var fh in firestoreHotels) {
        if (!allHotels.any((h) => h.id == fh.id)) {
          allHotels.add(fh);
        }
      }
    } catch (_) {}

    // Strictly match destination city ONLY
    final destinationHotels = allHotels.where((h) => _matchesCity(h.location, destination)).toList();

    if (destinationHotels.isEmpty) {
      return [];
    }

    // Within destination, filter by budget if possible
    final budgetMatches = destinationHotels.where((h) => (h.price > 0 ? h.price : 4000.0) <= maxPricePerNight).toList();
    if (budgetMatches.isNotEmpty) {
      budgetMatches.sort((a, b) => a.price.compareTo(b.price));
      return budgetMatches;
    }

    // Return destination hotels sorted by price (NEVER fall back to other cities)
    destinationHotels.sort((a, b) => a.price.compareTo(b.price));
    return destinationHotels;
  }

  Future<List<Restaurant>> getAffordableRestaurants(String destination, double maxPricePerMeal) async {
    List<Restaurant> allRestaurants = [...SeedData.initialRestaurants];
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      final firestoreRests = snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
      for (var fr in firestoreRests) {
        if (!allRestaurants.any((r) => r.id == fr.id)) {
          allRestaurants.add(fr);
        }
      }
    } catch (_) {}

    // Strictly match destination city ONLY
    final destinationRests = allRestaurants.where((r) => _matchesCity(r.location, destination)).toList();

    if (destinationRests.isEmpty) {
      return [];
    }

    final budgetMatches = destinationRests.where((r) => (r.price > 0 ? r.price : 800.0) <= maxPricePerMeal).toList();
    if (budgetMatches.isNotEmpty) {
      budgetMatches.sort((a, b) => a.price.compareTo(b.price));
      return budgetMatches;
    }

    destinationRests.sort((a, b) => a.price.compareTo(b.price));
    return destinationRests;
  }

  Future<List<TransportOption>> getAffordableTransport({
    required String origin,
    required String destination,
    double? maxFare,
  }) async {
    List<TransportOption> allTrans = [...SeedData.initialTransports];
    try {
      final snapshot = await _firestore.collection('transport').get();
      final firestoreTrans = snapshot.docs.map((doc) => TransportOption.fromFirestore(doc)).toList();
      for (var ft in firestoreTrans) {
        if (!allTrans.any((t) => t.id == ft.id)) {
          allTrans.add(ft);
        }
      }
    } catch (_) {}

    // Filter strictly by route: Origin -> Destination
    final routeMatches = allTrans.where((t) {
      return TransportService.isRouteMatch(t.route, source: origin, destination: destination);
    }).toList();

    if (routeMatches.isEmpty) {
      // If no exact direct route, find any options containing destination or origin
      final partialMatches = allTrans.where((t) {
        return TransportService.isRouteMatch(t.route, source: origin) ||
               TransportService.isRouteMatch(t.route, destination: destination);
      }).toList();
      if (partialMatches.isNotEmpty) {
        if (maxFare != null && maxFare > 0) {
          final affordable = partialMatches.where((t) => t.fare <= maxFare).toList();
          if (affordable.isNotEmpty) {
            affordable.sort((a, b) => a.fare.compareTo(b.fare));
            return affordable;
          }
        }
        partialMatches.sort((a, b) => a.fare.compareTo(b.fare));
        return partialMatches;
      }
      return [];
    }

    if (maxFare != null && maxFare > 0) {
      final affordable = routeMatches.where((t) => t.fare <= maxFare).toList();
      if (affordable.isNotEmpty) {
        affordable.sort((a, b) => a.fare.compareTo(b.fare));
        return affordable;
      }
    }

    // Sort: lowest fare first
    routeMatches.sort((a, b) => a.fare.compareTo(b.fare));
    return routeMatches;
  }

  Future<List<Attraction>> getAffordableAttractions(String destination, double maxActivityFee) async {
    List<Attraction> allAttractions = [...SeedData.initialAttractions];
    try {
      final snapshot = await _firestore.collection('attractions').get();
      final firestoreAttractions = snapshot.docs.map((doc) => Attraction.fromFirestore(doc)).toList();
      for (var fa in firestoreAttractions) {
        if (!allAttractions.any((a) => a.id == fa.id)) {
          allAttractions.add(fa);
        }
      }
    } catch (_) {}

    // Strictly match destination city ONLY
    final destinationAttractions = allAttractions.where((a) => _matchesCity(a.city, destination) || _matchesCity(a.location ?? '', destination)).toList();

    if (destinationAttractions.isEmpty) {
      return [];
    }

    // Filter within budget if possible
    final budgetMatches = destinationAttractions.where((a) => a.fee <= maxActivityFee).toList();
    if (budgetMatches.isNotEmpty) {
      budgetMatches.sort((a, b) => a.fee.compareTo(b.fee));
      return budgetMatches;
    }

    // Sort by fee (free first)
    destinationAttractions.sort((a, b) => a.fee.compareTo(b.fee));
    return destinationAttractions;
  }
}
