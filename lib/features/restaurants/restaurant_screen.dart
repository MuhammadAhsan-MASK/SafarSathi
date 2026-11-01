import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import '../../core/favorites_provider.dart';
import 'services/restaurant_service.dart';
import 'models/restaurant_model.dart';
import 'restaurant_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCity = 'All';

  final List<String> _cities = [
    'All', 'Islamabad', 'Karachi', 'Lahore', 'Hunza',
    'Skardu', 'Swat', 'Murree', 'Peshawar', 'Quetta', 'Multan',
  ];

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

  Future<void> _openMap(String name, String location) async {
    final encoded = Uri.encodeComponent('$name, $location, Pakistan');
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  void _onCitySelected(String city) {
    setState(() {
      _selectedCity = city;
      if (city == 'All') {
        _searchQuery = '';
        _searchController.clear();
      } else {
        _searchQuery = city;
        _searchController.text = city;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.foodBg,
      appBar: AppBar(
        title: const Text('Dining & Restaurants'),
        backgroundColor: Colors.transparent,
        actions: [_buildCurrencySelector(context)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _selectedCity = _cities.firstWhere(
                        (c) => c.toLowerCase() == value.trim().toLowerCase(),
                        orElse: () => 'All',
                      );
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by city, restaurant or cuisine...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onCitySelected('All');
                            },
                          )
                        : null,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected = _selectedCity.toLowerCase() == city.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (_) => _onCitySelected(city),
                        selectedColor: AppTheme.primaryPurple,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ],
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_outlined, size: 50, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('No restaurants found for "$_searchQuery".', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RestaurantDetailScreen(restaurant: restaurant)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with cuisine badge
            Stack(
              children: [
                if (restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty)
                  Image.network(
                    restaurant.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.restaurant, size: 40, color: Colors.grey)),
                  ),
                // Cuisine badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      restaurant.cuisine,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Favorite button (top-right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Consumer<FavoriteProvider>(
                    builder: (context, fav, _) {
                      final isFav = fav.isFavorite(restaurant.id);
                      return GestureDetector(
                        onTap: () => fav.toggleFavorite(restaurant.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.black87,
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    restaurant.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Location + Map button
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 15, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(restaurant.location,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => _openMap(restaurant.name, restaurant.location),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_outlined, size: 13, color: Colors.blue.shade700),
                              const SizedBox(width: 3),
                              Text('Map', style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Price per head
                  Text.rich(
                    TextSpan(children: [
                      const TextSpan(text: 'Avg ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      TextSpan(
                        text: Provider.of<CurrencyProvider>(context).formatPrice(restaurant.price),
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const TextSpan(text: ' / person', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ),
                  const Divider(height: 18),
                  // Actions: website + phone for reservations
                  Row(
                    children: [
                      if (restaurant.websiteUrl != null && restaurant.websiteUrl!.isNotEmpty)
                        Expanded(
                          child: _actionButton(
                            icon: Icons.language,
                            label: 'Menu / Website',
                            color: Colors.deepOrange,
                            onTap: () => _launchUrl(restaurant.websiteUrl!),
                          ),
                        ),
                      if (restaurant.websiteUrl != null && restaurant.phone != null) const SizedBox(width: 10),
                      if (restaurant.phone != null && restaurant.phone!.isNotEmpty)
                        Expanded(
                          child: _actionButton(
                            icon: Icons.phone,
                            label: restaurant.phone!,
                            color: Colors.green.shade700,
                            onTap: () => _callPhone(restaurant.phone!),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
            return DropdownMenuItem<String>(value: cur, child: Text(cur));
          }).toList(),
          onChanged: (String? newVal) {
            if (newVal != null) currencyProvider.setCurrency(newVal);
          },
        ),
      ),
    );
  }
}
