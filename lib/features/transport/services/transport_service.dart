import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/transport_model.dart';
import '../../../core/seed_data.dart';

class TransportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool _matchesCity(String text, String city) {
    final t = text.trim().toLowerCase();
    final c = city.trim().toLowerCase();
    if (c.isEmpty || c == 'all' || c == 'all cities') return true;
    if (t.isEmpty) return false;
    if (t == c || (t.length >= 3 && c.contains(t)) || (c.length >= 3 && t.contains(c))) {
      return true;
    }

    // Handle common Pakistani abbreviations & aliases
    if ((c.contains('karachi') || c == 'khi') && (t.contains('karachi') || t == 'khi')) return true;
    if ((c.contains('islamabad') || c.contains('rawalpindi') || c == 'isb' || c == 'isd' || c == 'rwp') &&
        (t.contains('islamabad') || t.contains('rawalpindi') || t == 'isb' || t == 'isd' || t == 'rwp')) {
      return true;
    }
    if ((c.contains('lahore') || c == 'lhr') && (t.contains('lahore') || t == 'lhr')) return true;
    if ((c.contains('peshawar') || c == 'pew') && (t.contains('peshawar') || t == 'pew')) return true;
    if ((c.contains('skardu') || c == 'kdu') && (t.contains('skardu') || t == 'kdu')) return true;
    if ((c.contains('gilgit') || c.contains('hunza') || c == 'gil') &&
        (t.contains('gilgit') || t.contains('hunza') || t == 'gil')) {
      return true;
    }
    if (c.contains('swat') && t.contains('swat')) return true;
    if (c.contains('quetta') && t.contains('quetta')) return true;
    if (c.contains('multan') && t.contains('multan')) return true;
    if (c.contains('murree') && t.contains('murree')) return true;

