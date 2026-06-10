import 'package:firebase_auth/firebase_auth.dart';
import '../profile/profile_screen.dart';
import '../../core/theme.dart';
import '../hotels/services/hotel_service.dart';
import '../hotels/models/hotel_model.dart';
import '../restaurants/services/restaurant_service.dart';
import '../restaurants/models/restaurant_model.dart';
import '../attractions/services/attraction_service.dart';
import '../attractions/models/attraction_model.dart';
import '../transport/services/transport_service.dart';
import '../transport/models/transport_model.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

  final TransportService _transportService = TransportService();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addHotel() {
    showDialog(
      context: context,
      builder: (context) => _BuildAddServiceDialog(
        title: 'Add Hotel',
        onAdd: (name, location, price, type, description) async {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          await _hotelService.addHotel(Hotel(
            id: '',
            name: name,
            location: location,
            price: price,
            rating: 4.0,
            description: description.isEmpty ? 'New hotel added by provider' : description,
            vendorId: uid,
          ));
        },
      ),
    );
  }

  void _addRestaurant() {
    showDialog(
      context: context,
      builder: (context) => _BuildAddServiceDialog(
        title: 'Add Restaurant',
        isRestaurant: true,
        onAdd: (name, location, price, type, description) async {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          await _restaurantService.addRestaurant(Restaurant(
            id: '',
            name: name,
            cuisine: type,
            price: price,
            location: location,
            vendorId: uid,
          ));
        },
      ),
    );
  }

  void _addAttraction() {
    showDialog(
      context: context,
      builder: (context) => _BuildAddServiceDialog(
        title: 'Add Attraction',
        isAttraction: true,
        onAdd: (name, location, price, type, description) async {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          await _attractionService.addAttraction(Attraction(
            id: '',
            name: name,
            city: location,
            type: type,
            fee: price,
            vendorId: uid,
          ));
        },
      ),
    );
  }

  void _addTransport() {
    showDialog(
      context: context,
      builder: (context) => _BuildAddServiceDialog(
        title: 'Add Transport',
        isTransport: true,
        onAdd: (name, location, price, type, description) async {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          await _transportService.addTransportOption(TransportOption(
            id: '',
            type: name,
            route: location,
            fare: price,
            time: type, // Using type field for time in transport context
            icon: name.toLowerCase().contains('flight') ? Icons.flight : Icons.directions_bus,
            vendorId: uid,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardMainContent(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardMainContent() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildStatsRow(),
            const SizedBox(height: 40),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildServiceCard('Hotels', Icons.hotel, 'Add and manage hotel listings', AppTheme.hotelColor, AppTheme.hotelBg, _addHotel),
            const SizedBox(height: 16),
            _buildServiceCard('Restaurants', Icons.restaurant, 'Add and manage dining spots', AppTheme.foodColor, AppTheme.foodBg, _addRestaurant),
            const SizedBox(height: 16),
            _buildServiceCard('Attractions', Icons.attractions, 'Add and manage tourist spots', AppTheme.attractionColor, AppTheme.attractionBg, _addAttraction),
            const SizedBox(height: 16),
            _buildServiceCard('Transport', Icons.directions_bus, 'Add and manage transport routes', AppTheme.transportColor, AppTheme.transportBg, _addTransport),
            const SizedBox(height: 40),
            const Text(
              'My Listings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMyListings(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        Text(
          user?.email?.split('@')[0].toUpperCase() ?? 'Partner',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Total Listings', '12', Icons.list_alt, Colors.blue),
        const SizedBox(width: 16),
        _buildStatCard('Views', '2.4k', Icons.remove_red_eye_outlined, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyListings() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Column(
      children: [
        _buildListingStream('Hotels', _hotelService.getHotelsByVendor(uid), (id) => _hotelService.deleteHotel(id)),
        _buildListingStream('Restaurants', _restaurantService.getRestaurantsByVendor(uid), (id) => _restaurantService.deleteRestaurant(id)),
        _buildListingStream('Attractions', _attractionService.getAttractionsByVendor(uid), (id) => _attractionService.deleteAttraction(id)),
        _buildListingStream('Transport', _transportService.getTransportOptionsByVendor(uid), (id) => _transportService.deleteTransportOption(id)),
      ],
    );
  }

  Widget _buildListingStream(String title, Stream<List<dynamic>> stream, Function(String) onDelete) {
    return StreamBuilder<List<dynamic>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ...snapshot.data!.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  item is TransportOption ? item.type : item.name,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item is TransportOption ? item.route : item.location is String ? item.location : (item is Attraction ? item.city : ''),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDelete(item.id),
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(String title, IconData icon, String subtitle, Color color, Color bgColor, VoidCallback onTap) {
    return Card(
      elevation: 4,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.add_circle, color: color, size: 30),
        onTap: onTap,
      ),
    );
  }
}

class _BuildAddServiceDialog extends StatefulWidget {
  final String title;
  final bool isRestaurant;
  final bool isAttraction;
  final bool isTransport;
  final Function(String name, String location, double price, String type, String description) onAdd;

  const _BuildAddServiceDialog({
    required this.title,
    this.isRestaurant = false,
    this.isAttraction = false,
    this.isTransport = false,
    required this.onAdd,
  });

  @override
  State<_BuildAddServiceDialog> createState() => _BuildAddServiceDialogState();
}

class _BuildAddServiceDialogState extends State<_BuildAddServiceDialog> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String typeLabel = 'Type';
    if (widget.isRestaurant) typeLabel = 'Cuisine';
    if (widget.isAttraction) typeLabel = 'Category (e.g. Nature)';
    if (widget.isTransport) typeLabel = 'Departure Time';

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isTransport) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Operator / Vehicle',
                  hintText: 'e.g. Daewoo Express',
                  prefixIcon: Icon(Icons.directions_bus),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Route',
                  hintText: 'e.g. LHR - ISL',
                  prefixIcon: Icon(Icons.route),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Fare (Rs)',
                  hintText: 'e.g. 1500',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Departure Time',
                  hintText: 'e.g. 08:00 AM',
                  prefixIcon: Icon(Icons.schedule),
                ),
              ),
            ] else if (widget.isAttraction) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Attraction Name',
                  hintText: 'e.g. Badshahi Mosque',
                  prefixIcon: Icon(Icons.place),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'e.g. Lahore',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Entry Fee (Rs)',
                  hintText: 'e.g. 200, or 0 for free',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g. Historical, Nature, Food',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
            ] else if (widget.isRestaurant) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  hintText: 'e.g. Café Gulberg',
                  prefixIcon: Icon(Icons.restaurant),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location / City',
                  hintText: 'e.g. Lahore, DHA',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Per Person Price (Rs)',
                  hintText: 'e.g. 1200',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Cuisine Type',
                  hintText: 'e.g. Pakistani, BBQ, Chinese',
                  prefixIcon: Icon(Icons.local_dining),
                ),
              ),
            ] else ...[
              // Hotel fields
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Hotel Name',
                  hintText: 'e.g. Pearl Continental',
                  prefixIcon: Icon(Icons.hotel),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location / City',
                  hintText: 'e.g. Lahore',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Room Rate (Rs/night)',
                  hintText: 'e.g. 8000',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Room Type',
                  hintText: 'e.g. Standard, Deluxe, Suite',
                  prefixIcon: Icon(Icons.king_bed),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Brief description...',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            widget.onAdd(
              _nameController.text,
              _locationController.text,
              double.tryParse(_priceController.text) ?? 0,
              _typeController.text,
              _descriptionController.text,
            );
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
