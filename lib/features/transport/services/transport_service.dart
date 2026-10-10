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

  String? getSeasonalWarning(String source, String destination) {
    final s = source.toLowerCase();
    final d = destination.toLowerCase();
    final month = DateTime.now().month;

    bool involvesNaran(String text) => text.contains('naran') || text.contains('babusar') || text.contains('chilas');
    bool involvesDeosai(String text) => text.contains('deosai') || text.contains('astor');
    bool involvesKhunjerab(String text) => text.contains('khunjerab') || text.contains('sost');

    if (involvesNaran(s) || involvesNaran(d)) {
      // Typically closed Nov (11) to May (5)
      if (month < 6 || month > 10) {
        return "⚠️ Babusar Top is currently closed due to snow. Alternate route via KKH is required.";
      }
    }
    if (involvesDeosai(s) || involvesDeosai(d)) {
      if (month < 7 || month > 9) {
        return "⚠️ Deosai Plains are inaccessible due to heavy snow. Jeep tracks are blocked.";
      }
    }
    if (involvesKhunjerab(s) || involvesKhunjerab(d)) {
      if (month < 4 || month > 11) {
        return "⚠️ Khunjerab Pass is closed for tourists during winter due to extreme cold.";
      }
    }
    
    return null;
  }
}
