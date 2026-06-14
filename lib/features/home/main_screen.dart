import 'package:flutter/material.dart';
import '../auth/role_selection_screen.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import '../hotels/hotel_screen.dart';
import '../restaurants/restaurant_screen.dart';
import '../transport/transport_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/user_role_service.dart';
import '../provider/provider_dashboard.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final UserRoleService _roleService = UserRoleService();

  final List<Widget> _travelerScreens = [
    const HomeScreen(),
    const HotelScreen(),
    const RestaurantScreen(),
    const TransportScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _roleService.getUserRoleStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        if (role == null) {
          return const RoleSelectionScreen();
        }

        if (role == 'Hotel Owner' ||
            role == 'Restaurant Owner' ||
            role == 'Transport Provider' ||
            role == 'Service Provider') {
          return const ProviderDashboard();
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _travelerScreens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryPurple,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              elevation: 0,
              backgroundColor: Colors.white,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.hotel_outlined),
                  activeIcon: Icon(Icons.hotel_rounded),
                  label: 'Hotels',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_outlined),
                  activeIcon: Icon(Icons.restaurant_rounded),
                  label: 'Food',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_bus_outlined),
                  activeIcon: Icon(Icons.directions_bus_rounded),
                  label: 'Transport',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
