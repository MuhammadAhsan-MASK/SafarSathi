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
  final String? weather;

  const SmartPackingScreen({
    super.key,
    this.destination = 'Hunza Valley',
    this.duration = '5 Days',
    this.weather,
  });

  @override
  State<SmartPackingScreen> createState() => _SmartPackingScreenState();
}

class _SmartPackingScreenState extends State<SmartPackingScreen> {
  late String _destination;
  late String _duration;
  late String _weather;
  String _selectedVibe = 'Adventure';
  String _currentTip = '';
  bool _isLoading = false;
  List<Map<String, dynamic>>? _packingList;

  final vibes = [
    'Adventure', 'Relaxation', 'Cultural', 'Family', 'Photography',
  ];

  // Key: City Name -> (weather, vibe, climateProfile, localTip)
  // climateProfile values: 'high_altitude', 'cold', 'coastal', 'urban_heritage'
  final Map<String, (String weather, String vibe, String climate, String tip)> _destinationPresets = {
    'Hunza Valley': (
      'Cold & Chilly (5°C)',
      'Adventure',
      'high_altitude',
      'ATMs in Karimabad often go offline; keep PKR 15,000+ cash and warm layers for Eagle\'s Nest.',
    ),
    'Skardu & Deosai': (
      'Freezing & Windy (2°C)',
      'Photography',
      'high_altitude',
      'Deosai Plains exceed 4,100m; carry Diamox, UV400 goggles, and heavy windproof layers.',
    ),
    'Fairy Meadows': (
      'Sub-Zero & Alpine (0°C)',
      'Adventure',
      'high_altitude',
      'Requires a 3-hour trek from Tattu Village; pack light but sub-zero thermal gear and trekking boots.',
    ),
    'Naran & Kaghan': (
      'Alpine Cold (6°C)',
      'Adventure',
      'cold',
      'Nights near Lake Saif-ul-Mulook drop sharply; keep a fleece jacket and waterproof shoes.',
    ),
    'Swat & Kalam': (
      'Crisp Mountain Air (8°C)',
      'Adventure',
      'cold',
      'Carry river-friendly grip shoes for Mahodand Lake and warm evening layers.',
    ),
    'Murree & Galiyat': (
      'Misty & Chilly (10°C)',
      'Family',
      'cold',
      'Sudden fog & drizzle are common; pack an umbrella, anti-slip sneakers, and warm sweaters.',
    ),
    'Neelum Valley': (
      'Mountain Mist & Rain (9°C)',
      'Adventure',
      'cold',
      'Carry original CNIC for checkposts, a compact raincoat, and power bank for remote valleys.',
    ),
    'Chitral & Kalash': (
      'Cool & Mountainous (9°C)',
      'Cultural',
      'cold',
      'Respect local Kalash traditions when photographing; Lowari Tunnel drive requires motion sickness prep.',
    ),
    'Kumrat Valley': (
      'Forest Cold (7°C)',
      'Adventure',
      'cold',
      'Limited mobile signal inside Kumrat forest; download offline maps and carry torch & cash.',
    ),
    'Gilgit & Naltar': (
      'Alpine Pine Breeze (8°C)',
      'Photography',
      'cold',
      'Naltar Lakes trail is bumpy; pack motion tablets, sunglasses, and dusty-trail shoes.',
    ),
    'Quetta & Ziarat': (
      'Dry & Chilly Nights (12°C)',
      'Cultural',
      'cold',
      'Dry mountain climate cracks lips fast; keep lip balm, moisturizer, and warm nightwear.',
    ),
    'Islamabad': (
      'Pleasant Foothills (20°C)',
      'Relaxation',
      'urban_heritage',
      'Great walking city for Margalla Trails & Faisal Mosque; bring sneakers and a light evening jacket.',
    ),
    'Lahore': (
      'Warm Heritage City (26°C)',
      'Cultural',
      'urban_heritage',
      'Keep a modest shawl/dupatta for Badshahi Mosque & Walled City tours, plus antacids for food streets!',
    ),
    'Karachi': (
      'Warm & Coastal (31°C)',
      'Relaxation',
      'coastal',
      'Humid coastal breeze; pack breathable cotton, SPF 50+ sunscreen, and waterproof sandals for Clifton/French Beach.',
    ),
    'Gwadar & Makran': (
      'Sunny & Coastal (29°C)',
      'Photography',
      'coastal',
      'Strong coastal sun along Kund Malir & Hammerhead; carry UV sunglasses, ORS hydration, and SPF 50+.',
    ),
    'Multan': (
      'Hot & Dry Plains (34°C)',
      'Cultural',
      'urban_heritage',
      'Pack airy cotton clothes, a head scarf/shawl for Sufi shrines, sunscreen, and a hydration flask.',
    ),
    'Bahawalpur': (
      'Warm Desert Sun (33°C)',
      'Cultural',
      'urban_heritage',
      'Visiting Noor Mahal & Derawar Fort involves sunny walks; wear cushioned sneakers and a sun hat.',
    ),
  };

