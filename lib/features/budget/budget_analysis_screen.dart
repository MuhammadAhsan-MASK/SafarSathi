import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'itinerary_screen.dart';

class BudgetAnalysisScreen extends StatelessWidget {
  const BudgetAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Budget Analysis'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHealthScoreCard(),
            const SizedBox(height: 30),
            _buildCostSummary(),
            const SizedBox(height: 30),
            _buildAnalysisInsights(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ItineraryScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('View Detailed Itinerary'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
      ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: 0.72,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Column(
                children: [
                  Text(
                    '--',
                    style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    'No Data',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Incomplete',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          Text(
            'Plan a trip to see your budget analysis.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimated Total Cost', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PKR 0',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
              ),
              const Icon(Icons.receipt_long_outlined, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analysis Summary', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInsightItem(Icons.info_outline, 'Add destinations to get cost insights.', Colors.grey),
      ],
    );
  }

  Widget _buildInsightItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
