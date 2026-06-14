import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../auth/user_role_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final roleService = UserRoleService();

    return FutureBuilder<String?>(
      future: roleService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPremiumHeader(context, user, role),
                      const SizedBox(height: 30),
                      if (role != 'Service Provider' && role != 'Hotel Owner' && role != 'Restaurant Owner' && role != 'Transport Provider') ...[
                        _buildSection(
                          'My Trip Library',
                          [
                            _buildTripCard('Summer in Naran', 'PKR 45,000', '25 June - 30 June', Colors.blue),
                            _buildTripCard('Lahore Food Tour', 'PKR 12,500', '12 July - 14 July', Colors.orange),
                          ],
                        ),
                      ] else ...[
                        _buildSection(
                          'Business Performance',
                          [
                            _buildStatCard('Active Listings', '12', Icons.list_alt, AppTheme.primaryPurple),
                            _buildStatCard('Monthly Reach', '2.4k', Icons.trending_up, Colors.green),
                          ],
                        ),
                      ],
                      _buildSection(
                        'Preferences',
                        [
                          _buildSettingTile(Icons.person_outline, 'Personal Information'),
                          _buildSettingTile(Icons.notifications_none, 'Notification Settings'),
                          _buildSettingTile(Icons.security, 'Privacy & Security'),
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

  Widget _buildTripCard(String title, String price, String date, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.map_outlined, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(price, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
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

  Widget _buildSettingTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        contentPadding: EdgeInsets.zero,
        onTap: () {},
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
