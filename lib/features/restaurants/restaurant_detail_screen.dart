import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/currency_provider.dart';
import '../../core/widgets/app_image.dart';
import 'models/restaurant_model.dart';
import '../../core/theme.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    }
  }

  Future<void> _callPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not call $phone')),
        );
      }
    }
  }

  Future<void> _openMap(String location, String name) async {
    final query = Uri.encodeComponent('$name $location Pakistan');
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    // Menu items
    final Map<String, double> menu = restaurant.typePrices.isNotEmpty
        ? restaurant.typePrices
        : {
            'Special ${restaurant.cuisine.split(' ').first} Platter': restaurant.price > 0 ? restaurant.price : 800.0,
            'Chef Signature Dish': (restaurant.price > 0 ? restaurant.price : 800.0) * 1.4,
            'Family Feast Deal': (restaurant.price > 0 ? restaurant.price : 800.0) * 3.2,
            'Fresh Salads & Traditional Raita': (restaurant.price > 0 ? restaurant.price : 800.0) * 0.4,
            'Special Traditional Chai & Dessert': (restaurant.price > 0 ? restaurant.price : 800.0) * 0.5,
          };

    return Scaffold(
      backgroundColor: AppTheme.foodBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: AppImage(
                url: restaurant.imageUrl,
                fit: BoxFit.cover,
                errorWidget: Container(color: Colors.grey[300], child: const Icon(Icons.restaurant, size: 50, color: Colors.grey)),
              ),
            ),
            actions: [
              if (restaurant.phone != null && restaurant.phone!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.phone),
                  tooltip: 'Call for Reservation',
                  onPressed: () => _callPhone(restaurant.phone!),
                ),
              IconButton(
                icon: const Icon(Icons.map_outlined),
                tooltip: 'View on Google Maps',
                onPressed: () => _openMap(restaurant.location, restaurant.name),
              ),
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
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          restaurant.cuisine,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.location,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price per person banner + Reservation CTA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.deepOrange.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Estimated Cost', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '~${currencyProvider.formatPrice(restaurant.price)} / person',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (restaurant.phone != null && restaurant.phone!.isNotEmpty)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.phone, size: 15),
                              label: const Text('Reserve Table'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _callPhone(restaurant.phone!),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Sample Menu & Prices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = menu.entries.elementAt(index);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                currencyProvider.formatPrice(entry.value),
                                style: const TextStyle(fontSize: 14, color: Colors.deepOrange, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        if (restaurant.phone != null && restaurant.phone!.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.phone_outlined, color: Colors.green),
                            tooltip: 'Call to Order / Reserve',
                            onPressed: () => _callPhone(restaurant.phone!),
                          ),
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
