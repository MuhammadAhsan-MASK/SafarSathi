import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransportOption {
  final String id;
  final String type;
  final String route;
  final double fare;
  final String time;
  final IconData icon;
  final String? imageUrl;
  final String? websiteUrl;
  final String vendorId;
  final DateTime? createdAt;
  final Map<String, double> typePrices;
  final String category; // 'bus', 'flight', 'train'
  final String departureTime;
  final int availableSeats;
  final String operator;

  TransportOption({
    required this.id,
    required this.type,
    required this.route,
    required this.fare,
    required this.time,
    required this.icon,
    required this.vendorId,
    this.imageUrl,
    this.websiteUrl,
    this.createdAt,
    this.typePrices = const {},
    this.category = 'bus',
    this.departureTime = '08:00',
    this.availableSeats = 15,
    this.operator = '',
  });

  factory TransportOption.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
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

    final rawPrices = data['typePrices'];
    final Map<String, double> parsedPrices = {};
    if (rawPrices is Map) {
      rawPrices.forEach((key, val) {
        if (val is num) parsedPrices[key.toString()] = val.toDouble();
      });
    }

    return TransportOption(
      id: doc.id,
      type: data['type']?.toString() ?? '',
      route: data['route']?.toString() ?? '',
      fare: (data['fare'] as num?)?.toDouble() ?? 0.0,
      time: data['time']?.toString() ?? '',
      icon: icon,
      imageUrl: data['imageUrl']?.toString(),
      websiteUrl: data['websiteUrl']?.toString(),
      vendorId: data['vendorId']?.toString() ?? '',
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      typePrices: parsedPrices,
      category: data['category']?.toString() ?? 'bus',
      departureTime: data['departureTime']?.toString() ?? '08:00',
      availableSeats: (data['availableSeats'] as num?)?.toInt() ?? 15,
      operator: data['operator']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'route': route,
      'fare': fare,
      'time': time,
      'category': category,
      'departureTime': departureTime,
      'availableSeats': availableSeats,
      'operator': operator,
      'imageUrl': imageUrl,
      'websiteUrl': websiteUrl,
      'vendorId': vendorId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'typePrices': typePrices,
    };
  }
}
