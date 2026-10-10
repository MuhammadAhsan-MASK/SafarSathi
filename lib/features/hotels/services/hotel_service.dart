import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/hotel_model.dart';

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

          csvHotels.add(Hotel(
            id: idStr,
            name: nameStr,
            location: cityStr,
            price: price,
            rating: rating,
            imageUrl: row.length > 17 ? row[17].toString() : null,
            websiteUrl: row.length > 18 ? row[18].toString() : null,
            vendorId: 'csv_data',
          ));
        }
      }
      _cachedCsvHotels = csvHotels;
      return csvHotels;
    } catch (e) {
      print('Failed to load CSV: $e');
      return [];
    }
  }

  Stream<List<Hotel>> getHotels() async* {
    List<Hotel> csvHotels = await _loadCsvHotels();
    
    await for (final snapshot in _firestore.collection('hotels').snapshots()) {
      final firestoreHotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      yield [...csvHotels, ...firestoreHotels];
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
    List<Hotel> csvHotels = await _loadCsvHotels();
    final lowerQuery = query.toLowerCase();
    final filteredCsvHotels = csvHotels.where((h) => 
        h.name.toLowerCase().contains(lowerQuery) || 
        h.location.toLowerCase().contains(lowerQuery)
    ).toList();

    await for (final snapshot in _firestore
        .collection('hotels')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()) {
      final firestoreHotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      yield [...filteredCsvHotels, ...firestoreHotels];
    }
  }
}
