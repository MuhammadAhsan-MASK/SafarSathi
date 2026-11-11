import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/role_selection_screen.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/user_role_service.dart';
import '../provider/provider_dashboard.dart';
import '../chatbot/chatbot_screen.dart';

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
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: UserRoleService.localRoleNotifier,
      builder: (context, localRole, _) {
        return StreamBuilder<String?>(
          stream: _roleService.getUserRoleStream(),
          builder: (context, snapshot) {
            if (localRole == null && snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = localRole ?? snapshot.data;

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
              floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A1B9A).withAlpha(110),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SafarBot AI',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(
                top: BorderSide(color: const Color(0xFFEFF0F6), width: 1.2),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppTheme.primaryPurple,
                  unselectedItemColor: Colors.grey.shade400,
                  showUnselectedLabels: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.explore_outlined, size: 22),
                      activeIcon: Icon(Icons.explore_rounded, size: 24),
                      label: 'Discover',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded, size: 22),
                      activeIcon: Icon(Icons.person_rounded, size: 24),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }
}