  @override
  void initState() {
    super.initState();
    _initDestinationState();
    _loadSavedChecklist();
  }

  void _initDestinationState() {
    final incomingLower = widget.destination.toLowerCase();
    String matchedKey = widget.destination;
    (String, String, String, String)? matchedPreset;

    for (final entry in _destinationPresets.entries) {
      final keyFirstWord = entry.key.split(' & ').first.toLowerCase();
      if (entry.key.toLowerCase() == incomingLower ||
          incomingLower.contains(keyFirstWord) ||
          entry.key.toLowerCase().contains(incomingLower)) {
        matchedKey = entry.key;
        matchedPreset = entry.value;
        break;
      }
    }

    _destination = matchedKey;
    _duration = widget.duration;

    if (matchedPreset != null) {
      _weather = (widget.weather != null && widget.weather!.isNotEmpty && widget.weather != 'Seasonal')
          ? widget.weather!
          : matchedPreset.$1;
      _selectedVibe = matchedPreset.$2;
      _currentTip = matchedPreset.$4;
    } else {
      final inferredClimate = _inferClimateProfile(widget.destination);
      _weather = (widget.weather != null && widget.weather!.isNotEmpty && widget.weather != 'Seasonal')
          ? widget.weather!
          : _defaultWeatherForClimate(inferredClimate);
      _currentTip = 'Pack comfortably based on $_destination\'s local weather and carry original CNIC.';
    }
  }

  String _inferClimateProfile(String dest) {
    final lower = dest.toLowerCase();
    for (final entry in _destinationPresets.entries) {
      final firstWord = entry.key.split(' & ').first.toLowerCase();
      if (lower.contains(firstWord) || entry.key.toLowerCase() == lower) {
        return entry.value.$3;
      }
    }
    if (lower.contains('skardu') ||
        lower.contains('deosai') ||
        lower.contains('hunza') ||
        lower.contains('fairy') ||
        lower.contains('khunjerab') ||
        lower.contains('babusar')) {
      return 'high_altitude';
    }
    if (lower.contains('karachi') ||
        lower.contains('gwadar') ||
        lower.contains('makran') ||
        lower.contains('kund malir') ||
        lower.contains('ormara')) {
      return 'coastal';
    }
    if (lower.contains('murree') ||
        lower.contains('swat') ||
        lower.contains('kalam') ||
        lower.contains('naran') ||
        lower.contains('kaghan') ||
        lower.contains('neelum') ||
        lower.contains('chitral') ||
        lower.contains('kumrat') ||
        lower.contains('gilgit') ||
        lower.contains('quetta') ||
        lower.contains('ziarat')) {
      return 'cold';
    }
    return 'urban_heritage';
  }

  String _defaultWeatherForClimate(String climate) {
    switch (climate) {
      case 'high_altitude':
        return 'Freezing & Windy (3°C)';
      case 'cold':
        return 'Cool Mountain Air (9°C)';
      case 'coastal':
        return 'Warm & Coastal (30°C)';
      default:
        return 'Mild & Warm (24°C)';
    }
  }

  String get _storageKey => 'safar_packing_v2_${_destination.replaceAll(' ', '_').toLowerCase()}';

