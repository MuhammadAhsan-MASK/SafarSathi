import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Hotel>> getHotels() {
    return _firestore.collection('hotels').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Hotel>> getHotelsByVendor(String vendorId) {
    return _firestore
        .collection('hotels')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addHotel(Hotel hotel) async {
    final data = hotel.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('hotels').add(data);
  }

  Future<void> deleteHotel(String id) async {
    await _firestore.collection('hotels').doc(id).delete();
  }

  Stream<List<Hotel>> searchHotels(String query) {
    return _firestore
        .collection('hotels')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    });
  }
}
