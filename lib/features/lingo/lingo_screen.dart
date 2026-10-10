import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'region_lingo_screen.dart';

class LingoScreen extends StatelessWidget {
  const LingoScreen({super.key});

  final List<Map<String, dynamic>> regions = const [
    {
      'name': 'Gilgit-Baltistan',
      'languages': 'Shina, Balti, Burushaski',
      'icon': Icons.terrain_rounded,
      'color': Colors.blueGrey,
    },
    {
      'name': 'Khyber Pakhtunkhwa',
      'languages': 'Pashto, Hindko',
      'icon': Icons.landscape_rounded,
      'color': Colors.teal,
    },
    {
      'name': 'Punjab',
      'languages': 'Punjabi, Seraiki',
      'icon': Icons.agriculture_rounded,
      'color': Colors.orange,
    },
    {
      'name': 'Sindh',
      'languages': 'Sindhi, Urdu',
      'icon': Icons.water_rounded,
      'color': Colors.blue,
    },
    {
      'name': 'Balochistan',
      'languages': 'Balochi, Brahui, Pashto',
      'icon': Icons.brightness_high_rounded,
      'color': Colors.brown,
    },
    {
      'name': 'Kashmir & Neelum',
      'languages': 'Pahari, Hindko, Kashmiri',
      'icon': Icons.park_rounded,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Safar Lingo'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: regions.length,
        itemBuilder: (context, index) {
          final region = regions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (region['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(region['icon'] as IconData, color: region['color'] as Color),
              ),
              title: Text(
                region['name'] as String,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                region['languages'] as String,
                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegionLingoScreen(
                      regionName: region['name'] as String,
                      color: region['color'] as Color,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
