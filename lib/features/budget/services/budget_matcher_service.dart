import 'package:cloud_firestore/cloud_firestore.dart';
import '../../hotels/models/hotel_model.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../transport/models/transport_model.dart';
import '../../transport/services/transport_service.dart';
import '../../attractions/models/attraction_model.dart';
import '../../../core/seed_data.dart';

class BudgetMatcherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Set<String> _ignoredCityTokens = {
    'valley',
    'city',
    'town',
    'north',
    'south',
    'park',
    'hill',
    'hills',
    'lake',
    'pass',
    'fort',
  };

  static bool _matchesCity(String location, String destination) {
    final loc = location.trim().toLowerCase();
    final dest = destination.trim().toLowerCase();
    if (dest.isEmpty) return true;
    if (loc.isEmpty) return false;

    if (loc.contains(dest) || (loc.length >= 3 && dest.contains(loc))) return true;
    for (var part in dest.split(RegExp(r'[, -]'))) {
      final token = part.trim();
      if (token.length >= 3 && !_ignoredCityTokens.contains(token) && loc.contains(token)) {
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
    if (dest.contains('hunza') && (loc.contains('hunza') || loc.contains('karimabad') || loc.contains('attabad') || loc.contains('aliabad') || loc.contains('passu') || loc.contains('duikar'))) {
      return true;
    }
    if (dest.contains('skardu') && (loc.contains('skardu') || loc.contains('shigar') || loc.contains('kachura') || loc.contains('deosai') || loc.contains('satpara'))) {
      return true;
    }
    if (dest.contains('swat') && (loc.contains('swat') || loc.contains('saidu') || loc.contains('mingora') || loc.contains('kalam') || loc.contains('madyan') || loc.contains('marghazar'))) {
      return true;
    }
    if (dest.contains('murree') && (loc.contains('murree') || loc.contains('bhurban') || loc.contains('jhika') || loc.contains('galyat') || loc.contains('nathia'))) {
      return true;
    }
    if ((dest.contains('naran') || dest.contains('kaghan')) && (loc.contains('naran') || loc.contains('kaghan') || loc.contains('shogran') || loc.contains('saif') || loc.contains('babusar'))) {
      return true;
    }
    if (dest.contains('gilgit') && (loc.contains('gilgit') || loc.contains('chinar') || loc.contains('karakoram'))) {
      return true;
    }
    if (dest.contains('chitral') && (loc.contains('chitral') || loc.contains('kalash') || loc.contains('ayun') || loc.contains('tirich'))) {
      return true;
    }
    if (dest.contains('gwadar') && (loc.contains('gwadar') || loc.contains('marine') || loc.contains('makran') || loc.contains('ormara'))) {
      return true;
    }
    if (dest.contains('multan') && (loc.contains('multan') || loc.contains('nishtar') || loc.contains('abdali'))) {
      return true;
    }
    if (dest.contains('peshawar') && (loc.contains('peshawar') || loc.contains('khyber') || loc.contains('qissa'))) {
      return true;
    }
    if (dest.contains('quetta') && (loc.contains('quetta') || loc.contains('zarghoon') || loc.contains('ziarat'))) {
      return true;
    }
    if (dest.contains('faisalabad') && loc.contains('faisalabad')) {
      return true;
    }

    return false;
  }

  Future<List<Hotel>> getAffordableHotels(String destination, double maxPricePerNight) async {
    List<Hotel> allHotels = [...SeedData.initialHotels];
    try {
      final snapshot = await _firestore.collection('hotels').get().timeout(const Duration(milliseconds: 1500));
      final firestoreHotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      for (var fh in firestoreHotels) {
        if (!allHotels.any((h) => h.id == fh.id)) {
          allHotels.add(fh);
        }
      }
    } catch (_) {}

    // Strictly match destination city ONLY
    final destinationHotels = allHotels.where((h) => _matchesCity(h.location, destination)).toList();

    double getLowestPrice(Hotel h) {
      if (h.typePrices.isNotEmpty) {
        final positives = h.typePrices.values.where((v) => v > 0);
        if (positives.isNotEmpty) {
          return positives.reduce((a, b) => a < b ? a : b);
        }
      }
      return h.price > 0 ? h.price : 3500.0;
    }

    // Filter strictly by calculated nightly budget cap — never return over-budget hotels
    final budgetMatches = destinationHotels.where((h) => getLowestPrice(h) <= maxPricePerNight).toList();
    budgetMatches.sort((a, b) => getLowestPrice(a).compareTo(getLowestPrice(b)));
    return budgetMatches;
  }

  Future<List<Restaurant>> getAffordableRestaurants(String destination, double maxPricePerMeal) async {
    List<Restaurant> allRestaurants = [...SeedData.initialRestaurants];
    try {
      final snapshot = await _firestore.collection('restaurants').get().timeout(const Duration(milliseconds: 1500));
      final firestoreRests = snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
      for (var fr in firestoreRests) {
        if (!allRestaurants.any((r) => r.id == fr.id)) {
          allRestaurants.add(fr);
        }
      }
    } catch (_) {}

    // Strictly match destination city ONLY
    final destinationRests = allRestaurants.where((r) => _matchesCity(r.location, destination)).toList();

    double getLowestMealPrice(Restaurant r) {
      if (r.typePrices.isNotEmpty) {
        final minPrice = r.typePrices.values.reduce((a, b) => a < b ? a : b);
        if (minPrice > 0) return minPrice;
      }
      return r.price > 0 ? r.price : 600.0;
    }

    if (destinationRests.isEmpty) {
      return [];
    }

    final budgetMatches = destinationRests.where((r) => getLowestMealPrice(r) <= maxPricePerMeal).toList();
    if (budgetMatches.isNotEmpty) {
      budgetMatches.sort((a, b) => getLowestMealPrice(a).compareTo(getLowestMealPrice(b)));
      return budgetMatches;
    }

    destinationRests.sort((a, b) => getLowestMealPrice(a).compareTo(getLowestMealPrice(b)));
    return destinationRests;
  }

  Future<List<TransportOption>> getAffordableTransport({
    required String origin,
    required String destination,
    double? maxFare,
  }) async {
    List<TransportOption> allTrans = [...SeedData.initialTransports];
    try {
      final snapshot = await _firestore.collection('transport').get().timeout(const Duration(milliseconds: 1500));
      final firestoreTrans = snapshot.docs.map((doc) => TransportOption.fromFirestore(doc)).toList();
      for (var ft in firestoreTrans) {
        if (!allTrans.any((t) => t.id == ft.id)) {
          allTrans.add(ft);
        }
      }
    } catch (_) {}

    // 1. Filter strictly by route: Origin -> Destination
    final routeMatches = allTrans.where((t) {
      return TransportService.isRouteMatch(t.route, source: origin, destination: destination);
    }).toList();

    List<TransportOption> candidates = [];

    if (routeMatches.isNotEmpty) {
      candidates = routeMatches;
    } else {
      // Intelligently generate connecting intercity options for any unlisted city pair
      final connecting = TransportService.generateConnectingOptions(origin, destination);
      if (connecting.isNotEmpty) {
        candidates = connecting;
      } else {
        candidates = allTrans;
      }
    }

    // Filter strictly by calculated budget cap if possible
    if (maxFare != null && maxFare > 0) {
      final affordable = candidates.where((t) => t.fare <= maxFare).toList();
      if (affordable.isNotEmpty) {
        affordable.sort((a, b) => a.fare.compareTo(b.fare));
        return affordable;
      }
    }

    // Sort: lowest fare first
    candidates.sort((a, b) => a.fare.compareTo(b.fare));
    return candidates;
  }

  Future<List<Attraction>> getAffordableAttractions(String destination, double maxActivityFee) async {
    List<Attraction> allAttractions = [...SeedData.initialAttractions];
    try {
      final snapshot = await _firestore.collection('attractions').get().timeout(const Duration(milliseconds: 1500));
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

    // Filter strictly within calculated activity budget
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
