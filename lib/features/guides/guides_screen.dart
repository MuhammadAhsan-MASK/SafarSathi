import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'models/guide_model.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  final List<LocalGuide> _allGuides = GuideMockService.fetchMockGuides();
  late List<LocalGuide> _filteredGuides;
  String _selectedRegion = 'All';
  String _selectedRole = 'All';
  bool _onlySafeForFemales = false;

  final List<String> _regions = ['All', 'Hunza Valley', 'Skardu (K2 Basecamp)', 'Naran / Kaghan', 'Swat Valley (Kalam)', 'Lahore'];
  final List<String> _roles = ['All', 'Tour Guide', 'Jeep Driver', 'Porter'];

  @override
  void initState() {
    super.initState();
    _filteredGuides = _allGuides;
  }

  void _filterGuides() {
    setState(() {
      _filteredGuides = _allGuides.where((g) {
        final matchesRegion = _selectedRegion == 'All' || g.region == _selectedRegion;
        final matchesRole = _selectedRole == 'All' || g.role == _selectedRole;
        final matchesSafety = !_onlySafeForFemales || g.isFemaleFriendly;
        return matchesRegion && matchesRole && matchesSafety;
      }).toList();
    });
  }

  void _hireGuide(LocalGuide guide) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hire Request Sent!"),
        content: Text("You have successfully requested to hire ${guide.name}. They will contact you shortly to confirm the booking."),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hire Local Experts'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _filteredGuides.isEmpty
                ? const Center(child: Text('No guides found for the selected filters.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredGuides.length,
                    itemBuilder: (ctx, index) {
                      return _buildGuideCard(_filteredGuides[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Region',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  value: _selectedRegion,
                  items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _selectedRegion = val;
                      _filterGuides();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Role',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  value: _selectedRole,
                  items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _selectedRole = val;
                      _filterGuides();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text("Solo / Female Traveler Safe", style: GoogleFonts.poppins(fontSize: 14)),
            subtitle: const Text("Only show verified safe guides with top ratings", style: TextStyle(fontSize: 11)),
            secondary: const Icon(Icons.security, color: Colors.pinkAccent),
            value: _onlySafeForFemales,
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: Colors.pinkAccent,
            onChanged: (val) {
              setState(() {
                _onlySafeForFemales = val;
                _filterGuides();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(LocalGuide guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                  child: Icon(
                    guide.role == 'Jeep Driver' ? Icons.directions_car : 
                    guide.role == 'Porter' ? Icons.backpack : Icons.person,
                    color: AppTheme.primaryPurple,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(guide.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (guide.isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.verified, color: Colors.blue, size: 18),
                            ),
                          if (guide.isFemaleFriendly)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.security, color: Colors.pinkAccent, size: 18),
                            ),
                        ],
                      ),
                      Text('${guide.role} • ${guide.region}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${guide.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(' (${guide.tripCount} trips)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Provider.of<CurrencyProvider>(context).formatPrice(guide.dailyRatePkr),
                      style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text('/ day', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _hireGuide(guide),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Hire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
