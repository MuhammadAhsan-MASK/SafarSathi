import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../auth/user_role_service.dart';
import 'saved_items_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSwitchingRole = false;

  Future<void> _handleRoleSwitch(String currentRole) async {
    final roleService = UserRoleService();
    String newRole = currentRole == 'Traveler' ? 'Service Provider' : 'Traveler';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newRole == 'Service Provider' ? 'Become a Provider' : 'Switch Mode'),
        content: Text(newRole == 'Service Provider' 
          ? 'Do you want to become a service provider?' 
          : 'Do you want to switch back to traveler mode?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
            child: Text(newRole == 'Service Provider' ? 'Become Provider' : 'Switch Now', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSwitchingRole = true);
      try {
        await roleService.updateUserRole(newRole);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully switched to $newRole mode')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to switch role: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSwitchingRole = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final roleService = UserRoleService();

    return StreamBuilder<String?>(
      stream: roleService.getUserRoleStream(),
      builder: (context, snapshot) {
        final role = snapshot.data;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: (snapshot.connectionState == ConnectionState.waiting || _isSwitchingRole)
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPremiumHeader(context, user, role),
                      const SizedBox(height: 20),
                      
                      // Role Switching Banner
                      if (role != null) _buildRoleSwitchBanner(role),
                      
                      const SizedBox(height: 10),
                      if (role != 'Service Provider' && role != 'Hotel Owner' && role != 'Restaurant Owner' && role != 'Transport Provider') ...[
                        _buildSection(
                          'My Trip Library',
                          [
                            _buildEmptyState('No trips added yet', Icons.map_outlined),
                          ],
                        ),
                      ] else ...[
                        _buildSection(
                          'Business Performance',
                          [
                            _buildStatCard('Active Listings', '0', Icons.list_alt, AppTheme.primaryPurple),
                            _buildStatCard('Monthly Reach', '0', Icons.trending_up, Colors.green),
                          ],
                        ),
                      ],
                      _buildSection(
                        'Preferences',
                        [
                          _buildSettingTile(Icons.favorite_outline, 'Saved Items', onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedItemsScreen()));
                          }),
                          _buildSettingTile(Icons.person_outline, 'Personal Information'),
                          _buildSettingTile(Icons.notifications_none, 'Notification Settings'),
                          _buildSettingTile(Icons.security, 'Privacy & Security'),
                        ],
                      ),
                      _buildSection(
                        'Policy & About',
                        [
                          _buildSettingTile(Icons.policy_outlined, 'Privacy Policy'),
                          _buildSettingTile(Icons.gavel_outlined, 'Terms of Service'),
                          _buildSettingTile(Icons.info_outline, 'About SafarSathi'),
                          _buildSettingTile(Icons.help_outline, 'Help & Support'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildLogoutButton(context),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildRoleSwitchBanner(String role) {
    bool isTraveler = role == 'Traveler';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(isTraveler ? Icons.business_center : Icons.person, color: AppTheme.primaryPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTraveler ? 'Become a Service Provider' : 'Switch to Traveler Mode',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      isTraveler 
                        ? 'List your hotel, transport or restaurant' 
                        : 'Plan trips and discover destinations',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleRoleSwitch(role),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isTraveler ? 'GET STARTED' : 'SWITCH MODE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, User? user, String? role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white24,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: AppTheme.primaryPurple),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? (user?.email?.split('@')[0].toUpperCase() ?? 'User Name'),
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (role != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role.toUpperCase(),
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'user@example.com',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.withValues(alpha: 0.3), size: 40),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        contentPadding: EdgeInsets.zero,
        onTap: onTap ?? () {},
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.logout_rounded),
          label: const Text('LOG OUT'),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Log Out'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Log Out', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await FirebaseAuth.instance.signOut();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}
