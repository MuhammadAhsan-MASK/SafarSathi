import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransportOption {
  final String id;
  final String type;
  final String route;
  final double fare;
  final String time;
  final IconData icon;
  final String vendorId;
  final DateTime? createdAt;
  final Map<String, double> typePrices;

  TransportOption({
    required this.id,
    required this.type,
    required this.route,
    required this.fare,
    required this.time,
    required this.icon,
    required this.vendorId,
    this.createdAt,
    this.typePrices = const {},
  });

  factory TransportOption.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    IconData icon;
    switch (data['category'] ?? 'bus') {
      case 'train':
        icon = Icons.train;
        break;
      case 'flight':
        icon = Icons.flight;
        break;
      default:
        icon = Icons.directions_bus;
    }

    return TransportOption(
      id: doc.id,
      type: data['type'] ?? '',
      route: data['route'] ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
      time: data['time'] ?? '',
      icon: icon,
      vendorId: data['vendorId'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      typePrices: Map<String, double>.from(data['typePrices'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'route': route,
      'fare': fare,
      'time': time,
      'category': icon == Icons.train ? 'train' : (icon == Icons.flight ? 'flight' : 'bus'),
      'vendorId': vendorId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'typePrices': typePrices,
    };
  }
}
