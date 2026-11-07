import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/hotel_model.dart';
import '../../../core/seed_data.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache the CSV hotels to avoid reading from disk on every search/render
  List<Hotel>? _cachedCsvHotels;

  Future<List<Hotel>> _loadCsvHotels() async {
    if (_cachedCsvHotels != null) return _cachedCsvHotels!;

    try {
      final rawData = await rootBundle.loadString('assets/hotels/Pakistan_Tourism_Hotels.csv');
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
      
      List<Hotel> csvHotels = [];
      for (int i = 1; i < listData.length; i++) {
        var row = listData[i];
        if (row.length >= 16) {
          String idStr = row[0].toString();
          String nameStr = row[1].toString().replaceAll('_', ' ');
          String cityStr = row[2].toString();
          double price = double.tryParse(row[9].toString().replaceAll(',', '')) ?? 0.0;
          double rating = double.tryParse(row[16].toString()) ?? 4.0;

          const hotelImages = [
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
            'https://images.unsplash.com/photo-1542314831-c6a4d2757271?w=800',
            'https://images.unsplash.com/photo-1551882547-ff40c0dffe19?w=800',
            'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
            'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
            'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          ];
          final imgUrl = hotelImages[i % hotelImages.length];

          csvHotels.add(Hotel(
            id: idStr,
            name: nameStr,
            location: cityStr,
            price: price,
            rating: rating,
            imageUrl: imgUrl,
            websiteUrl: null,
            vendorId: 'csv_data',
          ));
        }
      }
      _cachedCsvHotels = csvHotels;
      return csvHotels;
    } catch (e) {
      return [];
    }
  }

  Stream<List<Hotel>> getHotels() async* {
    if (!SeedData.useSeedData) {
      try {
        await for (final snapshot in _firestore.collection('hotels').snapshots()) {
          yield snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
        }
      } catch (_) {
        yield [];
      }
      return;
    }

    List<Hotel> csvHotels = await _loadCsvHotels();
    
    // First yield initial authentic seed hotels + CSV immediately
    yield _mergeHotels(SeedData.initialHotels, csvHotels);
    
    try {
      await for (final snapshot in _firestore.collection('hotels').snapshots()) {
        final firestoreHotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
        yield _mergeHotels(SeedData.initialHotels, [...firestoreHotels, ...csvHotels]);
      }
    } catch (_) {
      // Yield cached seed + CSV if firestore is offline
      yield _mergeHotels(SeedData.initialHotels, csvHotels);
    }
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

  Stream<List<Hotel>> searchHotels(String query) async* {
    final lowerQuery = query.trim().toLowerCase();
    List<Hotel> csvHotels = await _loadCsvHotels();

    bool matches(Hotel h) {
      if (lowerQuery.isEmpty) return true;
      return h.name.toLowerCase().contains(lowerQuery) ||
             h.location.toLowerCase().contains(lowerQuery) ||
             h.description.toLowerCase().contains(lowerQuery);
    }

    // Immediately yield matching from in-memory seed + CSV
    final immediateMatches = _mergeHotels(SeedData.initialHotels, csvHotels).where(matches).toList();
    yield immediateMatches;

    try {
      await for (final snapshot in _firestore.collection('hotels').snapshots()) {
        final firestoreHotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
        final allHotels = _mergeHotels(SeedData.initialHotels, [...firestoreHotels, ...csvHotels]);
        yield allHotels.where(matches).toList();
      }
    } catch (_) {
      yield immediateMatches;
    }
  }

  List<Hotel> _mergeHotels(List<Hotel> priorityList, List<Hotel> secondaryList) {
    final Map<String, Hotel> map = {};
    for (var h in secondaryList) {
      map[h.id] = h;
    }
    // Overwrite or ensure priority hotels exist
    for (var h in priorityList) {
      map[h.id] = h;
    }
    return map.values.toList();
  }
}