  Future<void> _loadSavedChecklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved);
        if (mounted) {
          setState(() {
            _packingList = decoded.map((cat) => Map<String, dynamic>.from(cat)).toList();
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error loading saved checklist: $e');
    }

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
    final climate = _inferClimateProfile(_destination);
    List<Map<String, dynamic>> curated;

    if (climate == 'high_altitude') {
      curated = [
        {
          'category': '🧥 Sub-Zero & Thermal Layering',
          'items': [
            {
              'item': 'Thermal Inners (Top & Bottom)',
              'reason': 'Base layer to retain core body heat in freezing mountain winds',
              'checked': false,
            },
            {
              'item': 'Heavy Down / Puffer Jacket',
              'reason': 'Essential outer insulation for early mornings & high passes',
              'checked': false,
            },
            {
              'item': 'Woolen Beanie Cap & Windproof Gloves',
              'reason': 'Prevents rapid heat loss from head and fingers at high altitude',
              'checked': false,
            },
            {
              'item': 'Thick Merino / Thermal Hiking Socks (3+ pairs)',
              'reason': 'Keeps feet warm and blister-free on rocky trails',
              'checked': false,
            },
            {
              'item': 'Fleece-Lined Windproof Trousers',
              'reason': 'Blocks chilly alpine gusts at viewpoints and lakes',
              'checked': false,
            },
          ],
        },
        {
          'category': '🥾 High-Altitude Footwear & Gear',
          'items': [
            {
              'item': 'Waterproof Trekking Boots with Deep Grip',
              'reason': 'Crucial traction for loose gravel, snow patches, and treks',
              'checked': false,
            },
            {
              'item': 'UV400 Polarized Sunglasses',
              'reason': 'Shields eyes from intense high-altitude UV & snow glare',
              'checked': false,
            },
            {
              'item': '20,000mAh Fast Power Bank',
              'reason': 'Sub-zero cold drains phone batteries fast and valleys have outages',
              'checked': false,
            },
            {
              'item': 'Insulated Thermal Flask',
              'reason': 'Keeps drinking water or hot kehwa warm for hours',
              'checked': false,
            },
            {
              'item': 'LED Headlamp / Pocket Torch',
              'reason': 'Essential for camp walks and night power cuts',
              'checked': false,
            },
          ],
        },
        {
          'category': '💊 Altitude Health & First Aid',
          'items': [
            {
              'item': 'Diamox (Acetazolamide) Tablets',
              'reason': 'Prevents Acute Mountain Sickness (AMS) above 3,500m',
              'checked': false,
            },
            {
              'item': 'Motion Sickness Tablets (Gravinate)',
              'reason': 'Vital for winding Karakoram Highway & mountain hairpins',
              'checked': false,
            },
            {
              'item': 'ORS Electrolyte Sachets',
              'reason': 'Maintains hydration in dry, high-altitude mountain air',
              'checked': false,
            },
            {
              'item': 'Paracetamol / Pain Relief & Bandages',
              'reason': 'Handles altitude headaches, soreness, and trail scrapes',
              'checked': false,
            },
          ],
        },
        {
          'category': '📄 Mountain Checkpoint Docs & Cash',
          'items': [
            {
              'item': 'Original CNIC / Passport (2 Photocopies)',
              'reason': 'Mandatory for security checkposts along KKH & northern borders',
              'checked': false,
            },
            {
              'item': 'Physical Cash (Min PKR 15,000+)',
              'reason': 'Remote valley ATMs frequently go offline or run out of cash',
              'checked': false,
            },
            {
              'item': 'Offline Downloaded Google Maps',
              'reason': 'Mobile data drops completely in many northern canyons',
              'checked': false,
            },
          ],
        },
        {
          'category': '🧴 Alpine Skincare',
          'items': [
            {
              'item': 'Sunscreen (SPF 50+) & Lip Balm',
              'reason': 'Prevents windburn and sunburn in thin mountain atmosphere',
              'checked': false,
            },
            {
              'item': 'Heavy Cold Cream / Moisturizer',
              'reason': 'Protects skin from severe drying mountain winds',
              'checked': false,
            },
            {
              'item': 'Antiseptic Wet Wipes & Hand Sanitizer',
              'reason': 'Quick hygiene on long jeep safaris and stops',
              'checked': false,
            },
          ],
        },
      ];
    } else if (climate == 'cold') {
      curated = [
        {
          'category': '🧥 Warm Layered Clothing',
          'items': [
            {
              'item': 'Warm Fleece Jacket or Wool Sweater',
              'reason': 'Comfortable warmth for crisp valley evenings and mornings',
              'checked': false,
            },
            {
              'item': 'Long-Sleeve Cotton T-Shirts (Layering)',
              'reason': 'Easy to adjust as daytime sun turns into cool breeze',
              'checked': false,
            },
            {
              'item': 'Rain & Windproof Hooded Jacket',
              'reason': 'Protects against sudden hill drizzle and mountain mist',
              'checked': false,
            },
            {
              'item': 'Comfortable Jeans or Cargo Trousers',
              'reason': 'Durable and warm for outdoor walks and sightseeing',
              'checked': false,
            },
            {
              'item': 'Warm Cotton / Wool Socks (3+ pairs)',
              'reason': 'Keeps feet cozy during walks and chilly hotel nights',
              'checked': false,
            },
          ],
        },
        {
          'category': '🥾 Valley Footwear & Gear',
          'items': [
            {
              'item': 'Anti-Slip Walking / Trail Sneakers',
              'reason': 'Safe grip on damp hill paths, mall roads, and forest trails',
              'checked': false,
            },
            {
              'item': 'Compact Folding Umbrella / Rain Poncho',
              'reason': 'Essential for unpredictable showers in hill stations & valleys',
              'checked': false,
            },
            {
              'item': '10,000mAh+ Power Bank & Charging Cable',
              'reason': 'Keeps phone charged through scenic drives and photography',
              'checked': false,
            },
            {
              'item': 'Lightweight Daypack Backpack',
              'reason': 'Conveniently carries water, snacks, and extra layers on day trips',
              'checked': false,
            },
          ],
        },
        {
          'category': '💊 Hill Road Health & First Aid',
          'items': [
            {
              'item': 'Motion Sickness Tablets (Gravinate)',
              'reason': 'Helps on winding hill climbs and sharp valley turns',
              'checked': false,
            },
            {
              'item': 'Paracetamol & Adhesive Bandages',
              'reason': 'Quick relief for travel fatigue or minor shoe blisters',
              'checked': false,
            },
            {
              'item': 'Reusable Water Bottle',
              'reason': 'Stay hydrated during outdoor hikes and chairlift visits',
              'checked': false,
            },
          ],
        },
        {
          'category': '📄 Travel Docs & Essentials',
          'items': [
            {
              'item': 'Original CNIC & Driving License',
              'reason': 'Required for hotel check-ins and highway checkpoints',
              'checked': false,
            },
            {
              'item': 'Cash for Tolls, Jeeps & Chairlifts',
              'reason': 'Local transport operators and stalls rarely accept cards',
              'checked': false,
            },
            {
              'item': 'Offline Maps & Hotel Confirmations',
              'reason': 'Smooth navigation even where 4G signals fluctuate',
              'checked': false,
            },
          ],
        },
        {
          'category': '🧴 Personal Care',
          'items': [
            {
              'item': 'Lip Balm & Skin Moisturizer',
              'reason': 'Keeps skin comfortable in cool mountain air',
              'checked': false,
            },
            {
              'item': 'Sunscreen (SPF 30+) & Sunglasses',
              'reason': 'Protects skin & eyes on sunny hilltop viewpoints',
              'checked': false,
            },
            {
              'item': 'Pocket Tissues & Hand Sanitizer',
              'reason': 'Handy for roadside chai stops and scenic picnics',
              'checked': false,
            },
          ],
        },
      ];
    } else if (climate == 'coastal') {
      curated = [
        {
          'category': '👕 Light & Breezy Coastal Wear',
          'items': [
            {
              'item': 'Breathable Cotton T-Shirts / Linen Kurtas',
              'reason': 'Lightweight fabric stays cool in warm, humid sea air',
              'checked': false,
            },
            {
              'item': 'Airy Cotton Trousers / Beach Shorts',
              'reason': 'Comfortable movement along beaches and waterfront promos',
              'checked': false,
            },
            {
              'item': 'Wide-Brim Sun Hat or Baseball Cap',
              'reason': 'Blocks direct midday sun glare on coastal drives',
              'checked': false,
            },
            {
              'item': 'Extra Swimwear / Change of Clothes',
              'reason': 'Essential if visiting beaches like Clifton, Hawksbay, or Kund Malir',
              'checked': false,
            },
          ],
        },
        {
          'category': '🩴 Beach Footwear & Sun Gear',
          'items': [
            {
              'item': 'Waterproof Beach Sandals / Slides',
              'reason': 'Easy to rinse sand off after shoreline walks',
              'checked': false,
            },
            {
              'item': 'Comfortable Breathable Sneakers',
              'reason': 'For city tours, malls, and evening boardwalks',
              'checked': false,
            },
            {
              'item': 'UV400 Polarized Sunglasses',
              'reason': 'Cuts harsh sunlight reflection off the sea and sand',
              'checked': false,
            },
            {
              'item': 'Quick-Dry Microfiber Towel & Phone Pouch',
              'reason': 'Protects your phone from salt water splashes and sand',
              'checked': false,
            },
            {
              'item': '10,000mAh Power Bank',
              'reason': 'Keeps maps and camera ready during full-day coastal trips',
              'checked': false,
            },
          ],
        },
        {
          'category': '💊 Sun Care & Hydration',
          'items': [
            {
              'item': 'Water-Resistant Sunscreen (SPF 50+)',
              'reason': 'Crucial protection against strong tropical/coastal UV rays',
              'checked': false,
            },
            {
              'item': 'ORS Electrolytes & Hydration Sachets',
              'reason': 'Replenishes salts lost quickly in warm humid weather',
              'checked': false,
            },
            {
              'item': 'Mosquito / Insect Repellent Spray',
              'reason': 'Useful for outdoor beach dinners and coastal evenings',
              'checked': false,
            },
            {
              'item': 'Aloe Vera / Soothing After-Sun Gel',
              'reason': 'Calms skin after sunny afternoon outings',
              'checked': false,
            },
          ],
        },
        {
          'category': '📄 ID & Smart Payments',
          'items': [
            {
              'item': 'Original CNIC & Driving License',
              'reason': 'Needed for hotels, beach entry passes, and coastal checkposts',
              'checked': false,
            },
            {
              'item': 'Debit Card + Cash for Boats & Food Stalls',
              'reason': 'Cards work in city malls while cash is handy at beach huts',
              'checked': false,
            },
          ],
        },
        {
          'category': '🧴 Freshness & Hygiene',
          'items': [
            {
              'item': 'Cooling Wet Wipes & Face Mist',
              'reason': 'Instant refresh after warm afternoon sightseeing',
              'checked': false,
            },
            {
              'item': 'Deodorant & Hand Sanitizer',
              'reason': 'Stay fresh through coastal humidity and street dining',
              'checked': false,
            },
          ],
        },
      ];
    } else {
      // 'urban_heritage' (Lahore, Islamabad, Multan, Bahawalpur, Peshawar, etc.)
      curated = [
        {
          'category': '👕 City & Heritage Attire',
          'items': [
            {
              'item': 'Lightweight Cotton / Lawn Shirts & Kurtas',
              'reason': 'Breathable comfort for walking forts, gardens, and bazaars',
              'checked': false,
            },
            {
              'item': 'Modest Shawl / Dupatta / Scarf',
              'reason': 'Required head/shoulder cover when entering mosques & Sufi shrines',
              'checked': false,
            },
            {
              'item': 'Comfortable Trousers / Jeans',
              'reason': 'Ideal for day-long heritage tours and evening dining',
              'checked': false,
            },
            {
              'item': 'Light Cardigan or Overshirt',
              'reason': 'Handy for cool evenings or chilly AC buses & restaurants',
              'checked': false,
            },
            {
              'item': 'Clean Cotton Socks (Extra Pairs)',
              'reason': 'Comfortable walking over warm marble courtyards at mosques/shrines',
              'checked': false,
            },
          ],
        },
        {
          'category': '👟 City Walking & Sightseeing Gear',
          'items': [
            {
              'item': 'Easy Slip-On Cushioned Walking Sneakers',
              'reason': 'Great arch support for forts and quick to remove at mosques',
              'checked': false,
            },
            {
              'item': 'Crossbody / Anti-Theft Day Bag',
              'reason': 'Keeps phone and wallet secure in bustling historical bazaars',
              'checked': false,
            },
            {
              'item': 'Insulated Reusable Water Bottle',
              'reason': 'Keeps water cool during afternoon palace and fort tours',
              'checked': false,
            },
            {
              'item': 'Sunglasses & Compact Sun Umbrella',
              'reason': 'Welcome shade in open fort courtyards and heritage plazas',
              'checked': false,
            },
            {
              'item': '10,000mAh Power Bank',
              'reason': 'Essential for photos, ride-hailing apps, and food spot navigation',
              'checked': false,
            },
          ],
        },
        {
          'category': '💊 Foodie & Urban Wellness',
          'items': [
            {
              'item': 'Digestive / Antacid Tablets (e.g. ENO / Risek)',
              'reason': 'Helpful when enjoying rich street food, karahi, and nihari',
              'checked': false,
            },
            {
              'item': 'ORS Electrolytes & Paracetamol',
              'reason': 'Combats afternoon sun fatigue during full-day city tours',
              'checked': false,
            },
            {
              'item': 'Adhesive Bandages',
              'reason': 'Handy if walking long heritage stretches',
              'checked': false,
            },
          ],
        },
        {
          'category': '📄 City ID, Cards & Tickets',
          'items': [
            {
              'item': 'Original CNIC',
              'reason': 'Mandatory for hotel check-ins and museum/fort entry',
              'checked': false,
            },
            {
              'item': 'Debit Card + Small Currency Notes (PKR 50/100)',
              'reason': 'Small notes make rickshaw rides, tips, and bazaar snacks easy',
              'checked': false,
            },
            {
              'item': 'Saved Hotel & Attraction Booking Details',
              'reason': 'Speeds up entry at popular heritage spots and restaurants',
              'checked': false,
            },
          ],
        },
        {
          'category': '🧴 Daily Personal Care',
          'items': [
            {
              'item': 'Sunscreen (SPF 50+)',
              'reason': 'Protects skin during sunny outdoor walks and rooftop dinners',
              'checked': false,
            },
            {
              'item': 'Hand Sanitizer & Antiseptic Wet Wipes',
              'reason': 'Must-have before and after street food tasting!',
              'checked': false,
            },
            {
              'item': 'Deodorant & Pocket Tissues',
              'reason': 'Keeps you feeling fresh all day',
              'checked': false,
            },
          ],
        },
      ];
    }

    setState(() {
      _packingList = curated;
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
            content: Text('Loaded expert packing checklist for $_destination.'),
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
      _currentTip = preset.$4;
    });
    _loadSavedChecklist();
  }

  void _showAllCitiesPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Pakistani City / Destination', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _destinationPresets.length,
                itemBuilder: (_, idx) {
                  final key = _destinationPresets.keys.elementAt(idx);
                  final info = _destinationPresets[key]!;
                  final isSelected = _destination == key;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? AppTheme.primaryPurple : const Color(0xFFF1F5F9),
                      child: Icon(Icons.location_on_rounded, color: isSelected ? Colors.white : AppTheme.primaryPurple, size: 18),
                    ),
                    title: Text(key, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: Text(info.$1, style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey[600])),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryPurple) : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _applyPreset(key);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.luggage_rounded, size: 21),
            const SizedBox(width: 8),
            Flexible(
              child: Text('Smart Packing AI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
            ),
          ],
        ),
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
            tooltip: 'Reset Checked Items',
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
          _buildPreferencesHeader(),
          _buildProgressBanner(checked, total, progress),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'CITIES & DESTINATIONS (${_destinationPresets.length}):',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              InkWell(
                onTap: _showAllCitiesPicker,
                child: Text(
                  'View All Cities →',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
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

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _showAllCitiesPicker,
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
                            Text(
                              '$_duration • $_weather',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                if (_currentTip.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates_rounded, size: 14, color: AppTheme.primaryPurple),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _currentTip,
                            style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      progress == 1.0 ? Icons.check_circle_rounded : Icons.luggage_rounded,
                      size: 18,
                      color: progress == 1.0 ? const Color(0xFF10B981) : AppTheme.primaryPurple,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Luggage Progress',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
            const Icon(Icons.luggage_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Ready to Pack?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Select a city above or tap AI Regenerate to build your customized packing list.',
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
