import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/currency_provider.dart';
import '../../core/theme.dart';
import '../hotels/services/hotel_service.dart';
import '../hotels/models/hotel_model.dart';

class RoomsPricingScreen extends StatelessWidget {
  final String vendorId;
  const RoomsPricingScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final hotelService = HotelService();
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Rooms & Pricing', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
      ),
      body: StreamBuilder<List<Hotel>>(
        stream: hotelService.getHotelsByVendor(vendorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final hotels = snapshot.data ?? [];
          final verifiedCount = hotels.where((h) => h.isVerified).length;
          final pendingCount = hotels.length - verifiedCount;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInventoryOverview(hotels.length, verifiedCount, pendingCount),
                  const SizedBox(height: 30),
                  Text('Your Properties', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (hotels.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text('No hotels listed yet', style: GoogleFonts.poppins(color: Colors.grey)),
                    ))
                  else
                    ...hotels.map((hotel) => _buildRoomTypeCard(
                      context,
                      hotelService,
                      hotel,
                      currency.formatPrice(hotel.price),
                      AppTheme.primaryPurple,
                    )),
                  const SizedBox(height: 30),
                  _buildBackToDashboardButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryOverview(int total, int verified, int pending) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(total.toString(), 'Total Properties'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStat(verified.toString(), 'Verified Live'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStat(pending.toString(), 'Pending'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _showEditPriceDialog(BuildContext context, HotelService hotelService, Hotel hotel) {
    final priceCtrl = TextEditingController(text: hotel.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Update Base Rate (${hotel.name})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
        content: TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nightly Rate (PKR)',
            prefixText: 'Rs. ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceCtrl.text.trim());
              if (newPrice == null || newPrice <= 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid positive rate in PKR.')),
                );
                return;
              }
              await hotelService.updateHotelPrice(hotel.id, newPrice);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTypeCard(
    BuildContext context,
    HotelService hotelService,
    Hotel hotel,
    String formattedPrice,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(Icons.hotel_rounded, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(hotel.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  hotel.isVerified ? 'Verified Live' : 'Pending Approval',
                  style: TextStyle(
                    fontSize: 11,
                    color: hotel.isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formattedPrice, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
              TextButton.icon(
                onPressed: () => _showEditPriceDialog(context, hotelService, hotel),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Edit Price', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 28)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackToDashboardButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.dashboard_outlined, color: Colors.white),
        label: const Text('Manage & Add from Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
