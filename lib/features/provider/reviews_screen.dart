import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../profile/services/review_service.dart';
import '../profile/models/review_model.dart';
import 'package:intl/intl.dart';

class ReviewsScreen extends StatelessWidget {
  final String vendorId;
  const ReviewsScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final reviewService = ReviewService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Guest Reviews', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
      ),
      body: StreamBuilder<List<Review>>(
        stream: reviewService.getReviewsByVendor(vendorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildRatingSummary(reviews),
                  const SizedBox(height: 30),
                  if (reviews.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text('No reviews yet', style: GoogleFonts.poppins(color: Colors.grey)),
                    ))
                  else
                    ...reviews.map((review) => _buildReviewCard(
                      review.userName, 
                      review.rating, 
                      review.comment, 
                      DateFormat('MMM dd, yyyy').format(review.timestamp)
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingSummary(List<Review> reviews) {
    double avg = 0;
    if (reviews.isNotEmpty) {
      avg = reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(avg.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
              Row(
                children: List.generate(5, (index) => Icon(Icons.star, color: index < avg.floor() ? Colors.amber : Colors.grey[300], size: 16)),
              ),
              const SizedBox(height: 4),
              const Text('Overall Rating', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRatingBar('5', _getPercentage(reviews, 5)),
              _buildRatingBar('4', _getPercentage(reviews, 4)),
              _buildRatingBar('3', _getPercentage(reviews, 3)),
              _buildRatingBar('2', _getPercentage(reviews, 2)),
              _buildRatingBar('1', _getPercentage(reviews, 1)),
            ],
          ),
        ],
      ),
    );
  }

  double _getPercentage(List<Review> reviews, int rating) {
    if (reviews.isEmpty) return 0;
    int count = reviews.where((e) => e.rating == rating).length;
    return count / reviews.length;
  }

  Widget _buildRatingBar(String label, double progress) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String user, int rating, String comment, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) => Icon(Icons.star, color: index < rating ? Colors.amber : Colors.grey[300], size: 16)),
          ),
          const SizedBox(height: 12),
          Text(comment, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Respond', style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
