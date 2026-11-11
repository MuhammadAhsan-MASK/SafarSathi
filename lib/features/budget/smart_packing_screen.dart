import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/gemini_service.dart';

class SmartPackingScreen extends StatefulWidget {
  final String destination;
  final String duration;
  final String weather;

  const SmartPackingScreen({
    super.key,
    this.destination = 'Hunza Valley',
    this.duration = '5 Days',
    this.weather = 'Cold & Chilly (5°C)',
  });

  @override
  State<SmartPackingScreen> createState() => _SmartPackingScreenState();
}

class _SmartPackingScreenState extends State<SmartPackingScreen> {
  late String _destination;
  late String _duration;
  late String _weather;
  String _selectedVibe = 'Adventure';
  bool _isLoading = false;
  List<Map<String, dynamic>>? _packingList;

  final vibes = [
    'Adventure', 'Relaxation', 'Cultural', 'Family', 'Photography',
  ];

  final Map<String, (String weather, String vibe, String tip)> _destinationPresets = {
    'Hunza & Northern Areas': (
      'Cold & Chilly (5°C)',
      'Adventure',
      'Northern ATMs often go offline; carry at least PKR 15,000 in cash.'
    ),
    'Murree & Galiyat': (
      'Misty & Road Frost (10°C)',
      'Family',
      'Dense evening fog; keep anti-freeze coolant in car and carry snow chains.'
    ),
    'Swat & Kalam': (
      'Crisp Autumn (7°C)',
      'Adventure',
      'Carry river-friendly waterproof shoes and warm fleece layers for night.'
    ),
    'Skardu & Deosai': (
      'Freezing & Windy (2°C)',
      'Photography',
      'High altitude AMS risk above 4,000m; keep Diamox, ORS, and UV goggles.'
    ),
    'Karachi & Baloch Coast': (
      'Warm & Breezy (28°C)',
      'Relaxation',
      'Pack lightweight cotton clothes, swimwear, and plenty of hydration.'
    ),
    'Lahore & Islamabad': (
      'Mild & Pleasant (19°C)',
      'Cultural',
      'Walking shoes for heritage sites and monuments; light jacket for evenings.'
    ),
  };

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _duration = widget.duration;
    _weather = widget.weather;
    _loadSavedChecklist();
  }

  String get _storageKey => 'safar_packing_${_destination.replaceAll(' ', '_').toLowerCase()}';

  Future<void> _loadSavedChecklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved);
        setState(() {
          _packingList = decoded.map((cat) => Map<String, dynamic>.from(cat)).toList();
        });
        return;
      }
    } catch (e) {
      debugPrint('Error loading saved checklist: $e');
    }

    // If nothing saved yet, generate immediately from local expert database
    _generateLocalCuratedList();
  }

  Future<void> _saveChecklistToStorage() async {
    if (_packingList == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_packingList));
    } catch (e) {
      debugPrint('Error saving checklist: $e');
    }
  }

  void _generateLocalCuratedList() {
    final lowerDest = _destination.toLowerCase();
    final bool isCold = lowerDest.contains('hunza') ||
        lowerDest.contains('skardu') ||
        lowerDest.contains('murree') ||
        lowerDest.contains('swat') ||
        lowerDest.contains('kalam') ||
        lowerDest.contains('naran') ||
        lowerDest.contains('gilgit');

    final bool isHighAltitude = lowerDest.contains('skardu') ||
        lowerDest.contains('deosai') ||
        lowerDest.contains('babusar') ||
        lowerDest.contains('khunjerab');

    final List<Map<String, dynamic>> defaultList = [
      {
        'category': '👕 Thermal & Layered Clothing',
        'items': [
          {
            'item': isCold ? 'Thermal Inners (Top & Bottom)' : 'Breathable Cotton Shirts',
            'reason': isCold ? 'Base layer to retain core body temperature in cold air' : 'Lightweight breathable daily wear',
            'checked': false
          },
          {
            'item': isCold ? 'Heavy Fleece / Down Jacket' : 'Light Evening Windbreaker',
            'reason': isCold ? 'Essential outer warmth against sub-zero mountain winds' : 'Protection against dust and breeze',
            'checked': false
          },
          {
            'item': isCold ? 'Woolen Beanie Cap & Gloves' : 'Sun Hat / Baseball Cap',
            'reason': isCold ? '80% of heat loss occurs via head & hands' : 'Sunstroke prevention during sightseeing',
            'checked': false
          },
          {
            'item': 'Thick Hiking Socks (3+ pairs)',
            'reason': 'Prevents blisters and keeps feet warm while walking',
            'checked': false
          },
          {
            'item': 'Waterproof Windbreaker',
            'reason': 'Shields against sudden mountain squalls and rains',
            'checked': false
          },
        ]
      },
      {
        'category': '🥾 Mountain Footwear & Outdoor Gear',
        'items': [
          {
            'item': 'Sturdy Trekking Boots with Deep Lug Grip',
            'reason': 'Crucial for rocky trails, viewpoints and loose gravel',
            'checked': false
          },
          {
            'item': '20,000mAh Fast Power Bank',
            'reason': 'Northern valleys face load-shedding; cold drains phone battery fast',
            'checked': false
          },
          {
            'item': 'UV400 Polarized Sunglasses',
            'reason': 'Protects retina against sharp high-altitude UV radiation & snow glare',
            'checked': false
          },
          {
            'item': 'LED Headlamp / Pocket Torch',
            'reason': 'Handy for night walks, power outages, and trail movement',
            'checked': false
          },
          {
            'item': 'Insulated Thermal Flask / Water Bottle',
            'reason': 'Keeps boiled drinking water or warm kehwa warm for 12 hours',
            'checked': false
          },
        ]
      },
      {
        'category': '💊 Health, Altitude & First Aid Kit',
        'items': [
          if (isHighAltitude)
            {
              'item': 'Diamox (Acetazolamide) Tablets',
              'reason': 'Medically proven prevention for Acute Mountain Sickness (AMS)',
              'checked': false
            },
          {
            'item': 'ORS Electrolyte Rehydration Sachets',
            'reason': 'Prevents dehydration on long dry mountain drives and treks',
            'checked': false
          },
          {
            'item': 'Motion Sickness Tablets (Gravinate)',
            'reason': 'Vital for winding Karakoram Highway & hill climb hairpins',
            'checked': false
          },
          {
            'item': 'Paracetamol & Pain Relief Tablets',
            'reason': 'For general altitude headaches, muscle soreness, or fever',
            'checked': false
          },
          {
            'item': 'First Aid Bandages & Antiseptic Cream',
            'reason': 'Immediate treatment for trail scrapes and blisters',
            'checked': false
          },
        ]
      },
      {
        'category': '📄 Essential Documents & Emergency Cash',
        'items': [
          {
            'item': 'Original CNIC / Passport (2 Copies)',
            'reason': 'Mandatory for security checkpoints along KKH and border zones',
            'checked': false
          },
          {
            'item': 'Physical Cash in Wallet (Min PKR 15,000)',
            'reason': 'Remote ATMs in valleys frequently lose internet connection',
            'checked': false
          },
          {
            'item': 'Vehicle Registration & Original Driving License',
            'reason': 'Required for highway police and car rental checks',
            'checked': false
          },
          {
            'item': 'Offline Downloaded Google / SafarSathi Maps',
            'reason': 'Cellular internet is unavailable on several mountain stretches',
            'checked': false
          },
        ]
      },
      {
        'category': '🧴 Personal Care & Toiletries',
        'items': [
          {
            'item': 'Broad-Spectrum Sunscreen (SPF 50+)',
            'reason': 'High altitude sun causes rapid skin sunburn without sunscreen',
            'checked': false
          },
          {
            'item': 'Moisturizing Cold Cream & Lip Balm',
            'reason': 'Combats extreme dry mountain winds that crack lips and skin',
            'checked': false
          },
          {
            'item': 'Antiseptic Wet Wipes & Sanitizer',
            'reason': 'Convenient cleanliness on road trips and remote food dhabas',
            'checked': false
          },
        ]
      },
    ];

    setState(() {
      _packingList = defaultList;
    });
    _saveChecklistToStorage();
  }

  Future<void> _generateListWithAi() async {
    setState(() => _isLoading = true);
    try {
      final list = await GeminiService.generatePackingList(
        destination: _destination,
        vibe: _selectedVibe,
        duration: _duration,
        weatherConditions: _weather,
      );
      if (mounted && list.isNotEmpty) {
        setState(() => _packingList = list);
        _saveChecklistToStorage();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI customized checklist generated successfully!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Gemini packing error, fallback to curated: $e');
      _generateLocalCuratedList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to verified expert packing checklist for $_destination.'),
            backgroundColor: AppTheme.primaryPurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addNewCustomItem(int categoryIndex) {
    final itemCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Custom Item', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Item Name',
                hintText: 'e.g. DSLR Camera, Drone, Inhaler',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: 'Why it matters (optional)',
                hintText: 'e.g. For landscape photography',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final text = itemCtrl.text.trim();
              if (text.isNotEmpty && _packingList != null) {
                setState(() {
                  final cat = _packingList![categoryIndex];
                  final items = cat['items'] as List<dynamic>;
                  items.add({
                    'item': text,
                    'reason': reasonCtrl.text.trim().isNotEmpty ? reasonCtrl.text.trim() : 'Personal travel essential',
                    'checked': false,
                  });
                });
                _saveChecklistToStorage();
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add to Bag'),
          ),
        ],
      ),
    );
  }

  void _shareChecklist() {
    if (_packingList == null) return;

    int total = 0;
    int checked = 0;
    final buffer = StringBuffer();
    buffer.writeln('🎒 SafarSathi - Smart Packing Checklist for $_destination');
    buffer.writeln('⏱️ Duration: $_duration | 🌤️ Weather: $_weather');
    buffer.writeln('----------------------------------------');

    for (final cat in _packingList!) {
      buffer.writeln('\n${cat['category']}:');
      for (final item in cat['items'] as List<dynamic>) {
        total++;
        final isChecked = item['checked'] == true;
        if (isChecked) checked++;
        buffer.writeln('${isChecked ? '✅' : '⬜'} ${item['item']} - (${item['reason']})');
      }
    }

    buffer.writeln('\n----------------------------------------');
    buffer.writeln('📊 Progress: $checked / $total items packed (${((checked / (total == 0 ? 1 : total)) * 100).toInt()}%)');
    buffer.writeln('Ready for Safar with SafarSathi 🇵🇰');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Packing checklist copied! Paste directly in WhatsApp.')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _applyPreset(String destKey) {
    final preset = _destinationPresets[destKey];
    if (preset == null) return;

    setState(() {
      _destination = destKey;
      _weather = preset.$1;
      _selectedVibe = preset.$2;
      _generateLocalCuratedList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int total = 0;
    int checked = 0;
    if (_packingList != null) {
      for (final cat in _packingList!) {
        for (final item in cat['items'] as List<dynamic>) {
          total++;
          if (item['checked'] == true) checked++;
        }
      }
    }
    final double progress = total == 0 ? 0.0 : checked / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Smart Packing AI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20),
            tooltip: 'Share Packing Checklist',
            onPressed: _shareChecklist,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, size: 22),
            tooltip: 'Reset Checklist',
            onPressed: () {
              if (_packingList != null) {
                setState(() {
                  for (final cat in _packingList!) {
                    for (final item in cat['items'] as List<dynamic>) {
                      item['checked'] = false;
                    }
                  }
                });
                _saveChecklistToStorage();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Destination & Preset Header
          _buildPreferencesHeader(),

          // Progress Bar & Stats
          _buildProgressBanner(checked, total, progress),

          // Checklist Cards
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination Quick Preset Pills
          Text('DESTINATION PRESETS:', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 0.6)),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _destinationPresets.keys.map((presetName) {
                final isSelected = _destination == presetName;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(presetName.split(' & ').first),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _applyPreset(presetName);
                    },
                    selectedColor: AppTheme.primaryPurple,
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Current Trip Info Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.primaryPurple),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _destination,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('$_duration • $_weather',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateListWithAi,
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('AI Regenerate', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBanner(int checked, int total, double progress) {
    final int percent = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    progress == 1.0 ? Icons.check_circle_rounded : Icons.backpack_rounded,
                    size: 18,
                    color: progress == 1.0 ? const Color(0xFF10B981) : AppTheme.primaryPurple,
                  ),
                  const SizedBox(width: 6),
                  Text('Luggage Progress', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: progress == 1.0 ? const Color(0xFFECFDF5) : const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$checked / $total packed ($percent%)',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: progress == 1.0 ? const Color(0xFF059669) : AppTheme.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? const Color(0xFF10B981) : AppTheme.primaryPurple,
              ),
            ),
          ),
          if (progress == 1.0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '🎉 Everything is packed! Have an incredible journey across Pakistan! 🇵🇰',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF059669), fontWeight: FontWeight.bold),
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
            const Icon(Icons.backpack_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Ready to Pack?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Select a destination preset above or tap AI Regenerate to build your customized packing list.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _packingList!.length,
      itemBuilder: (context, i) {
        final categoryMap = _packingList![i];
        final category = categoryMap['category'] as String;
        final items = categoryMap['items'] as List<dynamic>;

        final int catChecked = items.where((it) => it['checked'] == true).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: ExpansionTile(
            shape: Border.all(color: Colors.transparent),
            collapsedShape: Border.all(color: Colors.transparent),
            initiallyExpanded: true,
            title: Text(
              category,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF1E293B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$catChecked/${items.length}',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 19, color: AppTheme.primaryPurple),
                  tooltip: 'Add item to $category',
                  onPressed: () => _addNewCustomItem(i),
                ),
              ],
            ),
            children: items.map((itemObj) {
              final itemInfo = itemObj as Map<String, dynamic>;
              final bool isChecked = itemInfo['checked'] ?? false;

              return CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                value: isChecked,
                onChanged: (val) {
                  setState(() {
                    itemInfo['checked'] = val;
                  });
                  _saveChecklistToStorage();
                },
                title: Text(
                  itemInfo['item'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    color: isChecked ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  itemInfo['reason'] as String,
                  style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B)),
                ),
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
