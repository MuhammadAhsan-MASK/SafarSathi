import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/currency_provider.dart';
import 'models/restaurant_model.dart';
import '../../core/theme.dart';
import '../booking/booking_success_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
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

  void _simulateBooking(String orderItem) {
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
                Text('Placing Order...'),
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
              itemName: '${widget.restaurant.name} - $orderItem',
              category: 'Restaurant Order',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    // Mock realistic menu if empty
    final Map<String, double> menu = restaurant.typePrices.isNotEmpty
        ? restaurant.typePrices
        : {
            'Special ${restaurant.cuisine.split(' ').first} Meal': restaurant.price > 0 ? restaurant.price : 800.0,
            'Chef Signature Dish': (restaurant.price > 0 ? restaurant.price : 800.0) * 1.5,
            'Family Platter': (restaurant.price > 0 ? restaurant.price : 800.0) * 3.5,
            'Drinks & Desserts Combo': (restaurant.price > 0 ? restaurant.price : 800.0) * 0.8,
          };

    return Scaffold(
      backgroundColor: AppTheme.foodBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty
                  ? Image.network(
                      restaurant.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image, size: 50))),
                    )
                  : Container(color: Colors.grey[300], child: const Icon(Icons.restaurant, size: 50, color: Colors.grey)),
            ),
            actions: [
              if (restaurant.websiteUrl != null && restaurant.websiteUrl!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.language),
                  tooltip: 'Visit Official Website',
                  onPressed: () => _launchUrl(restaurant.websiteUrl!),
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
                          restaurant.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        restaurant.cuisine,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(restaurant.location, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Restaurant Menu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = menu.entries.elementAt(index);
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
                                currencyProvider.formatPrice(entry.value),
                                style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _simulateBooking(entry.key),
                          child: const Text('ORDER / ADD'),
                        )
                      ],
                    ),
                  ),
                );
              },
              childCount: menu.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}
