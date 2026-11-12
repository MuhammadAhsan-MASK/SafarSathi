import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../booking/services/booking_service.dart';
import '../booking/models/booking_model.dart';

class BookingsScreen extends StatelessWidget {
  final String vendorId;
  const BookingsScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Recent Bookings', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
      ),
      body: StreamBuilder<List<Booking>>(
        stream: bookingService.getBookingsByVendor(vendorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No bookings found', style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final statusLower = booking.status.toLowerCase();
              Color statusColor = Colors.orange;
              if (statusLower == 'confirmed') statusColor = Colors.green;
              if (statusLower == 'cancelled' || statusLower == 'rejected') statusColor = Colors.red;

              return _buildBookingCard(context, bookingService, booking, statusColor);
            },
          );
        },
      ),
    );
  }

  void _showBookingDetails(BuildContext context, BookingService service, Booking booking, Color statusColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(booking.itemName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Customer', booking.customerName),
            _detailRow('Dates', booking.dates),
            _detailRow('Amount', 'PKR ${booking.price.toStringAsFixed(0)}'),
            _detailRow('Status', booking.status),
          ],
        ),
        actions: [
          if (booking.status.toLowerCase() == 'pending') ...[
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await service.updateBookingStatus(booking.id, 'Cancelled');
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await service.updateBookingStatus(booking.id, 'Confirmed');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Confirm'),
            ),
          ] else
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingService service, Booking booking, Color statusColor) {
    final isPending = booking.status.toLowerCase() == 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
                child: Text(
                  booking.customerName.isNotEmpty ? booking.customerName[0].toUpperCase() : 'U',
                  style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.customerName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '${booking.itemName} • PKR ${booking.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(booking.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(booking.dates, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  if (isPending)
                    TextButton(
                      onPressed: () => service.updateBookingStatus(booking.id, 'Confirmed'),
                      child: const Text('Confirm', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  TextButton(
                    onPressed: () => _showBookingDetails(context, service, booking, statusColor),
                    child: const Text('Details', style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
