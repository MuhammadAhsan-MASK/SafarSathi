import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/hotels/models/hotel_model.dart';
import '../features/restaurants/models/restaurant_model.dart';
import '../features/transport/models/transport_model.dart';
import '../features/attractions/models/attraction_model.dart';
import 'data/hotels_data.dart';
import 'data/restaurants_data.dart';
import 'data/transport_data.dart';
import 'data/attractions_data.dart';

class SeedData {
  static List<Hotel> get initialHotels => allHotels;
  static List<Restaurant> get initialRestaurants => allRestaurants;
  static List<TransportOption> get initialTransports => allTransports;
  static List<Attraction> get initialAttractions => allAttractions;

  /// Seed all initial data into Cloud Firestore
  static Future<void> seedFirebase() async {
    final firestore = FirebaseFirestore.instance;
    for (var h in initialHotels) {
      await firestore.collection('hotels').doc(h.id).set(h.toMap(), SetOptions(merge: true));
    }
    for (var r in initialRestaurants) {
      await firestore.collection('restaurants').doc(r.id).set(r.toMap(), SetOptions(merge: true));
    }
    for (var t in initialTransports) {
      await firestore.collection('transport').doc(t.id).set(t.toMap(), SetOptions(merge: true));
    }
    for (var a in initialAttractions) {
      await firestore.collection('attractions').doc(a.id).set(a.toMap(), SetOptions(merge: true));
    }
  }
}
