import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String itemName;
  final String category;

  const BookingSuccessScreen({
    super.key,
    required this.itemName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 100,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Booking Successful!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your $category reservation for "$itemName" has been confirmed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              _buildInfoRow(Icons.confirmation_number_outlined, 'Booking ID', '#SS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
              _buildInfoRow(Icons.calendar_today_outlined, 'Status', 'Confirmed'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('BACK TO HOME'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryPurple),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