    return false;
  }

  static bool isRouteMatch(String route, {String? source, String? destination}) {
    final r = route.toLowerCase();

    final hasSource = source != null &&
        source.trim().isNotEmpty &&
        source.trim().toLowerCase() != 'all' &&
        source.trim().toLowerCase() != 'all cities';
    final hasDest = destination != null &&
        destination.trim().isNotEmpty &&
        destination.trim().toLowerCase() != 'all' &&
        destination.trim().toLowerCase() != 'all cities';

    if (!hasSource && !hasDest) return true;

    // Route format often "Origin -> Destination" (avoid splitting inside words like "Attock")
    final parts = route.split(RegExp(r'\s*(?:->|\sto\s|\s-\s)\s*', caseSensitive: false));
    if (parts.length >= 2) {
      final originPart = parts.first;
      final destPart = parts.sublist(1).join(' -> ');

      if (hasSource && hasDest) {
        return _matchesCity(originPart, source) && _matchesCity(destPart, destination);
      }
      if (hasSource) return _matchesCity(originPart, source);
      if (hasDest) return _matchesCity(destPart, destination);
    }

    if (hasSource && hasDest) {
      return _matchesCity(r, source) && _matchesCity(r, destination);
    }
    if (hasSource) return _matchesCity(r, source);
    if (hasDest) return _matchesCity(r, destination);

    return true;
  }

  Stream<List<TransportOption>> getTransportOptions({String? source, String? destination, String? category}) async* {
    List<TransportOption> filterList(List<TransportOption> list) {
      final cat = category?.trim().toLowerCase();
      final hasCat = cat != null && cat.isNotEmpty && cat != 'all';

      var matched = list.where((t) {
        final routeOk = isRouteMatch(t.route, source: source, destination: destination);
        final catOk = !hasCat || t.category.toLowerCase() == cat;
        return routeOk && catOk;
      }).toList();

      // If exact route matching found options, return them
      if (matched.isNotEmpty) return matched;

      // Intelligent Connecting Route Fallback for unlisted pairs
      final hasSource = source != null &&
          source.trim().isNotEmpty &&
          source.trim().toLowerCase() != 'all' &&
          source.trim().toLowerCase() != 'all cities';
      final hasDest = destination != null &&
          destination.trim().isNotEmpty &&
          destination.trim().toLowerCase() != 'all' &&
          destination.trim().toLowerCase() != 'all cities';

      final sameCity = hasSource && hasDest && _matchesCity(source, destination);
      if (sameCity) return matched;

      if (hasSource && hasDest) {
        matched = generateConnectingOptions(source, destination, cat);
        if (matched.isNotEmpty) return matched;
      }

      // If still empty and category is 'train' for a mountain city, recommend bus & flight connections
      final isMountainDest = hasDest &&
          (destination.toLowerCase().contains('hunza') ||
              destination.toLowerCase().contains('skardu') ||
              destination.toLowerCase().contains('swat'));
      if (isMountainDest && cat == 'train' && (!_matchesCity(source ?? 'Islamabad', 'Islamabad') || !hasSource)) {
        return _generateMountainConnectingOptions(source ?? 'Islamabad', destination);
      }

      return matched;
    }

    // Always immediately yield seed data for instantaneous UI rendering
    yield filterList(SeedData.initialTransports);

    if (!SeedData.useSeedData) {
      try {
        await for (final snapshot in _firestore.collection('transport').snapshots()) {
          final firestoreTransports = snapshot.docs
              .map((doc) => TransportOption.fromFirestore(doc))
              .where((t) => t.isVerified)
              .toList();
          yield filterList(firestoreTransports);
        }
      } catch (_) {
        yield filterList(SeedData.initialTransports);
      }
      return;
    }

    try {
      await for (final snapshot in _firestore.collection('transport').snapshots()) {
        final firestoreTransports = snapshot.docs
            .map((doc) => TransportOption.fromFirestore(doc))
            .where((t) => t.isVerified)
            .toList();
        final combined = _mergeTransports(SeedData.initialTransports, firestoreTransports);
        yield filterList(combined);
      }
    } catch (_) {
      yield filterList(SeedData.initialTransports);
    }
  }

  static List<TransportOption> generateConnectingOptions(String src, String dst, [String? category]) {
    if (_matchesCity(src, dst)) return [];
    final list = <TransportOption>[];
    final isFlight = category == null || category == 'flight' || category == 'all';
    final isBus = category == null || category == 'bus' || category == 'all';
    final isTrain = category == null || category == 'train' || category == 'all';

    final isMountain = dst.toLowerCase().contains('hunza') || dst.toLowerCase().contains('skardu') || dst.toLowerCase().contains('swat');
    final srcIsIslamabad = _matchesCity(src, 'Islamabad');

    if (isFlight && !dst.toLowerCase().contains('swat')) {
      list.add(TransportOption(
        id: 'conn_flight_${src}_$dst',
        type: srcIsIslamabad ? 'PIA / AirSial Direct Northern Flight' : 'PIA / AirSial Connecting Flight',
        route: srcIsIslamabad ? '$src -> $dst' : '$src -> $dst (via Islamabad)',
        fare: srcIsIslamabad ? 22000 : 34000,
        time: srcIsIslamabad ? '1h 15m' : '3h 45m',
        icon: Icons.flight,
        vendorId: 'pia_official',
        websiteUrl: 'https://www.piac.com.pk/',
        category: 'flight',
        departureTime: '08:00',
        availableSeats: 16,
        operator: srcIsIslamabad ? 'Direct Air Service' : 'Connecting Flight (via ISB)',
        typePrices: srcIsIslamabad
            ? {'Economy': 22000, 'Business': 38000}
            : {'Economy': 34000, 'Business': 55000},
      ));
    }

    if (isBus) {
      list.add(TransportOption(
        id: 'conn_bus_${src}_$dst',
        type: 'Faisal Movers / Daewoo Luxury Transfer',
        route: '$src -> $dst (Intercity Express)',
        fare: 6200,
        time: '14h 00m',
        icon: Icons.directions_bus,
        vendorId: 'faisal_movers',
        websiteUrl: 'https://faisalmovers.com/',
        category: 'bus',
        departureTime: '09:00',
        availableSeats: 20,
        operator: 'Intercity Highway Service',
        typePrices: {'Executive': 6200, 'Super Luxury': 7800},
      ));
    }

    if (isTrain && !isMountain) {
      list.add(TransportOption(
        id: 'conn_train_${src}_$dst',
        type: 'Pakistan Railways Intercity',
        route: '$src -> $dst (Express Service)',
        fare: 4200,
        time: '16h 30m',
        icon: Icons.train,
        vendorId: 'pak_railways',
        websiteUrl: 'https://pakrail.gov.pk/',
        category: 'train',
        departureTime: '10:30',
        availableSeats: 35,
        operator: 'Pakistan Railways',
        typePrices: {'Economy': 2400, 'AC Std': 4200},
      ));
    }

    return list;
  }

  List<TransportOption> _generateMountainConnectingOptions(String src, String dst) {
    return [
      TransportOption(
        id: 'mtn_rail_natco_${src}_$dst',
        type: 'Green Line + NATCO Mountain Transfer',
        route: '$src -> $dst (Train to ISB + NATCO)',
        fare: 9200,
        time: '18h 00m',
        icon: Icons.train,
        vendorId: 'pak_railways',
        websiteUrl: 'https://pakrail.gov.pk/',
        category: 'train',
        departureTime: '06:00',
        availableSeats: 22,
        operator: 'Pak Railways + NATCO Combined',
        typePrices: {'Standard Combined': 9200, 'AC Sleeper + Deluxe': 14500},
      ),
    ];
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
