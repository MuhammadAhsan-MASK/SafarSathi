import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'services/restaurant_service.dart';
import 'models/restaurant_model.dart';
import '../../core/favorites_provider.dart';
import '../booking/booking_success_screen.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  String _searchQuery = '';

  void _simulateBooking(BuildContext context, String name, String category) {
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
        if (mounted) {
          Navigator.pop(context); // Close dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingSuccessScreen(itemName: name, category: category),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.foodBg,
      appBar: AppBar(
        title: const Text('Food'),
        backgroundColor: Colors.transparent,
        actions: [_buildCurrencySelector(context)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by cuisine or city...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.grey[100],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Restaurant>>(
        stream: _searchQuery.isEmpty
            ? _restaurantService.getRestaurants()
            : _restaurantService.searchRestaurants(_searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final restaurants = snapshot.data ?? [];
          if (restaurants.isEmpty) {
            return const Center(child: Text('No restaurants found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              return _buildRestaurantCard(context, restaurants[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: restaurant.imageUrl != null
                    ? Image.network(
                        restaurant.imageUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.broken_image, size: 50)),
                        ),
                      )
                    : Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Consumer<FavoriteProvider>(
                  builder: (context, favorites, _) {
                    final isFav = favorites.isFavorite(restaurant.id);
                    return InkWell(
                      onTap: () => favorites.toggleFavorite(restaurant.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      restaurant.cuisine,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
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
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Avg. ${Provider.of<CurrencyProvider>(context).formatPrice(restaurant.price)} / meal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _simulateBooking(context, restaurant.name, 'Restaurant'),
                      child: const Text('BOOK NOW'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currencyProvider.selectedCurrency,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.currency_exchange, size: 20, color: Colors.black54),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          items: currencyProvider.currencies.map((String cur) {
            return DropdownMenuItem<String>(
              value: cur,
              child: Text(cur),
            );
          }).toList(),
          onChanged: (String? newVal) {
            if (newVal != null) {
              currencyProvider.setCurrency(newVal);
            }
          },
        ),
      ),
    );
  }
}
