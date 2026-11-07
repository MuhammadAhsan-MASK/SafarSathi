import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import '../../core/favorites_provider.dart';
import 'services/attraction_service.dart';
import 'models/attraction_model.dart';

class AttractionsScreen extends StatefulWidget {
  final String? initialCity;
  const AttractionsScreen({super.key, this.initialCity});

  @override
  State<AttractionsScreen> createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  final AttractionService _attractionService = AttractionService();

  // Selection state
  String? _selectedCity;
  String? _selectedType;
  bool _hasSearched = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _cities = [
    'Islamabad',
    'Karachi',
    'Lahore',
    'Murree',
    'Hunza',
    'Skardu',
    'Swat',
    'Peshawar',
    'Quetta',
    'Multan',
  ];

  final List<Map<String, dynamic>> _types = [
    {
      'name': 'All Types',
      'icon': Icons.explore,
      'desc': 'Discover all sights and wonders',
      'color': Colors.purple,
    },
    {
      'name': 'Historical',
      'icon': Icons.account_balance,
      'desc': 'Ancient forts, palaces, and ruins',
      'color': Colors.amber[800],
    },
    {
      'name': 'Greenery & Nature',
      'icon': Icons.park,
      'desc': 'Valleys, pine forests, and lakes',
      'color': Colors.green[700],
    },
    {
      'name': 'Religious & Spiritual',
      'icon': Icons.mosque,
      'desc': 'Historic mosques, shrines & spiritual hubs',
      'color': Colors.teal[700],
    },
    {
      'name': 'Mountain & Adventure',
      'icon': Icons.terrain,
      'desc': 'Peaks, passes, ski resorts & high treks',
      'color': Colors.blue[700],
    },
    {
      'name': 'Cultural & Arts',
      'icon': Icons.palette,
      'desc': 'Museums, folk art galleries & craft bazaars',
      'color': Colors.deepOrange,
    },
    {
      'name': 'Parks & Recreation',
      'icon': Icons.nature_people,
      'desc': 'Promenades, amusement parks & viewpoints',
      'color': Colors.pink[600],
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCity != null && widget.initialCity!.isNotEmpty) {
      _selectedCity = widget.initialCity;
      _selectedType = 'All Types';
      _hasSearched = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        title: Text(
          _hasSearched ? '$_selectedCity Attractions' : 'Explore Attractions',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          if (_hasSearched)
            IconButton(
              icon: const Icon(Icons.tune, color: AppTheme.attractionColor),
              tooltip: 'Change City & Type',
              onPressed: () {
                setState(() {
                  _hasSearched = false;
                });
              },
            ),
          _buildCurrencySelector(context),
        ],
      ),
      body: _hasSearched ? _buildResultsView() : _buildSelectionWizard(),
    );
  }

  // ─────────────────────────────────────────────
  // 1. SELECTION WIZARD (Ask City & Type)
  // ─────────────────────────────────────────────
  Widget _buildSelectionWizard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E24AA).withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.travel_explore, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover Pakistan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select a city & attraction type to view authentic historic & scenic destinations.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Step 1: Select City
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.attractionColor,
                  shape: BoxShape.circle,
                ),
                child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Select City',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _cities.map((city) {
              final isSelected = _selectedCity == city;
              return ChoiceChip(
                label: Text(city),
                selected: isSelected,
                selectedColor: AppTheme.attractionColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppTheme.attractionColor : Colors.grey.shade300,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedCity = selected ? city : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Step 2: Select Type of Attraction
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.attractionColor,
                  shape: BoxShape.circle,
                ),
                child: const Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Select Attraction Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Type Selection List
          Column(
            children: _types.map((typeInfo) {
              final typeName = typeInfo['name'] as String;
              final isSelected = _selectedType == typeName;
              final icon = typeInfo['icon'] as IconData;
              final color = typeInfo['color'] as Color? ?? AppTheme.attractionColor;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = typeName;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                typeName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isSelected ? color : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                typeInfo['desc'] as String,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: color, size: 22)
                        else
                          Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Search Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search, size: 22),
              label: const Text(
                'Show Attractions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.attractionColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              onPressed: () {
                if (_selectedCity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a city first.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                setState(() {
                  _selectedType ??= 'All Types';
                  _hasSearched = true;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 2. RESULTS VIEW
  // ─────────────────────────────────────────────
  Widget _buildResultsView() {
    return Column(
      children: [
        // Top Filter Bar with City Selector & Quick Category Tabs
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input + City change button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search in $_selectedCity...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF5F3F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.location_city, size: 16),
                    label: Text(_selectedCity ?? 'City'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.attractionColor,
                      side: const BorderSide(color: AppTheme.attractionColor),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _showCityPicker();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontal Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _types.map((t) {
                    final typeName = t['name'] as String;
                    final isSelected = (_selectedType ?? 'All Types') == typeName;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(typeName),
                        selected: isSelected,
                        selectedColor: AppTheme.attractionColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: const Color(0xFFF3E5F5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        showCheckmark: false,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedType = typeName;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Stream Results List
        Expanded(
          child: StreamBuilder<List<Attraction>>(
            stream: _attractionService.getAttractions(
              city: _selectedCity,
              type: _selectedType == 'All Types' ? null : _selectedType,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var attractions = snapshot.data ?? [];

              // Apply search query filter if user typed in search bar
              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                attractions = attractions.where((a) {
                  return a.name.toLowerCase().contains(q) ||
                      (a.location?.toLowerCase().contains(q) ?? false) ||
                      (a.history?.toLowerCase().contains(q) ?? false) ||
                      a.type.toLowerCase().contains(q);
                }).toList();
              }

              if (attractions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No attractions found for "$_selectedType" in $_selectedCity.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Show All in This City'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.attractionColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedType = 'All Types';
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  return _buildAttractionCard(context, attractions[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 3. ATTRACTION CARD (Name, History, Location, Map Link)
  // ─────────────────────────────────────────────
  Widget _buildAttractionCard(BuildContext context, Attraction attraction) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with category badge overlay
          Stack(
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: (attraction.imageUrl != null && attraction.imageUrl!.isNotEmpty && attraction.imageUrl!.startsWith('http'))
                    ? Image.network(
                        attraction.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.purple.shade50,
                          child: const Icon(Icons.image, size: 50, color: Colors.purple),
                        ),
                      )
                    : Container(
                        color: Colors.purple.shade50,
                        child: const Icon(Icons.photo_camera_back, size: 50, color: Colors.purple),
                      ),
              ),
              // Category Chip
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.label_outline, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        attraction.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Fee Chip
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: attraction.fee == 0 ? Colors.green.shade700 : Colors.deepOrange.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        attraction.fee == 0 ? 'FREE ENTRY' : 'Ticket: ${currencyProvider.formatPrice(attraction.fee)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<FavoriteProvider>(
                      builder: (context, fav, _) {
                        final isFav = fav.isFavorite(attraction.id);
                        return GestureDetector(
                          onTap: () => fav.toggleFavorite(attraction.id),
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
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Watch Video Tour overlay badge
              Positioned(
                bottom: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () => _showVideoPreviewSheet(context, attraction),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'Watch Video Tour',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attraction Name
                Text(
                  attraction.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Location / Address with Pin
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppTheme.attractionColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        attraction.location ?? '${attraction.city}, Pakistan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // History & Background Section
                if (attraction.history != null && attraction.history!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F2FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9D8FD)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_stories, size: 15, color: Colors.purple.shade700),
                            const SizedBox(width: 6),
                            Text(
                              'History & Significance',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attraction.history!,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Action Bar: Watch Video, View on Map & Official Website
                Row(
                  children: [
                    // Watch Video Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () => _showVideoPreviewSheet(context, attraction),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.smart_display_rounded, size: 16),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Watch Video',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // View on Map Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.attractionColor,
                          side: const BorderSide(color: AppTheme.attractionColor),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (attraction.mapUrl != null && attraction.mapUrl!.isNotEmpty) {
                            _launchUrl(attraction.mapUrl!);
                          } else {
                            _openMap(attraction.location ?? attraction.city, attraction.name);
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_outlined, size: 16),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'View on Map',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Website Link (if present)
                    if (attraction.websiteUrl != null && attraction.websiteUrl!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.language, color: AppTheme.attractionColor, size: 20),
                        tooltip: 'Official Portal',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF3E5F5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _launchUrl(attraction.websiteUrl!),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Video Tour Bottom Sheet
  void _showVideoPreviewSheet(BuildContext context, Attraction attraction) {
    final videoUrl = attraction.effectiveVideoUrl;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_display_rounded, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video Tour & Sights Preview',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        attraction.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Video Thumbnail card with play overlay
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: (attraction.imageUrl != null && attraction.imageUrl!.isNotEmpty && attraction.imageUrl!.startsWith('http'))
                        ? Image.network(
                            attraction.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                          )
                        : Container(color: Colors.grey[800]),
                  ),
                ),
                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _launchUrl(videoUrl);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Tap to Play 4K Video Tour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Watch authentic drone footage, travel guides, and walkthroughs of ${attraction.name} in ${attraction.city}, Pakistan to see what this destination looks like.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_fill, size: 20),
                    label: const Text('Play Video Tour (YouTube)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _launchUrl(videoUrl);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // City Picker Bottom Sheet / Dialog
  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose a City',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: _cities.map((city) {
                    final isSelected = _selectedCity == city;
                    return ChoiceChip(
                      label: Text(city),
                      selected: isSelected,
                      selectedColor: AppTheme.attractionColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCity = city;
                          });
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
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
