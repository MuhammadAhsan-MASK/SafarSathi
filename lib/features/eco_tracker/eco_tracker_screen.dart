import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class EcoTrackerScreen extends StatefulWidget {
  const EcoTrackerScreen({super.key});

  @override
  State<EcoTrackerScreen> createState() => _EcoTrackerScreenState();
}

class _EcoTrackerScreenState extends State<EcoTrackerScreen> {
  String _transportMode = 'Bus';
  double _distance = 300; // default to 300 km
  int _ecoPoints = 0;

  double _calculateFootprint() {
    // Basic approximate CO2 emissions in kg per km
    final factors = {
      'Bus': 0.05,
      'Train': 0.04,
      'Car': 0.15,
      'Jeep / SUV': 0.20,
      'Air': 0.25,
    };
    return _distance * (factors[_transportMode] ?? 0.1);
  }

  void _recalculate() {
    final kgCO2 = _calculateFootprint();
    setState(() {
      if (kgCO2 < 20) {
        _ecoPoints = 50; 
      } else if (kgCO2 < 50) {
        _ecoPoints = 25;
      } else if (kgCO2 < 100) {
        _ecoPoints = 10;
      } else {
        _ecoPoints = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  Widget build(BuildContext context) {
    final co2 = _calculateFootprint();

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('Carbon Footprint Tracker'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildInputSection(),
                  const SizedBox(height: 24),
                  _buildResultsCard(co2),
                  const SizedBox(height: 24),
                  _buildEcoBadges(co2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travel Green 🌿',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your travel choices impact Pakistan\'s beautiful environment. Calculate and minimize your carbon footprint.',
            style: GoogleFonts.poppins(color: Colors.green.shade100, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transport Mode', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _transportMode,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              prefixIcon: Icon(Icons.directions_transit, color: Colors.green.shade700),
            ),
            items: ['Bus', 'Train', 'Car', 'Jeep / SUV', 'Air']
                .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) {
              setState(() {
                _transportMode = val!;
                _recalculate();
              });
            },
          ),
          const SizedBox(height: 20),
          Text('Trip Distance (km)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _distance,
                  min: 50,
                  max: 2000,
                  divisions: 39,
                  activeColor: Colors.green,
                  label: '${_distance.round()} km',
                  onChanged: (val) {
                    setState(() {
                      _distance = val;
                      _recalculate();
                    });
                  },
                ),
              ),
              Text('${_distance.round()} km', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard(double co2) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: co2 > 100 
            ? [Colors.orange.shade400, Colors.deepOrange.shade600]
            : [Colors.green.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Icon(Icons.co2, color: Colors.white, size: 50),
          const SizedBox(height: 8),
          Text(
            '${co2.toStringAsFixed(1)} kg',
            style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'Estimated CO₂ Emissions',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoBadges(double co2) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _ecoPoints > 0 ? Icons.workspace_premium : Icons.nature_people,
                color: _ecoPoints > 0 ? Colors.amber : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                '$_ecoPoints Eco-Points earned',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _ecoPoints == 50
                ? "Incredible! You're a true Eco-Warrior."
                : _ecoPoints > 0
                    ? "Good job choosing sustainable travel options!"
                    : "Consider taking a bus or train to reduce your emissions.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
