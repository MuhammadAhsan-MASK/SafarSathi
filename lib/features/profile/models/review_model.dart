import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime timestamp;
  final String vendorId;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
    required this.vendorId,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userName: data['userName'] ?? 'Anonymous',
      rating: (data['rating'] ?? 0).toInt(),
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vendorId: data['vendorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
      'vendorId': vendorId,
    };
  }
}
