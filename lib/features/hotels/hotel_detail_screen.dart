import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/currency_provider.dart';
import 'models/hotel_model.dart';
import '../booking/booking_success_screen.dart';
import '../../core/theme.dart';

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    }
  }

  void _simulateBooking(String roomName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing Booking...'),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              itemName: '${widget.hotel.name} - $roomName',
              category: 'Hotel Room',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    // Mock realistic room prices if empty
    final Map<String, double> roomPrices = hotel.typePrices.isNotEmpty
        ? hotel.typePrices
        : {
            'Standard Room': hotel.price > 0 ? hotel.price : 4000.0,
            'Deluxe Room': (hotel.price > 0 ? hotel.price : 4000.0) * 1.5,
            'Executive Suite': (hotel.price > 0 ? hotel.price : 4000.0) * 2.5,
          };

    return Scaffold(
      backgroundColor: AppTheme.hotelBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                  ? Image.network(
                      hotel.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image, size: 50))),
                    )
                  : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
            actions: [
              if (hotel.websiteUrl != null && hotel.websiteUrl!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.language),
                  tooltip: 'Visit Official Website',
                  onPressed: () => _launchUrl(hotel.websiteUrl!),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 4),
                          Text(hotel.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(hotel.location, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    hotel.description.isNotEmpty ? hotel.description : 'Enjoy a wonderful stay at ${hotel.name}. This property offers premium amenities and excellent service, making your trip a memorable one.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text('Available Rooms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = roomPrices.entries.elementAt(index);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                '${currencyProvider.formatPrice(entry.value)} / night',
                                style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _simulateBooking(entry.key),
                          child: const Text('BOOK ROOM'),
                        )
                      ],
                    ),
                  ),
                );
              },
              childCount: roomPrices.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}
