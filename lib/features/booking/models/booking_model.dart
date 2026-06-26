import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String customerName;
  final String itemName;
  final String dates;
  final double price;
  final String status;
  final String vendorId;

  Booking({
    required this.id,
    required this.customerName,
    required this.itemName,
    required this.dates,
    required this.price,
    required this.status,
    required this.vendorId,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      itemName: data['itemName'] ?? '',
      dates: data['dates'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pending',
      vendorId: data['vendorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'itemName': itemName,
      'dates': dates,
      'price': price,
      'status': status,
      'vendorId': vendorId,
    };
  }
}
