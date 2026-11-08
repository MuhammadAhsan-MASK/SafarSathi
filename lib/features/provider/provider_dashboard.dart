import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/widgets/app_image.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import '../hotels/services/hotel_service.dart';
import '../hotels/models/hotel_model.dart';
import '../hotels/hotel_detail_screen.dart';
import '../restaurants/services/restaurant_service.dart';
import '../restaurants/models/restaurant_model.dart';
import '../restaurants/restaurant_detail_screen.dart';
import '../transport/services/transport_service.dart';
import '../transport/models/transport_model.dart';
import '../transport/transport_detail_screen.dart';
import '../guides/models/guide_model.dart';
import '../guides/services/guide_service.dart';
import '../guides/guide_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/user_role_service.dart';
import 'rooms_pricing_screen.dart';
import 'bookings_screen.dart';
import 'reviews_screen.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  final TransportService _transportService = TransportService();
  final HotelService _hotelService = HotelService();
  final RestaurantService _restaurantService = RestaurantService();
  final GuideService _guideService = GuideService();

  int _selectedIndex = 0;
  bool _isSwitching = false;
  String _activeTab = 'All'; // 'All', 'Hotels', 'Transport', 'Food', 'Guides'
  String _searchQuery = '';

  final List<String> _pakistanCities = [
    'Islamabad',
    'Rawalpindi',
    'Karachi',
    'Lahore',
    'Murree',
    'Swat',
    'Hunza',
    'Skardu',
    'Gilgit',
    'Naran',
    'Peshawar',
    'Quetta',
    'Multan',
    'Faisalabad',
    'Chitral',
    'Gwadar',
    'Neelum Valley',
  ];

  Future<String?> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile == null) return null;

      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'provider_${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        final savedFile = await File(pickedFile.path).copy('${appDir.path}/$fileName');
        return savedFile.path;
      } catch (_) {
        return pickedFile.path;
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  Widget _buildGalleryImagePicker({
    required String title,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    final hasImage = imagePath != null && imagePath.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasImage ? Colors.grey.shade100 : AppTheme.primaryPurple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasImage ? Colors.grey.shade300 : AppTheme.primaryPurple.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage(url: imagePath, fit: BoxFit.cover),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.photo_library_rounded, size: 13, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  'Change Photo',
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_photo_alternate_rounded, size: 28, color: AppTheme.primaryPurple),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select Photo from Gallery',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryPurple),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to open phone gallery',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _handleQuickSwitch() async {
    final roleService = UserRoleService();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: AppTheme.primaryPurple),
            const SizedBox(width: 8),
            Text('Traveler Mode', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Do you want to switch back to Traveler mode to explore trips and book services?',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Switch Mode', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) setState(() => _isSwitching = true);
      try {
        await roleService.updateUserRole('Traveler');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to switch: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSwitching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSwitching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _selectedIndex == 0 ? _buildDashboardContent() : const ProfileScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryPurple.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryPurple),
            label: 'Console',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryPurple),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProviderHeader(),
          const SizedBox(height: 18),
          _buildStatsOverview(),
          const SizedBox(height: 22),
          _buildPublishServicesSection(),
          const SizedBox(height: 22),
          _buildOperationalShortcuts(),
          const SizedBox(height: 22),
          _buildMyPublishedListings(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── 1. HEADER (Styled like HomeScreen with gradient & pill badges) ────────
  Widget _buildProviderHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@')[0].toUpperCase() ?? 'Partner';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, bottom: 26, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Greeting + Mode Switcher
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Service Provider 🇵🇰',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, color: Colors.amberAccent, size: 14),
                        ],
                      ),
                    ),
                    Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _handleQuickSwitch,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Traveler Mode',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Field for Provider's Listings
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search my published services & fleet...',
                hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryPurple, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. PERFORMANCE & STATS OVERVIEW ───────────────────────────────────────
  Widget _buildStatsOverview() {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Business Overview',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, color: Colors.green, size: 10),
                    const SizedBox(width: 4),
                    Text('Live on SastaSafar', style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.green[800], fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<Hotel>>(
                  stream: _hotelService.getHotelsByVendor(uid),
                  builder: (context, snap) {
                    final count = snap.data?.length ?? 0;
                    return _buildStatBox('Active Stays', '$count', Icons.hotel_rounded, AppTheme.hotelColor);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<List<TransportOption>>(
                  stream: _transportService.getTransportOptionsByVendor(uid),
                  builder: (context, snap) {
                    final count = snap.data?.length ?? 0;
                    return _buildStatBox('Routes / Fleet', '$count', Icons.directions_bus_rounded, AppTheme.transportColor);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<Restaurant>>(
                  stream: _restaurantService.getRestaurantsByVendor(uid),
                  builder: (context, snap) {
                    final count = snap.data?.length ?? 0;
                    return _buildStatBox('Dining Spots', '$count', Icons.restaurant_rounded, AppTheme.foodColor);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<List<LocalGuide>>(
                  stream: _guideService.getGuidesByVendor(uid),
                  builder: (context, snap) {
                    final count = snap.data?.length ?? 0;
                    return _buildStatBox('Tour Guides', '$count', Icons.explore_rounded, const Color(0xFF3F51B5));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. PUBLISH SERVICES (Styled exactly like Explore Services on HomeScreen) ──
  Widget _buildPublishServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Add & Publish Services',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Matches Traveler App',
                style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.primaryPurple, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildServiceActionCard(
                  title: 'List Hotel / Stay',
                  subtitle: 'Rooms & suites pricing',
                  icon: Icons.hotel_rounded,
                  color: AppTheme.hotelColor,
                  onTap: _showAddHotelModal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceActionCard(
                  title: 'Add Fleet Route',
                  subtitle: 'Bus, train, flight & van',
                  icon: Icons.directions_bus_rounded,
                  color: AppTheme.transportColor,
                  onTap: _showAddTransportModal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildServiceActionCard(
                  title: 'Add Restaurant',
                  subtitle: 'Cuisine, dishes & menu',
                  icon: Icons.restaurant_rounded,
                  color: AppTheme.foodColor,
                  onTap: _showAddRestaurantModal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceActionCard(
                  title: 'Register Guide',
                  subtitle: '4x4 car, trips & rate',
                  icon: Icons.explore_rounded,
                  color: const Color(0xFF3F51B5),
                  onTap: _showAddGuideModal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 4. OPERATIONAL SHORTCUTS (Bookings, Reviews, Pricing) ──────────────────
  Widget _buildOperationalShortcuts() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickPill('Inventory', Icons.inventory_2_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RoomsPricingScreen(vendorId: uid)));
            }),
            Container(width: 1, height: 28, color: Colors.grey.shade200),
            _buildQuickPill('Bookings', Icons.calendar_month_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BookingsScreen(vendorId: uid)));
            }),
            Container(width: 1, height: 28, color: Colors.grey.shade200),
            _buildQuickPill('Reviews', Icons.star_border_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewsScreen(vendorId: uid)));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryPurple),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. MY PUBLISHED LISTINGS WITH CATEGORY TABS ───────────────────────────
  Widget _buildMyPublishedListings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final tabs = ['All', 'Hotels', 'Transport', 'Food', 'Guides'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Published Listings',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs.map((t) {
                final isSel = _activeTab == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSel,
                    label: Text(t),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      color: isSel ? Colors.white : Colors.black87,
                    ),
                    selectedColor: AppTheme.primaryPurple,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSel ? AppTheme.primaryPurple : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) => setState(() => _activeTab = t),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Dynamic Combined Feed
          _buildCombinedListingsFeed(user.uid),
        ],
      ),
    );
  }

  Widget _buildCombinedListingsFeed(String uid) {
    return Column(
      children: [
        if (_activeTab == 'All' || _activeTab == 'Hotels') _buildHotelSection(uid),
        if (_activeTab == 'All' || _activeTab == 'Transport') _buildTransportSection(uid),
        if (_activeTab == 'All' || _activeTab == 'Food') _buildRestaurantSection(uid),
        if (_activeTab == 'All' || _activeTab == 'Guides') _buildGuideSection(uid),
      ],
    );
  }

  Widget _buildHotelSection(String uid) {
    return StreamBuilder<List<Hotel>>(
      stream: _hotelService.getHotelsByVendor(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final items = snapshot.data!.where((h) {
          if (_searchQuery.isEmpty) return true;
          return h.name.toLowerCase().contains(_searchQuery) || h.location.toLowerCase().contains(_searchQuery);
        }).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((h) => _buildHotelCard(h)).toList(),
        );
      },
    );
  }

  Widget _buildHotelCard(Hotel h) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: h))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppImage(
                  url: h.imageUrl ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorWidget: Container(width: 85, height: 85, color: Colors.grey[200], child: const Icon(Icons.hotel)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.hotelColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text('HOTEL', style: GoogleFonts.poppins(color: AppTheme.hotelColor, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        Text(' ${h.rating.toStringAsFixed(1)}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(h.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(h.location, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${currency.formatPrice(h.price)} / night',
                            style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                          onPressed: () => _confirmDelete('hotel', h.id, h.name, () => _hotelService.deleteHotel(h.id)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportSection(String uid) {
    return StreamBuilder<List<TransportOption>>(
      stream: _transportService.getTransportOptionsByVendor(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final items = snapshot.data!.where((t) {
          if (_searchQuery.isEmpty) return true;
          return t.type.toLowerCase().contains(_searchQuery) || t.route.toLowerCase().contains(_searchQuery);
        }).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((t) => _buildTransportCard(t)).toList(),
        );
      },
    );
  }

  Widget _buildTransportCard(TransportOption t) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransportDetailScreen(option: t))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: AppTheme.transportColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(t.icon, color: AppTheme.transportColor, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.transportColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(t.category.toUpperCase(), style: GoogleFonts.poppins(color: AppTheme.transportColor, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        Text(t.departureTime, style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(t.type, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(t.route, style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${currency.formatPrice(t.fare)} / person',
                            style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                          onPressed: () => _confirmDelete('fleet', t.id, t.type, () => _transportService.deleteTransportOption(t.id)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantSection(String uid) {
    return StreamBuilder<List<Restaurant>>(
      stream: _restaurantService.getRestaurantsByVendor(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final items = snapshot.data!.where((r) {
          if (_searchQuery.isEmpty) return true;
          return r.name.toLowerCase().contains(_searchQuery) || r.location.toLowerCase().contains(_searchQuery);
        }).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((r) => _buildRestaurantCard(r)).toList(),
        );
      },
    );
  }

  Widget _buildRestaurantCard(Restaurant r) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppImage(
                  url: r.imageUrl ?? 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorWidget: Container(width: 85, height: 85, color: Colors.grey[200], child: const Icon(Icons.restaurant)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.foodColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text('DINING', style: GoogleFonts.poppins(color: AppTheme.foodColor, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(r.cuisine, style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(r.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(r.location, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '~${currency.formatPrice(r.price)} / meal',
                            style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                          onPressed: () => _confirmDelete('restaurant', r.id, r.name, () => _restaurantService.deleteRestaurant(r.id)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection(String uid) {
    return StreamBuilder<List<LocalGuide>>(
      stream: _guideService.getGuidesByVendor(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final items = snapshot.data!.where((g) {
          if (_searchQuery.isEmpty) return true;
          return g.name.toLowerCase().contains(_searchQuery) || g.region.toLowerCase().contains(_searchQuery);
        }).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((g) => _buildGuideCard(g)).toList(),
        );
      },
    );
  }

  Widget _buildGuideCard(LocalGuide g) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: g))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppImage(
                  url: g.imageUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorWidget: Container(width: 85, height: 85, color: Colors.grey[200], child: const Icon(Icons.person)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF3F51B5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text('LOCAL GUIDE', style: GoogleFonts.poppins(color: const Color(0xFF3F51B5), fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        Text(' ${g.rating.toStringAsFixed(1)}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(g.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${g.region} • ${g.car}', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${currency.formatPrice(g.dailyRatePkr)} / day',
                            style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                          onPressed: () => _confirmDelete('guide', g.id, g.name, () => _guideService.deleteGuide(g.id)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String type, String id, String name, Future<void> Function() onConfirmed) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete $type?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove "$name" from SastaSafar?', style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await onConfirmed();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed "$name" successfully.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODALS TO ADD SERVICES (MATCHING APP DATA STANDARDS EXACTLY)
  // ══════════════════════════════════════════════════════════════════════════

  // ── A. ADD HOTEL MODAL ───────────────────────────────────────────────────
  void _showAddHotelModal() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final basePriceCtrl = TextEditingController(text: '3500');
    final phoneCtrl = TextEditingController(text: '+92-300-1234567');
    final websiteCtrl = TextEditingController();
    final descCtrl = TextEditingController(text: 'Clean and verified budget rooms with WiFi, hot water, and breakfast.');
    final stdPriceCtrl = TextEditingController(text: '3500');
    final dlxPriceCtrl = TextEditingController(text: '4800');
    final execPriceCtrl = TextEditingController(text: '6500');
    String selectedCity = _pakistanCities.first;
    String selectedImageUrl = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.all(22),
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.hotelColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.hotel_rounded, color: AppTheme.hotelColor)),
                    const SizedBox(width: 10),
                    Text('List Hotel / Accommodation', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                _buildInputField('Hotel Name', nameCtrl, 'e.g. Margalla View Residency', Icons.business_outlined),
                const SizedBox(height: 14),

                Text('Destination City', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  isExpanded: true,
                  items: _pakistanCities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setModal(() => selectedCity = val);
                  },
                  decoration: _inputDecoration('', Icons.location_city_rounded),
                ),
                const SizedBox(height: 14),

                _buildInputField('Area / Address', addressCtrl, 'e.g. G-9 Markaz, Karachi Company', Icons.pin_drop_outlined),
                const SizedBox(height: 14),

                _buildInputField('Starting Nightly Rate (PKR)', basePriceCtrl, '3500', Icons.payments_outlined, isNumber: true),
                const SizedBox(height: 18),

                Text('Room Pricing Tiers (PKR)', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInputField('Standard', stdPriceCtrl, '3500', null, isNumber: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Deluxe', dlxPriceCtrl, '4800', null, isNumber: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Executive', execPriceCtrl, '6500', null, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 14),

                _buildInputField('Phone / WhatsApp', phoneCtrl, '+92 300 1234567', Icons.phone_outlined),
                const SizedBox(height: 14),
                _buildInputField('Website / Booking Link (Optional)', websiteCtrl, 'https://...', Icons.language_outlined),
                const SizedBox(height: 14),

                _buildGalleryImagePicker(
                  title: 'Hotel Photo',
                  imagePath: selectedImageUrl,
                  onTap: () async {
                    final path = await _pickImageFromGallery();
                    if (path != null) {
                      setModal(() => selectedImageUrl = path);
                    }
                  },
                ),
                const SizedBox(height: 14),
                _buildInputField('Description & Amenities', descCtrl, 'Free WiFi, AC, Breakfast...', Icons.description_outlined, maxLines: 2),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(ctx);
                    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'provider_user';
                    final fullLocation = '${addressCtrl.text.trim()}, $selectedCity';
                    final baseP = double.tryParse(basePriceCtrl.text) ?? 3500;
                    final typeMap = <String, double>{
                      'Standard Room': double.tryParse(stdPriceCtrl.text) ?? baseP,
                      'Deluxe Room': double.tryParse(dlxPriceCtrl.text) ?? (baseP * 1.3),
                      'Executive Suite': double.tryParse(execPriceCtrl.text) ?? (baseP * 1.8),
                    };

                    final finalImg = selectedImageUrl.trim().isNotEmpty
                        ? selectedImageUrl.trim()
                        : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800';

                    await _hotelService.addHotel(Hotel(
                      id: '',
                      name: nameCtrl.text.trim(),
                      location: fullLocation,
                      price: baseP,
                      rating: 4.8,
                      vendorId: uid,
                      imageUrl: finalImg,
                      phone: phoneCtrl.text.trim(),
                      websiteUrl: websiteCtrl.text.trim().isNotEmpty ? websiteCtrl.text.trim() : null,
                      description: descCtrl.text.trim(),
                      typePrices: typeMap,
                    ));

                    nav.pop();
                    messenger.showSnackBar(const SnackBar(content: Text('Hotel listed live on SastaSafar!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Publish Hotel Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── B. ADD TRANSPORT MODAL ────────────────────────────────────────────────
  void _showAddTransportModal() {
    final operatorCtrl = TextEditingController(text: 'Faisal Movers Executive');
    final baseFareCtrl = TextEditingController(text: '4500');
    final timeDurationCtrl = TextEditingController(text: '4h 30m');
    final departureTimeCtrl = TextEditingController(text: '08:30 AM');
    final seatsCtrl = TextEditingController(text: '32');
    final phoneCtrl = TextEditingController(text: '+92-300-7654321');
    final econFareCtrl = TextEditingController(text: '4500');
    final execFareCtrl = TextEditingController(text: '6200');
    final bizFareCtrl = TextEditingController(text: '8000');

    String origin = 'Lahore';
    String destination = 'Islamabad';
    String category = 'bus'; // bus, flight, train, car

    final categories = [
      ('Bus Express', 'bus', Icons.directions_bus_rounded),
      ('Flight Jet', 'flight', Icons.flight_rounded),
      ('Railway Train', 'train', Icons.train_rounded),
      ('Private Tour Van', 'car', Icons.airport_shuttle_rounded),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.all(22),
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.transportColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.directions_bus_rounded, color: AppTheme.transportColor)),
                    const SizedBox(width: 10),
                    Text('Register Fleet / Route', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                // Category selector
                Text('Transport Category', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: categories.map((c) {
                    final isSel = category == c.$2;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModal(() => category = c.$2),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.transportColor : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(c.$3, size: 18, color: isSel ? Colors.white : Colors.black87),
                              const SizedBox(height: 2),
                              Text(c.$1.split(' ')[0], style: GoogleFonts.poppins(fontSize: 10, color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                _buildInputField('Operator / Fleet Name', operatorCtrl, 'e.g. Daewoo Express Luxury', Icons.directions_bus_outlined),
                const SizedBox(height: 14),

                // Origin -> Destination
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From (Origin)', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: origin,
                            isExpanded: true,
                            items: _pakistanCities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                            onChanged: (val) {
                              if (val != null) setModal(() => origin = val);
                            },
                            decoration: _inputDecoration('', Icons.trip_origin_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('To (Destination)', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: destination,
                            isExpanded: true,
                            items: _pakistanCities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                            onChanged: (val) {
                              if (val != null) setModal(() => destination = val);
                            },
                            decoration: _inputDecoration('', Icons.location_on_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _buildInputField('Base Fare (PKR)', baseFareCtrl, '4500', Icons.payments_outlined, isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInputField('Total Seats', seatsCtrl, '32', Icons.airline_seat_recline_normal_outlined, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _buildInputField('Departure Time', departureTimeCtrl, '08:30 AM', Icons.schedule_rounded)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInputField('Trip Duration', timeDurationCtrl, '4h 30m', Icons.timelapse_rounded)),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Ticket Class Pricing (PKR)', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInputField('Economy', econFareCtrl, '4500', null, isNumber: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Executive', execFareCtrl, '6200', null, isNumber: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('VIP / Sleeper', bizFareCtrl, '8000', null, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 14),
                _buildInputField('Booking Contact / Helpline', phoneCtrl, '+92 300 7654321', Icons.phone_outlined),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    if (operatorCtrl.text.trim().isEmpty) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(ctx);
                    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'provider_user';
                    final routeStr = '$origin -> $destination';
                    final fareP = double.tryParse(baseFareCtrl.text) ?? 4500;
                    final typeMap = <String, double>{
                      'Economy': double.tryParse(econFareCtrl.text) ?? fareP,
                      'Executive': double.tryParse(execFareCtrl.text) ?? (fareP * 1.3),
                      'Business / VIP': double.tryParse(bizFareCtrl.text) ?? (fareP * 1.7),
                    };

                    IconData iconData = Icons.directions_bus;
                    if (category == 'flight') iconData = Icons.flight;
                    if (category == 'train') iconData = Icons.train;
                    if (category == 'car') iconData = Icons.airport_shuttle;

                    await _transportService.addTransportOption(TransportOption(
                      id: '',
                      type: operatorCtrl.text.trim(),
                      route: routeStr,
                      fare: fareP,
                      time: timeDurationCtrl.text.trim(),
                      icon: iconData,
                      category: category,
                      departureTime: departureTimeCtrl.text.trim(),
                      availableSeats: int.tryParse(seatsCtrl.text) ?? 20,
                      operator: operatorCtrl.text.trim(),
                      vendorId: uid,
                      websiteUrl: phoneCtrl.text.trim(),
                      typePrices: typeMap,
                    ));

                    nav.pop();
                    messenger.showSnackBar(const SnackBar(content: Text('Fleet route registered live on SastaSafar!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.transportColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Register Route Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── C. ADD RESTAURANT MODAL ───────────────────────────────────────────────
  void _showAddRestaurantModal() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final basePriceCtrl = TextEditingController(text: '850');
    final phoneCtrl = TextEditingController(text: '+92-300-9876543');
    final dish1NameCtrl = TextEditingController(text: 'Chicken Karahi (Half)');
    final dish1PriceCtrl = TextEditingController(text: '1200');
    final dish2NameCtrl = TextEditingController(text: 'Mutton Shinwari (1kg)');
    final dish2PriceCtrl = TextEditingController(text: '2800');
    final dish3NameCtrl = TextEditingController(text: 'Special BBQ Platter');
    final dish3PriceCtrl = TextEditingController(text: '1600');

    String selectedCity = _pakistanCities.first;
    String selectedCuisine = 'Pakistani BBQ & Karahi';
    String selectedImageUrl = '';

    final cuisines = [
      'Pakistani BBQ & Karahi',
      'Shinwari & Peshawari Meat',
      'Desi & Continental',
      'Fresh River Trout & Seafood',
      'Fast Food & Grills',
      'Traditional Sweets & Bakery',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.all(22),
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.foodColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.restaurant_rounded, color: AppTheme.foodColor)),
                    const SizedBox(width: 10),
                    Text('Add Restaurant & Dining', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                _buildInputField('Restaurant Name', nameCtrl, 'e.g. Haveli Heritage Restaurant', Icons.storefront_outlined),
                const SizedBox(height: 14),

                Text('City & Location', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  isExpanded: true,
                  items: _pakistanCities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setModal(() => selectedCity = val);
                  },
                  decoration: _inputDecoration('', Icons.location_city_rounded),
                ),
                const SizedBox(height: 14),

                _buildInputField('Street Address / Market', addressCtrl, 'e.g. Fort Road Food Street', Icons.pin_drop_outlined),
                const SizedBox(height: 14),

                Text('Cuisine Specialty', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedCuisine,
                  isExpanded: true,
                  items: cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12.5)))).toList(),
                  onChanged: (val) {
                    if (val != null) setModal(() => selectedCuisine = val);
                  },
                  decoration: _inputDecoration('', Icons.fastfood_outlined),
                ),
                const SizedBox(height: 14),

                _buildInputField('Average Cost Per Person (PKR)', basePriceCtrl, '850', Icons.payments_outlined, isNumber: true),
                const SizedBox(height: 18),

                Text('Signature Dishes & Menu Prices', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildInputField('Dish 1 Name', dish1NameCtrl, 'Chicken Karahi', null)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildInputField('Price (PKR)', dish1PriceCtrl, '1200', null, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildInputField('Dish 2 Name', dish2NameCtrl, 'Mutton Karahi', null)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildInputField('Price (PKR)', dish2PriceCtrl, '2800', null, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildInputField('Dish 3 Name', dish3NameCtrl, 'BBQ Platter', null)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildInputField('Price (PKR)', dish3PriceCtrl, '1600', null, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 14),

                _buildInputField('Phone for Table Booking', phoneCtrl, '+92 300 9876543', Icons.phone_outlined),
                const SizedBox(height: 14),

                _buildGalleryImagePicker(
                  title: 'Restaurant Photo',
                  imagePath: selectedImageUrl,
                  onTap: () async {
                    final path = await _pickImageFromGallery();
                    if (path != null) {
                      setModal(() => selectedImageUrl = path);
                    }
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(ctx);
                    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'provider_user';
                    final fullLocation = '${addressCtrl.text.trim()}, $selectedCity';
                    final baseP = double.tryParse(basePriceCtrl.text) ?? 850;
                    final typeMap = <String, double>{
                      dish1NameCtrl.text.trim(): double.tryParse(dish1PriceCtrl.text) ?? 1200,
                      dish2NameCtrl.text.trim(): double.tryParse(dish2PriceCtrl.text) ?? 2800,
                      dish3NameCtrl.text.trim(): double.tryParse(dish3PriceCtrl.text) ?? 1600,
                    };

                    final finalImg = selectedImageUrl.trim().isNotEmpty
                        ? selectedImageUrl.trim()
                        : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800';

                    await _restaurantService.addRestaurant(Restaurant(
                      id: '',
                      name: nameCtrl.text.trim(),
                      cuisine: selectedCuisine,
                      price: baseP,
                      location: fullLocation,
                      vendorId: uid,
                      imageUrl: finalImg,
                      phone: phoneCtrl.text.trim(),
                      typePrices: typeMap,
                    ));

                    nav.pop();
                    messenger.showSnackBar(const SnackBar(content: Text('Restaurant & Menu published live!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.foodColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Publish Dining Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── D. ADD TOUR GUIDE MODAL ───────────────────────────────────────────────
  void _showAddGuideModal() {
    final nameCtrl = TextEditingController();
    final carCtrl = TextEditingController(text: 'Toyota Prado TX 4x4 (AC & Heated)');
    final expCtrl = TextEditingController(text: '8 Years Guiding Experience');
    final dailyRateCtrl = TextEditingController(text: '7000');
    final phoneCtrl = TextEditingController(text: '+92 355 5123456');
    final whatsappCtrl = TextEditingController(text: '923555123456');
    final bioCtrl = TextEditingController(text: 'Licensed local mountain guide. Safe high-altitude driver for families and solo travelers.');

    String selectedRegion = 'Hunza';
    String selectedRole = '4x4 Mountain Guide';
    bool isFemaleFriendly = true;
    String selectedImageUrl = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.all(22),
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF3F51B5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.explore_rounded, color: Color(0xFF3F51B5))),
                    const SizedBox(width: 10),
                    Text('Register as Local Guide', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                _buildInputField('Guide Full Name', nameCtrl, 'e.g. Aslam Khan Hunzai', Icons.badge_outlined),
                const SizedBox(height: 14),

                Text('Primary Region / Area', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  isExpanded: true,
                  items: _pakistanCities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setModal(() => selectedRegion = val);
                  },
                  decoration: _inputDecoration('', Icons.terrain_rounded),
                ),
                const SizedBox(height: 14),

                _buildInputField('Role / Specialization', TextEditingController(text: selectedRole), '4x4 Mountain Driver', Icons.military_tech_outlined),
                const SizedBox(height: 14),

                _buildInputField('Vehicle / Car Model', carCtrl, 'e.g. Toyota Prado TX 4x4 (AC & Heated)', Icons.directions_car_outlined),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _buildInputField('Experience', expCtrl, '8 Years Guiding', Icons.history_edu_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInputField('Per Day Rate (PKR)', dailyRateCtrl, '7000', Icons.payments_outlined, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _buildInputField('Direct Call Phone', phoneCtrl, '+92 355 5123456', Icons.phone_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInputField('WhatsApp Number', whatsappCtrl, '923555123456', Icons.chat_outlined)),
                  ],
                ),
                const SizedBox(height: 14),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Female-Friendly & Safe for Families', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  subtitle: Text('Show verification badge to female solo travelers', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                  value: isFemaleFriendly,
                  activeColor: AppTheme.primaryPurple,
                  onChanged: (val) => setModal(() => isFemaleFriendly = val),
                ),
                const SizedBox(height: 14),

                _buildGalleryImagePicker(
                  title: 'Guide Profile Photo',
                  imagePath: selectedImageUrl,
                  onTap: () async {
                    final path = await _pickImageFromGallery();
                    if (path != null) {
                      setModal(() => selectedImageUrl = path);
                    }
                  },
                ),
                const SizedBox(height: 14),
                _buildInputField('Bio / About Me', bioCtrl, 'Local history, photography spots...', Icons.edit_note_outlined, maxLines: 2),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(ctx);
                    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'provider_user';
                    final rateP = double.tryParse(dailyRateCtrl.text) ?? 7000;

                    final finalImg = selectedImageUrl.trim().isNotEmpty
                        ? selectedImageUrl.trim()
                        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400';

                    await _guideService.addGuide(LocalGuide(
                      id: '',
                      name: nameCtrl.text.trim(),
                      role: selectedRole,
                      region: selectedRegion,
                      rating: 4.9,
                      dailyRatePkr: rateP,
                      tripCount: 45,
                      imageUrl: finalImg,
                      isVerified: true,
                      isFemaleFriendly: isFemaleFriendly,
                      experience: expCtrl.text.trim(),
                      car: carCtrl.text.trim(),
                      contactNumber: phoneCtrl.text.trim(),
                      whatsappNumber: whatsappCtrl.text.trim(),
                      bio: bioCtrl.text.trim(),
                      vendorId: uid,
                    ));

                    nav.pop();
                    messenger.showSnackBar(const SnackBar(content: Text('Tour Guide registered live on SastaSafar!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Register Guide Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HELPER WIDGETS ────────────────────────────────────────────────────────
  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
    IconData? icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.grey[800])),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
      prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryPurple, size: 18) : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 1.5)),
    );
  }
}
