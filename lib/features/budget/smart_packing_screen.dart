import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/gemini_service.dart';

class SmartPackingScreen extends StatefulWidget {
  final String destination;
  final String duration;
  final String weather; // simple string pass for now

  const SmartPackingScreen({
    super.key,
    required this.destination,
    required this.duration,
    required this.weather,
  });

  @override
  State<SmartPackingScreen> createState() => _SmartPackingScreenState();
}

class _SmartPackingScreenState extends State<SmartPackingScreen> {
  String _selectedVibe = 'Adventure';
  bool _isLoading = false;
  List<Map<String, dynamic>>? _packingList;

  final vibes = [
    'Adventure', 'Relaxation', 'Cultural', 'Business', 'Family',
  ];

  Future<void> _generateList() async {
    setState(() => _isLoading = true);
    try {
      final list = await GeminiService.generatePackingList(
        destination: widget.destination,
        vibe: _selectedVibe,
        duration: widget.duration,
        weatherConditions: widget.weather,
      );
      if (mounted) setState(() => _packingList = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate packing list: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Smart Packing AI'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_packingList != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  for (final cat in _packingList!) {
                    for (final item in cat['items'] as List<dynamic>) {
                      (item as Map<String, dynamic>)['checked'] = false;
                    }
                  }
                });
              },
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildPreferencesHeader(),
          if (_packingList != null) _buildProgressBanner(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _packingList == null
                ? _buildEmptyState()
                : _buildChecklist(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Destination: ${widget.destination}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Duration: ${widget.duration} | Weather: ${widget.weather}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          Text('Trip Vibe', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedVibe,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: vibes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() {
              _selectedVibe = v!;
              _packingList = null; 
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateList,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Smart Checklist'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBanner() {
    int total = 0;
    int checked = 0;
    for (final cat in _packingList!) {
      for (final item in cat['items'] as List<dynamic>) {
        total++;
        if ((item as Map<String, dynamic>)['checked'] == true) checked++;
      }
    }
    final progress = total == 0 ? 0.0 : checked / total;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Packing Progress', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('$checked / $total packed', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : AppTheme.primaryPurple,
              ),
            ),
          ),
          if (progress == 1.0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text('All packed! You\'re ready to go! 🎒', style: GoogleFonts.poppins(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.backpack_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Ready to Pack?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Tap the button above to let AI analyze the location, weather, and vibe to generate your perfect packing list.', 
              textAlign: TextAlign.center, 
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _packingList!.length,
      itemBuilder: (context, i) {
        final categoryMap = _packingList![i];
        final category = categoryMap['category'] as String;
        final items = categoryMap['items'] as List<dynamic>;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            title: Text(category, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            initiallyExpanded: true,
            children: items.map((itemObj) {
              final itemInfo = itemObj as Map<String, dynamic>;
              return CheckboxListTile(
                value: itemInfo['checked'] ?? false,
                onChanged: (val) {
                  setState(() {
                    itemInfo['checked'] = val;
                  });
                },
                title: Text(itemInfo['item'] as String, style: GoogleFonts.poppins()),
                subtitle: Text(itemInfo['reason'] as String, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primaryPurple,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
