import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/favorites_provider.dart';
import '../../core/currency_provider.dart';
import '../../core/theme.dart';
import '../hotels/models/hotel_model.dart';
import '../restaurants/models/restaurant_model.dart';
import '../attractions/models/attraction_model.dart';
import '../hotels/hotel_screen.dart';
import '../restaurants/restaurant_screen.dart';
import '../attractions/attractions_screen.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _openMap(String location, [String? name]) async {
    final query = Uri.encodeComponent(name != null ? '$name, $location, Pakistan' : '$location, Pakistan');
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Saved & Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Hotels'),
            Tab(text: 'Food'),
            Tab(text: 'Attractions'),
          ],
        ),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favorites, _) {
          final favHotels = favorites.getFavoriteHotels();
          final favRests = favorites.getFavoriteRestaurants();
          final favAttractions = favorites.getFavoriteAttractions();
          final totalCount = favHotels.length + favRests.length + favAttractions.length;

          if (totalCount == 0) {
            return _buildEmptyState(
              icon: Icons.favorite_border,
              title: 'No saved items yet',
              message: 'Bookmark your favorite hotels, restaurants, and attractions to access them anytime offline.',
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // 1. ALL TAB
              _buildAllTab(context, favHotels, favRests, favAttractions, favorites),

              // 2. HOTELS TAB
              favHotels.isEmpty
                  ? _buildEmptyCategory('No saved hotels yet', 'Explore top authentic hotels in Pakistan.', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HotelScreen()));
                    }, Icons.hotel_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: favHotels.length,
                      itemBuilder: (ctx, i) => _buildHotelCard(ctx, favHotels[i], favorites),
                    ),

              // 3. FOOD TAB
              favRests.isEmpty
                  ? _buildEmptyCategory('No saved restaurants yet', 'Explore authentic Pakistani dining spots.', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantScreen()));
                    }, Icons.restaurant_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: favRests.length,
                      itemBuilder: (ctx, i) => _buildRestaurantCard(ctx, favRests[i], favorites),
                    ),

              // 4. ATTRACTIONS TAB
              favAttractions.isEmpty
                  ? _buildEmptyCategory('No saved attractions yet', 'Discover historical and scenic destinations.', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttractionsScreen()));
                    }, Icons.location_on_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: favAttractions.length,
                      itemBuilder: (ctx, i) => _buildAttractionCard(ctx, favAttractions[i], favorites),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllTab(
    BuildContext context,
    List<Hotel> hotels,
    List<Restaurant> rests,
    List<Attraction> attractions,
    FavoriteProvider favProvider,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (hotels.isNotEmpty) ...[
          _buildSectionHeader('Hotels & Stays (${hotels.length})', Icons.hotel, AppTheme.hotelColor),
          ...hotels.map((h) => _buildHotelCard(context, h, favProvider)),
          const SizedBox(height: 16),
        ],
        if (rests.isNotEmpty) ...[
          _buildSectionHeader('Restaurants & Cafes (${rests.length})', Icons.restaurant, AppTheme.foodColor),
          ...rests.map((r) => _buildRestaurantCard(context, r, favProvider)),
          const SizedBox(height: 16),
        ],
        if (attractions.isNotEmpty) ...[
          _buildSectionHeader('Attractions & Sights (${attractions.length})', Icons.location_on, AppTheme.attractionColor),
          ...attractions.map((a) => _buildAttractionCard(context, a, favProvider)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARDS FOR SAVED ITEMS
  // ─────────────────────────────────────────────
  Widget _buildHotelCard(BuildContext context, Hotel hotel, FavoriteProvider favProvider) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                    ? Image.network(hotel.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]))
                    : Container(color: Colors.grey[200]),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Remove from Saved',
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)),
                  onPressed: () => favProvider.removeFavorite(hotel.id),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${currency.formatPrice(hotel.price)}/night',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(hotel.location, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (hotel.phone != null && hotel.phone!.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone, size: 15, color: Colors.green),
                          label: const Text('Call', style: TextStyle(color: Colors.green)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _callPhone(hotel.phone!),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _openMap(hotel.location, hotel.name),
                      ),
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

  Widget _buildRestaurantCard(BuildContext context, Restaurant rest, FavoriteProvider favProvider) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: rest.imageUrl != null && rest.imageUrl!.isNotEmpty
                    ? Image.network(rest.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]))
                    : Container(color: Colors.grey[200]),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Remove from Saved',
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)),
                  onPressed: () => favProvider.removeFavorite(rest.id),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.deepOrange.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    rest.cuisine,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rest.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(rest.location, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                    Text('~${currency.formatPrice(rest.price)}/person', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (rest.phone != null && rest.phone!.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone, size: 15, color: Colors.green),
                          label: const Text('Call', style: TextStyle(color: Colors.green)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _callPhone(rest.phone!),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _openMap(rest.location, rest.name),
                      ),
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

  Widget _buildAttractionCard(BuildContext context, Attraction attraction, FavoriteProvider favProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: attraction.imageUrl != null && attraction.imageUrl!.isNotEmpty
                    ? Image.network(attraction.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]))
                    : Container(color: Colors.grey[200]),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Remove from Saved',
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)),
                  onPressed: () => favProvider.removeFavorite(attraction.id),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    attraction.type,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attraction.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(attraction.location ?? attraction.city, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                if (attraction.history != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    attraction.history!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.smart_display_rounded, size: 15),
                        label: const Text('Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _launchUrl(attraction.effectiveVideoUrl),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('Map'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.attractionColor,
                          side: const BorderSide(color: AppTheme.attractionColor),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (attraction.mapUrl != null) {
                            _launchUrl(attraction.mapUrl!);
                          } else {
                            _openMap(attraction.location ?? attraction.city, attraction.name);
                          }
                        },
                      ),
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

  Widget _buildEmptyState({required IconData icon, required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategory(String title, String message, VoidCallback onExplore, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[350]),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white),
              onPressed: onExplore,
              child: const Text('Explore Now'),
            ),
          ],
        ),
      ),
    );
  }
}
