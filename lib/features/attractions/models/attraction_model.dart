import 'package:cloud_firestore/cloud_firestore.dart';

class Attraction {
  final String id;
  final String name;
  final String city;
  final String type;
  final double fee;
  final String? imageUrl;
  final String vendorId;
  final String? location;
  final String? history;
  final String? mapUrl;
  final String? websiteUrl;
  final String? videoUrl;
  final DateTime? createdAt;

  Attraction({
    required this.id,
    required this.name,
    required this.city,
    required this.type,
    required this.fee,
    required this.vendorId,
    this.imageUrl,
    this.location,
    this.history,
    this.mapUrl,
    this.websiteUrl,
    this.videoUrl,
    this.createdAt,
  });

  String get effectiveVideoUrl {
    if (videoUrl != null && videoUrl!.isNotEmpty) {
      return videoUrl!;
    }
    final query = Uri.encodeComponent('$name $city Pakistan travel tour 4k');
    return 'https://www.youtube.com/results?search_query=$query';
  }

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
      location: data['location'],
      history: data['history'],
      mapUrl: data['mapUrl'],
      websiteUrl: data['websiteUrl'],
      videoUrl: data['videoUrl'],
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
      'location': location,
      'history': history,
      'mapUrl': mapUrl,
      'websiteUrl': websiteUrl,
      'videoUrl': videoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
