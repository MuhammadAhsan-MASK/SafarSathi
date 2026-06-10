import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transport_model.dart';

class TransportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransportOption>> getTransportOptions({String? source, String? destination}) {
    Query query = _firestore.collection('transport');
    
    // Simple filter if provided
    if (source != null && source.isNotEmpty) {
      query = query.where('route', isGreaterThanOrEqualTo: source);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TransportOption.fromFirestore(doc)).toList();
    });
  }

  Stream<List<TransportOption>> getTransportOptionsByVendor(String vendorId) {
    return _firestore
        .collection('transport')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TransportOption.fromFirestore(doc)).toList();
    });
  }

  Future<void> addTransportOption(TransportOption option) async {
    final data = option.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('transport').add(data);
  }

  Future<void> deleteTransportOption(String id) async {
    await _firestore.collection('transport').doc(id).delete();
  }
}
