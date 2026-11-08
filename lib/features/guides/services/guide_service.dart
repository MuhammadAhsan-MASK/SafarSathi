import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guide_model.dart';

class GuideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<LocalGuide>> getGuides() async* {
    final mockGuides = GuideMockService.fetchMockGuides();
    yield mockGuides;

    try {
      await for (final snapshot in _firestore.collection('guides').snapshots()) {
        final firestoreGuides = snapshot.docs.map((doc) => LocalGuide.fromFirestore(doc)).toList();
        yield [...firestoreGuides, ...mockGuides];
      }
    } catch (_) {
      yield mockGuides;
    }
  }

  Stream<List<LocalGuide>> getGuidesByVendor(String vendorId) {
    return _firestore
        .collection('guides')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LocalGuide.fromFirestore(doc)).toList();
    });
  }

  Future<void> addGuide(LocalGuide guide) async {
    final data = guide.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('guides').add(data);
  }

  Future<void> deleteGuide(String id) async {
    await _firestore.collection('guides').doc(id).delete();
  }
}
