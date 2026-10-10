import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class BargainItem {
  final String name;
  final String category;
  final String minPrice;
  final String maxPrice;
  final String tip;

  const BargainItem({
    required this.name,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.tip,
  });
}

final List<BargainItem> _bargainData = [
  // Transport
  BargainItem(name: 'Jeep to Fairy Meadows', category: 'Transport', minPrice: '5,000', maxPrice: '8,000', tip: 'PKR 6,000 is a fair deal. Book round-trip to negotiate down.'),
  BargainItem(name: 'Jeep Naran–Babusar Top', category: 'Transport', minPrice: '3,500', maxPrice: '6,000', tip: 'Share with others to reduce cost per head.'),
  BargainItem(name: 'Rickshaw (short city ride)', category: 'Transport', minPrice: '100', maxPrice: '300', tip: 'Always agree on the fare BEFORE getting in.'),
  BargainItem(name: 'Intercity Bus (per seat)', category: 'Transport', minPrice: '800', maxPrice: '2,500', tip: 'Daewoo & Faisal Movers have fixed rates. Avoid touts.'),
  BargainItem(name: 'Horse Ride in Nathia Gali', category: 'Transport', minPrice: '500', maxPrice: '1,500', tip: 'Agree on full route price, not per minute rate.'),
  // Souvenirs
  BargainItem(name: 'Pashmina Shawl', category: 'Souvenir', minPrice: '1,500', maxPrice: '4,000', tip: 'Genuine Pashmina is expensive. Acrylic blends sell for PKR 500–800 — inspect before buying.'),
  BargainItem(name: 'Hunza Dry Fruits (per kg)', category: 'Souvenir', minPrice: '1,200', maxPrice: '2,500', tip: 'Walnut, apricot, and almond. Buy directly from local farms for 20% less.'),
  BargainItem(name: 'Wooden Carved Items', category: 'Souvenir', minPrice: '500', maxPrice: '3,000', tip: 'Small trinkets are cheap but quality varies. Machine-carved vs hand-carved matters.'),
  BargainItem(name: 'Chitrali Cap (Pakol)', category: 'Souvenir', minPrice: '400', maxPrice: '1,200', tip: 'Authentic wool ones cost more. Check stitching quality.'),
  BargainItem(name: 'Lapis Lazuli Stone', category: 'Souvenir', minPrice: '200', maxPrice: '2,000', tip: 'Fake glass stones are common. Test with a scratch on untreated ceramic.'),
  // Food
  BargainItem(name: 'Biryani Plate (restaurant)', category: 'Food', minPrice: '250', maxPrice: '600', tip: 'Dhabas serve the same quality rice for half the price.'),
  BargainItem(name: 'Fresh Trout Fish (Kaghan)', category: 'Food', minPrice: '600', maxPrice: '1,200', tip: 'Price is per fish, not per kg. Always clarify before ordering.'),
  BargainItem(name: 'Chai (cup of tea)', category: 'Food', minPrice: '30', maxPrice: '100', tip: 'Tourist spots overcharge for tea. Local dhabas serve it for PKR 30–50.'),
  BargainItem(name: 'Chapli Kebab (2 pcs)', category: 'Food', minPrice: '150', maxPrice: '350', tip: 'Peshawar originals are best. Avoid hotel menus and find local stalls.'),
  // Accommodation
  BargainItem(name: 'Camping Tent Rental (night)', category: 'Stay', minPrice: '500', maxPrice: '1,500', tip: 'Many camps include free breakfast with tent. Always confirm what is included.'),
  BargainItem(name: 'PTDC Motel (per night)', category: 'Stay', minPrice: '2,500', maxPrice: '5,000', tip: 'Book directly on their website to avoid agent markups.'),
];

class BargainScreen extends StatefulWidget {
  const BargainScreen({super.key});

  @override
  State<BargainScreen> createState() => _BargainScreenState();
}

class _BargainScreenState extends State<BargainScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<BargainItem> _filtered = _bargainData;

  final List<String> _categories = ['All', 'Transport', 'Souvenir', 'Food', 'Stay'];
  final Map<String, Color> _categoryColors = {
    'Transport': Colors.blue,
    'Souvenir': Colors.purple,
    'Food': Colors.orange,
    'Stay': Colors.teal,
  };
  final Map<String, IconData> _categoryIcons = {
    'Transport': Icons.directions_car,
    'Souvenir': Icons.card_giftcard,
    'Food': Icons.restaurant,
    'Stay': Icons.hotel,
  };

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _bargainData.where((item) {
        final matchesQuery = query.isEmpty || item.name.toLowerCase().contains(query);
        final matchesCat = _selectedCategory == 'All' || item.category == _selectedCategory;
        return matchesQuery && matchesCat;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bargain Engine'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search item (e.g., Jeep, Shawl...)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.65)),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        _selectedCategory = cat;
                        _applyFilter();
                      },
                      selectedColor: AppTheme.primaryPurple,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Colors.grey[100],
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No items found. Try a different search.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _buildBargainCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBargainCard(BargainItem item) {
    final color = _categoryColors[item.category] ?? AppTheme.primaryPurple;
    final icon = _categoryIcons[item.category] ?? Icons.info_outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.category, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceChip('Min (Fair)', 'PKR ${item.minPrice}', Colors.green),
                _buildPriceChip('Max (Tourist)', 'PKR ${item.maxPrice}', Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.tip, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label, String price, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
