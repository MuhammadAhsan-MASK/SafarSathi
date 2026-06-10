import 'package:firebase_auth/firebase_auth.dart';
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
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildProfileHeader(context, user, role),
                      const SizedBox(height: 40),
                      if (role != 'Service Provider') ...[
                        _buildSection(
                          context,
                          'Saved Trip Plans',
                          [
                            _buildTripPlanItem(context, 'Summer in Naran', 'Rs. 45,000', '25 June - 30 June'),
                            _buildTripPlanItem(context, 'Lahore Food Tour', 'Rs. 12,500', '12 July - 14 July'),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        _buildSection(
                          context,
                          'Business Overview',
                          [
                            _buildBusinessStatsItem(context, 'Active Listings', '12', Icons.list_alt),
                            _buildBusinessStatsItem(context, 'Monthly Views', '2.4k', Icons.remove_red_eye_outlined),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildSection(
                        context,
                        'Account Settings',
                        [
                          _buildSettingItem(Icons.person_outline, 'Edit Profile'),
                          _buildSettingItem(Icons.notifications_none, 'Notifications'),
                          _buildSettingItem(Icons.security, 'Security'),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: SizedBox(
                          width: double.infinity,
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
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
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
                                if (context.mounted) {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user, String? role) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor),
            ),
// ... same code ...
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? (user?.email?.split('@')[0].toUpperCase() ?? 'User Name'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (role != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'user@example.com',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildTripPlanItem(BuildContext context, String title, String cost, String date) {
// ... same code ...
  }

  Widget _buildBusinessStatsItem(BuildContext context, String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
// ... same code ...
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: EdgeInsets.zero,
      onTap: () {},
    );
  }
}
