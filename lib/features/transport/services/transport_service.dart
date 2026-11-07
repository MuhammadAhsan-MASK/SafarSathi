import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transport_model.dart';
import '../../../core/seed_data.dart';

class TransportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool isRouteMatch(String route, {String? source, String? destination}) {
    final r = route.toLowerCase();
    
    bool matchesCity(String text, String city) {
      final c = city.trim().toLowerCase();
      if (c.isEmpty) return true;
      if (text.contains(c)) return true;

      // Handle common Pakistani abbreviations
      if ((c.contains('karachi') || c == 'khi') && (text.contains('karachi') || text.contains('khi'))) return true;
      if ((c.contains('islamabad') || c.contains('rawalpindi') || c == 'isb' || c == 'isd' || c == 'rwp') &&
          (text.contains('islamabad') || text.contains('rawalpindi') || text.contains('isb') || text.contains('isd') || text.contains('rwp'))) {
        return true;
      }
      if ((c.contains('lahore') || c == 'lhr') && (text.contains('lahore') || text.contains('lhr'))) return true;
      if ((c.contains('peshawar') || c == 'pew') && (text.contains('peshawar') || text.contains('pew'))) return true;
      if ((c.contains('skardu') || c == 'kdu') && (text.contains('skardu') || text.contains('kdu'))) return true;
      if ((c.contains('gilgit') || c.contains('hunza') || c == 'gil') &&
          (text.contains('gilgit') || text.contains('hunza') || text.contains('gil'))) {
        return true;
      }
      if (c.contains('swat') && text.contains('swat')) return true;
      if (c.contains('murree') && text.contains('murree')) return true;

      return false;
    }

    final hasSource = source != null && source.trim().isNotEmpty;
    final hasDest = destination != null && destination.trim().isNotEmpty;

    if (!hasSource && !hasDest) return true;

    // Route format often "Origin -> Destination"
    if (route.contains('->') || route.contains(' to ') || route.contains('-')) {
      final parts = route.split(RegExp(r'->|to|-'));
      if (parts.length >= 2) {
        final originPart = parts[0];
        final destPart = parts[1];

        if (hasSource && hasDest) {
          return matchesCity(originPart, source) && matchesCity(destPart, destination);
        }
        if (hasSource) return matchesCity(originPart, source);
        if (hasDest) return matchesCity(destPart, destination);
      }
    }

    if (hasSource && hasDest) {
      return matchesCity(r, source) && matchesCity(r, destination);
    }
    if (hasSource) return matchesCity(r, source);
    if (hasDest) return matchesCity(r, destination);

    return true;
  }

  Stream<List<TransportOption>> getTransportOptions({String? source, String? destination, String? category}) async* {
    List<TransportOption> filterList(List<TransportOption> list) {
      return list.where((t) {
        final routeOk = isRouteMatch(t.route, source: source, destination: destination);
        final catOk = category == null || category.isEmpty || t.category == category;
        return routeOk && catOk;
      }).toList();
    }

    if (!SeedData.useSeedData) {
      try {
        await for (final snapshot in _firestore.collection('transport').snapshots()) {
          final firestoreTransports = snapshot.docs.map((doc) => TransportOption.fromFirestore(doc)).toList();
          yield filterList(firestoreTransports);
        }
      } catch (_) {
        yield [];
      }
      return;
    }

    // Immediately yield seed transports matching route + category
    yield filterList(SeedData.initialTransports);

    try {
      await for (final snapshot in _firestore.collection('transport').snapshots()) {
        final firestoreTransports = snapshot.docs.map((doc) => TransportOption.fromFirestore(doc)).toList();
        final combined = _mergeTransports(SeedData.initialTransports, firestoreTransports);
        yield filterList(combined);
      }
    } catch (_) {
      yield filterList(SeedData.initialTransports);
    }
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

  List<TransportOption> _mergeTransports(List<TransportOption> priorityList, List<TransportOption> secondaryList) {
    final Map<String, TransportOption> map = {};
    for (var t in secondaryList) {
      map[t.id] = t;
    }
    for (var t in priorityList) {
      map[t.id] = t;
    }
    return map.values.toList();
  }
}
