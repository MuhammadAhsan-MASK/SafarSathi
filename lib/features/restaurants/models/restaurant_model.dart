import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double price;
  final String location;
  final String? imageUrl;
  final String vendorId;
  final DateTime? createdAt;
  final Map<String, double> typePrices;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.price,
    required this.location,
    required this.vendorId,
    this.imageUrl,
    this.createdAt,
    this.typePrices = const {},
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      cuisine: data['cuisine'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      vendorId: data['vendorId'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      typePrices: Map<String, double>.from(data['typePrices'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cuisine': cuisine,
      'price': price,
      'location': location,
      'imageUrl': imageUrl,
      'vendorId': vendorId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'typePrices': typePrices,
    };
  }
}
