import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double price;
  final String location;
  final String? imageUrl;
  final String? websiteUrl;
  final String? phone;
  final String? description;
  final String vendorId;
  final DateTime? createdAt;
  final Map<String, double> typePrices;
  final bool isVerified;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.price,
    required this.location,
    required this.vendorId,
    this.imageUrl,
    this.websiteUrl,
    this.phone,
    this.description,
    this.createdAt,
    this.typePrices = const {},
    this.isVerified = true,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    final rawPrices = data['typePrices'];
    final Map<String, double> parsedPrices = {};
    if (rawPrices is Map) {
      rawPrices.forEach((key, val) {
        if (val is num) parsedPrices[key.toString()] = val.toDouble();
      });
    }

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      cuisine: data['cuisine'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      websiteUrl: data['websiteUrl'],
      phone: data['phone'],
      description: data['description'],
      vendorId: data['vendorId'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      typePrices: parsedPrices,
      isVerified: data['isVerified'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cuisine': cuisine,
      'price': price,
      'location': location,
      'imageUrl': imageUrl,
      'websiteUrl': websiteUrl,
      'phone': phone,
      'description': description,
      'vendorId': vendorId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'typePrices': typePrices,
      'isVerified': isVerified,
    };
  }
}
