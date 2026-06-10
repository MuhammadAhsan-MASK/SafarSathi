import 'package:cloud_firestore/cloud_firestore.dart';

class Attraction {
  final String id;
  final String name;
  final String city;
  final String type;
  final double fee;
  final String? imageUrl;
  final String vendorId;
  final DateTime? createdAt;

  Attraction({
    required this.id,
    required this.name,
    required this.city,
    required this.type,
    required this.fee,
    required this.vendorId,
    this.imageUrl,
    this.createdAt,
  });

  factory Attraction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Attraction(
      id: doc.id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      type: data['type'] ?? '',
      fee: (data['fee'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      vendorId: data['vendorId'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,
      'type': type,
      'fee': fee,
      'imageUrl': imageUrl,
      'vendorId': vendorId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
