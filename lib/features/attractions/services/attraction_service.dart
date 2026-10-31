import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attraction_model.dart';
import '../../../core/seed_data.dart';

class AttractionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Attraction>> getAttractions({String? city, String? type}) async* {
    // 1. Immediately yield filtered seed data
    yield _filter(SeedData.initialAttractions, city: city, type: type);

    // 2. Stream and merge with Firestore
    try {
      await for (final snapshot in _firestore.collection('attractions').snapshots()) {
        final firestoreList = snapshot.docs.map((doc) => Attraction.fromFirestore(doc)).toList();
        final merged = _mergeAttractions(SeedData.initialAttractions, firestoreList);
        yield _filter(merged, city: city, type: type);
      }
    } catch (_) {
      yield _filter(SeedData.initialAttractions, city: city, type: type);
    }
  }

  List<Attraction> _filter(List<Attraction> list, {String? city, String? type}) {
    return list.where((a) {
      if (city != null && city.isNotEmpty && city.toLowerCase() != 'all') {
        if (!a.city.toLowerCase().contains(city.toLowerCase())) {
          return false;
        }
      }
      if (type != null && type.isNotEmpty && type.toLowerCase() != 'all') {
        if (a.type.toLowerCase() != type.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<Attraction> _mergeAttractions(List<Attraction> seed, List<Attraction> remote) {
    final Map<String, Attraction> map = {};
    for (var a in seed) {
      map[a.id] = a;
    }
    for (var a in remote) {
      map[a.id] = a;
    }
    return map.values.toList();
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
