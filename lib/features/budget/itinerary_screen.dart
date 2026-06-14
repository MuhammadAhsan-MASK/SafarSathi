import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Trip Itinerary'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildTimelineSlot('Morning', '09:00 AM', 'Visit Rakaposhi View Point', 'Refreshments & Sightseeing', Icons.wb_sunny_outlined, Colors.orange),
                _buildTimelineSlot('Afternoon', '01:30 PM', 'Lunch at Hunza Food Pavilion', 'Traditional local cuisine', Icons.restaurant, Colors.deepOrange),
                _buildTimelineSlot('Evening', '04:00 PM', 'Altit Fort Exploration', 'Historical tour & Photography', Icons.fort_outlined, Colors.brown),
                _buildTimelineSlot('Night', '08:00 PM', 'Stargazing at Duiker', 'Stunning peaks view', Icons.nightlight_round_outlined, Colors.indigo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          bool isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryPurple : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Day', style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 10)),
                const SizedBox(height: 4),
                Text('${index + 1}', style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineSlot(String timeOfDay, String time, String title, String description, IconData icon, Color color) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(timeOfDay, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                      Text(time, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(description, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('Est. PKR 1,500', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
