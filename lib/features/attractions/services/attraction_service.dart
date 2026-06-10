import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attraction_model.dart';

class AttractionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Attraction>> getAttractions() {
    return _firestore.collection('attractions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Attraction.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Attraction>> getAttractionsByVendor(String vendorId) {
    return _firestore
        .collection('attractions')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Attraction.fromFirestore(doc)).toList();
    });
  }

  Future<void> addAttraction(Attraction attraction) async {
    final data = attraction.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('attractions').add(data);
  }

  Future<void> deleteAttraction(String id) async {
    await _firestore.collection('attractions').doc(id).delete();
  }
}
