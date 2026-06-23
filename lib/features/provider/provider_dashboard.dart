import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../hotels/services/hotel_service.dart';
import '../hotels/models/hotel_model.dart';
import '../restaurants/services/restaurant_service.dart';
import '../restaurants/models/restaurant_model.dart';
import '../transport/services/transport_service.dart';
import '../transport/models/transport_model.dart';
import '../profile/profile_screen.dart';
import '../auth/user_role_service.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  final TransportService _transportService = TransportService();
  int _selectedIndex = 0;
  bool _isSwitching = false;

  void _handleQuickSwitch() async {
    final roleService = UserRoleService();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Provider Mode'),
        content: const Text('Do you want to switch back to Traveler mode?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
            child: const Text('Switch Now', style: TextStyle(color: Colors.white)),
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

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProviderHeader(),
          const SizedBox(height: 30),
          _buildStatsSection(),
          const SizedBox(height: 30),
          _buildManageSection(),
          const SizedBox(height: 30),
          _buildQuickActions(),
          const SizedBox(height: 30),
          _buildMyListingsSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProviderHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hotel Manager', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                    Text(
                      user?.email?.split('@')[0].toUpperCase() ?? 'Partner',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _handleQuickSwitch,
                child: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.swap_horiz_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: 0.0,
                          strokeWidth: 8,
                          backgroundColor: Color(0xFFF3E5F5),
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                        ),
                      ),
                      Text('0%', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Occupancy Rate', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildSimpleStatCard('Monthly Revenue', 'PKR 0', Icons.trending_up, Colors.green),
                const SizedBox(height: 12),
                _buildSimpleStatCard('Total Bookings', '0', Icons.book_online, Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage Property', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildManagementCard('Rooms & Pricing', 'Manage inventory and rates', Icons.king_bed_outlined, AppTheme.primaryPurple),
          const SizedBox(height: 12),
          _buildManagementCard('Recent Bookings', 'Review guest reservations', Icons.history, Colors.orange),
          const SizedBox(height: 12),
          _buildManagementCard('Guest Reviews', 'Respond to feedback', Icons.star_outline, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildManagementCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton('Add Hotel', Icons.hotel, _addHotel, AppTheme.hotelColor),
              _buildActionButton('Add Food', Icons.restaurant, _addRestaurant, AppTheme.foodColor),
              _buildActionButton('Add Fleet', Icons.directions_bus, _addTransport, AppTheme.transportColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMyListingsSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Listings', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: AppTheme.primaryPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryPurple,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Hotels'),
                    Tab(text: 'Food'),
                    Tab(text: 'Fleet'),
                  ],
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      _buildHotelList(user.uid),
                      _buildRestaurantList(user.uid),
                      _buildTransportList(user.uid),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelList(String vendorId) {
    return StreamBuilder<List<Hotel>>(
      stream: _hotelService.getHotelsByVendor(vendorId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return const Center(child: Text('No hotels added yet'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) => _buildListItem(items[i].name, items[i].location, () => _hotelService.deleteHotel(items[i].id)),
        );
      },
    );
  }

  Widget _buildRestaurantList(String vendorId) {
    return StreamBuilder<List<Restaurant>>(
      stream: _restaurantService.getRestaurantsByVendor(vendorId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return const Center(child: Text('No restaurants added yet'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) => _buildListItem(items[i].name, items[i].location, () => _restaurantService.deleteRestaurant(items[i].id)),
        );
      },
    );
  }

  Widget _buildTransportList(String vendorId) {
    return StreamBuilder<List<TransportOption>>(
      stream: _transportService.getTransportOptionsByVendor(vendorId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return const Center(child: Text('No fleet added yet'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) => _buildListItem(items[i].type, items[i].route, () => _transportService.deleteTransportOption(items[i].id)),
        );
      },
    );
  }

  Widget _buildListItem(String title, String subtitle, VoidCallback onDelete) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onDelete),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor: AppTheme.primaryPurple,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Stats'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _addHotel() {
    showDialog(context: context, builder: (context) => _BuildAddServiceDialog(title: 'Add Hotel', onAdd: (name, loc, price, type, desc) async {
      await _hotelService.addHotel(Hotel(id: '', name: name, location: loc, price: price, rating: 4.0, description: desc, vendorId: FirebaseAuth.instance.currentUser?.uid ?? ''));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hotel added successfully!')));
    }));
  }

  void _addRestaurant() {
    showDialog(context: context, builder: (context) => _BuildAddServiceDialog(title: 'Add Restaurant', isRestaurant: true, onAdd: (name, loc, price, type, desc) async {
      await _restaurantService.addRestaurant(Restaurant(id: '', name: name, cuisine: type, price: price, location: loc, vendorId: FirebaseAuth.instance.currentUser?.uid ?? ''));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restaurant added successfully!')));
    }));
  }

  void _addTransport() {
    showDialog(context: context, builder: (context) => _BuildAddServiceDialog(title: 'Add Transport', isTransport: true, onAdd: (name, loc, price, type, desc) async {
      await _transportService.addTransportOption(TransportOption(id: '', type: name, route: loc, fare: price, time: type, icon: Icons.directions_bus, vendorId: FirebaseAuth.instance.currentUser?.uid ?? ''));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transport added successfully!')));
    }));
  }
}

class _BuildAddServiceDialog extends StatefulWidget {
  final String title;
  final bool isRestaurant;
  final bool isTransport;
  final Function(String name, String location, double price, String type, String description) onAdd;

  const _BuildAddServiceDialog({required this.title, this.isRestaurant = false, this.isTransport = false, required this.onAdd});

  @override State<_BuildAddServiceDialog> createState() => _BuildAddServiceDialogState();
}

class _BuildAddServiceDialogState extends State<_BuildAddServiceDialog> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: _typeController, decoration: InputDecoration(labelText: widget.isRestaurant ? 'Cuisine' : 'Type')),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          widget.onAdd(_nameController.text, _locationController.text, double.tryParse(_priceController.text) ?? 0, _typeController.text, _descriptionController.text);
          Navigator.pop(context);
        }, child: const Text('Add')),
      ],
    );
  }
}
