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
      imageUrl: data['imageUrl'],
      websiteUrl: data['websiteUrl'],
      vendorId: data['vendorId'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      typePrices: Map<String, double>.from(data['typePrices'] ?? {}),
      category: data['category'] ?? 'bus',
      departureTime: data['departureTime'] ?? '08:00',
      availableSeats: (data['availableSeats'] ?? 15) as int,
      operator: data['operator'] ?? '',
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
