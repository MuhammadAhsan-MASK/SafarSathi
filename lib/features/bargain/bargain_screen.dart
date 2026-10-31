import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class BargainItem {
  final String name;
  final String category;
  final double minNumeric;
  final double maxNumeric;
  final String minPrice;
  final String maxPrice;
  final String tip;
  final String? urduRebuttal;

  const BargainItem({
    required this.name,
    required this.category,
    required this.minNumeric,
    required this.maxNumeric,
    required this.minPrice,
    required this.maxPrice,
    required this.tip,
    this.urduRebuttal,
  });
}

final List<BargainItem> _bargainData = [
  // Transport
  BargainItem(
    name: 'Jeep to Fairy Meadows',
    category: 'Transport',
    minNumeric: 5000,
    maxNumeric: 8000,
    minPrice: '5,000',
    maxPrice: '8,000',
    tip: 'PKR 6,000 is a fair deal. Book round-trip with the driver to negotiate down.',
    urduRebuttal: 'Bhai round-trip ka munasib rate lagayein, 6,000 theek hai.',
  ),
  BargainItem(
    name: 'Jeep Naran–Babusar Top',
    category: 'Transport',
    minNumeric: 3500,
    maxNumeric: 6000,
    minPrice: '3,500',
    maxPrice: '6,000',
    tip: 'Share with other travelers to bring the cost down per head.',
    urduRebuttal: 'Hum sharing pe jana chahte hain, munasib per-seat rate batayein.',
  ),
  BargainItem(
    name: 'Rickshaw (short city ride)',
    category: 'Transport',
    minNumeric: 100,
    maxNumeric: 300,
    minPrice: '100',
    maxPrice: '300',
    tip: 'Always agree on the fare BEFORE getting in. Meter is rarely used.',
    urduRebuttal: 'Itne qareeb ke liye 150 bohat hain bhai.',
  ),
  BargainItem(
    name: 'Intercity Bus (per seat)',
    category: 'Transport',
    minNumeric: 800,
    maxNumeric: 2500,
    minPrice: '800',
    maxPrice: '2,500',
    tip: 'Daewoo & Faisal Movers have fixed computerized rates. Avoid touts outside terminals.',
    urduRebuttal: 'Terminal counter se official ticket rate check kar lete hain.',
  ),
  BargainItem(
    name: 'Horse Ride in Nathia Gali',
    category: 'Transport',
    minNumeric: 500,
    maxNumeric: 1500,
    minPrice: '500',
    maxPrice: '1,500',
    tip: 'Agree on the full route price (e.g. to Miranjani base), not a deceptive per-minute rate.',
    urduRebuttal: 'Pura round-trip ka final batao, minute ka hisab nahi karna.',
  ),
  // Souvenirs
  BargainItem(
    name: 'Pashmina Shawl',
    category: 'Souvenir',
    minNumeric: 1500,
    maxNumeric: 4000,
    minPrice: '1,500',
    maxPrice: '4,000',
    tip: 'Genuine Kashmiri Pashmina passes through a ring. Acrylic blends sell for PKR 600–900.',
    urduRebuttal: 'Bhai yeh pure wool nahi hai, 1,800 final karein.',
  ),
  BargainItem(
    name: 'Hunza Dry Fruits (per kg)',
    category: 'Souvenir',
    minNumeric: 1200,
    maxNumeric: 2500,
    minPrice: '1,200',
    maxPrice: '2,500',
    tip: 'Walnut, apricot, and almond. Buy directly from Karimabad women cooperatives for best price.',
    urduRebuttal: 'Do kilo lene hain, wholesale discount lagao.',
  ),
  BargainItem(
    name: 'Wooden Carved Handicrafts',
    category: 'Souvenir',
    minNumeric: 500,
    maxNumeric: 3000,
    minPrice: '500',
    maxPrice: '3,000',
    tip: 'Inspect for real walnut or deodar wood vs light synthetic stained timber.',
    urduRebuttal: 'Showroom se behtar rate local market mein mil raha hai.',
  ),
  BargainItem(
    name: 'Chitrali Cap (Pakol)',
    category: 'Souvenir',
    minNumeric: 400,
    maxNumeric: 1200,
    minPrice: '400',
    maxPrice: '1,200',
    tip: 'Pure sheep wool caps feel soft and stretch comfortably. Stiff ones use cheap synthetic felt.',
    urduRebuttal: 'Bhai 600 rupay mein pakka karein.',
  ),
  BargainItem(
    name: 'Lapis Lazuli Gemstones',
    category: 'Souvenir',
    minNumeric: 300,
    maxNumeric: 2000,
    minPrice: '300',
    maxPrice: '2,000',
    tip: 'Fake dyed glass stones are common. Real lapis has flecks of golden pyrite visible.',
    urduRebuttal: 'Asal Badakhshan pathar hai toh certificate ya test dikhayein.',
  ),
  // Food
  BargainItem(
    name: 'Biryani Plate (restaurant)',
    category: 'Food',
    minNumeric: 250,
    maxNumeric: 600,
    minPrice: '250',
    maxPrice: '600',
    tip: 'Local food streets serve authentic basmati biryani with raita/salad for PKR 280–350.',
    urduRebuttal: 'Single plate standard rate pe de dein.',
  ),
  BargainItem(
    name: 'Fresh Trout Fish (Swat / Kaghan)',
    category: 'Food',
    minNumeric: 800,
    maxNumeric: 1600,
    minPrice: '800',
    maxPrice: '1,600',
    tip: 'Weigh live fish before frying. Price is per kilogram, not per tiny serving piece.',
    urduRebuttal: 'Pehle live kanta karein, per-kg rate fix karein.',
  ),
  BargainItem(
    name: 'Dhaba Doodh Patti Chai',
    category: 'Food',
    minNumeric: 40,
    maxNumeric: 120,
    minPrice: '40',
    maxPrice: '120',
    tip: 'Tourist viewpoint stalls charge 3x. Authentic local roadside dhabas charge PKR 50–70.',
    urduRebuttal: 'Bhai regular cup ka rate lagayein.',
  ),
  BargainItem(
    name: 'Peshawari Chapli Kebab (2 pcs)',
    category: 'Food',
    minNumeric: 250,
    maxNumeric: 500,
    minPrice: '250',
    maxPrice: '500',
    tip: 'Taroo Jabba and Qissa Khwani have the gold standard. Hotel menus charge double.',
    urduRebuttal: 'Weight ke hisab se tarka laga ke dein.',
  ),
  // Stay
  BargainItem(
    name: 'Camping Tent Rental (night)',
    category: 'Stay',
    minNumeric: 800,
    maxNumeric: 2000,
    minPrice: '800',
    maxPrice: '2,000',
    tip: 'Many riverside sites include mattress, sleeping bag, and campfire. Confirm what is included.',
    urduRebuttal: 'Mattress aur blankets sath include karein is rate mein.',
  ),
  BargainItem(
    name: 'Guesthouse Room (Northern Areas)',
    category: 'Stay',
    minNumeric: 2500,
    maxNumeric: 6000,
    minPrice: '2,500',
    maxPrice: '6,000',
    tip: 'During off-peak weekdays, hotels readily negotiate 30–40% off their rack rates.',
    urduRebuttal: 'Hum 2 raat ruk rahe hain, special discount rate lagayein.',
  ),
];

class BargainScreen extends StatefulWidget {
  const BargainScreen({super.key});

  @override
  State<BargainScreen> createState() => _BargainScreenState();
}

class _BargainScreenState extends State<BargainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quoteController = TextEditingController();

  String _selectedCategory = 'All';
  List<BargainItem> _filtered = _bargainData;
  BargainItem? _calculatorSelectedItem;
  Map<String, dynamic>? _analysisResult;

  final List<String> _categories = ['All', 'Transport', 'Souvenir', 'Food', 'Stay'];
  final Map<String, Color> _categoryColors = {
    'Transport': Colors.blue,
    'Souvenir': Colors.purple,
    'Food': Colors.orange,
    'Stay': Colors.teal,
  };
  final Map<String, IconData> _categoryIcons = {
    'Transport': Icons.directions_car,
    'Souvenir': Icons.card_giftcard,
    'Food': Icons.restaurant,
    'Stay': Icons.hotel,
  };

  @override
  void initState() {
    super.initState();
    _calculatorSelectedItem = _bargainData.first;
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _bargainData.where((item) {
        final matchesQuery = query.isEmpty || item.name.toLowerCase().contains(query);
        final matchesCat = _selectedCategory == 'All' || item.category == _selectedCategory;
        return matchesQuery && matchesCat;
      }).toList();
    });
  }

  void _calculateVerdict() {
    final text = _quoteController.text.replaceAll(',', '').trim();
    final quote = double.tryParse(text);

    if (quote == null || quote <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quoted price in PKR.')),
      );
      return;
    }

    final item = _calculatorSelectedItem!;
    final min = item.minNumeric;
    final max = item.maxNumeric;

    String verdict;
    Color color;
    IconData icon;
    String advice;
    String suggestedCounter;

    if (quote <= min) {
      verdict = 'Super Steal / Great Deal!';
      color = Colors.green.shade700;
      icon = Icons.verified;
      advice = 'This is at or below local wholesale rate. Accept the offer right away!';
      suggestedCounter = 'Pay the quoted PKR ${quote.toStringAsFixed(0)} gladly.';
    } else if (quote <= max) {
      verdict = 'Fair Market Price';
      color = Colors.teal.shade700;
      icon = Icons.check_circle_outline;
      advice = 'This is a fair standard tourist rate. No need for aggressive haggling.';
      suggestedCounter = 'Accept or round down to nearest 500 (e.g. PKR ${(quote * 0.9).toStringAsFixed(0)}).';
    } else if (quote <= max * 1.35) {
      final markup = (((quote - max) / max) * 100).toStringAsFixed(0);
      final counter = ((min + max) / 2).toStringAsFixed(0);
      verdict = 'A Bit High (+$markup% Markup)';
      color = Colors.amber.shade900;
      icon = Icons.warning_amber_rounded;
      advice = 'The vendor is testing the waters. Negotiate firmly with confidence.';
      suggestedCounter = 'Counter-offer: PKR $counter. Walk away if they refuse.';
    } else {
      final markup = (((quote - max) / max) * 100).toStringAsFixed(0);
      final counter = max.toStringAsFixed(0);
      verdict = 'Overpriced Tourist Markup (+$markup% Over!)';
      color = Colors.red.shade700;
      icon = Icons.gpp_bad_rounded;
      advice = 'You are being heavily overcharged. Politely decline and try another vendor.';
      suggestedCounter = 'Counter max: PKR $counter. If they say no, smile and walk away.';
    }

    setState(() {
      _analysisResult = {
        'verdict': verdict,
        'color': color,
        'icon': icon,
        'advice': advice,
        'suggestedCounter': suggestedCounter,
        'rebuttal': item.urduRebuttal ?? 'Bhai munasib rate lagayein.',
        'fairRange': 'PKR ${item.minPrice} – ${item.maxPrice}',
      };
    });
  }

  void _openCalculatorForItem(BargainItem item) {
    setState(() {
      _calculatorSelectedItem = item;
      _quoteController.text = item.maxNumeric.toStringAsFixed(0);
      _analysisResult = null;
    });
    _calculateVerdict();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Bargain & Anti-Scam Engine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP INTERACTIVE CALCULATOR ────────────────────────────
            _buildInteractiveCalculator(),

            // ── DIRECTORY SEARCH & CATEGORY CHIPS ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Benchmark Directory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse typical local costs and insider bargaining tips across Pakistan.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items, jeeps, shawls, dry fruit...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (_) => _applyFilter(),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            selectedColor: AppTheme.primaryPurple,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedCategory = cat;
                                  _applyFilter();
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ── DIRECTORY CARDS LIST ──────────────────────────────────
            _filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No items match your search.'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _buildBargainCard(_filtered[i]),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCalculator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.price_check, color: Colors.green.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quote Checker & Anti-Scam Tool',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Enter what a vendor quoted to test if you are being overcharged.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dropdown of items
          DropdownButtonFormField<BargainItem>(
            value: _calculatorSelectedItem,
            decoration: InputDecoration(
              labelText: 'Select Service or Item',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            isExpanded: true,
            items: _bargainData.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text('${item.name} (${item.category})', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _calculatorSelectedItem = val;
                  _analysisResult = null;
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // Quote input field + Analyze button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quoteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quoted Price (PKR)',
                    prefixText: 'Rs. ',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: const Text('Check'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _calculateVerdict,
              ),
            ],
          ),

          // ── VERDICT DISPLAY ─────────────────────────────────────
          if (_analysisResult != null) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_analysisResult!['color'] as Color).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _analysisResult!['color'] as Color, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_analysisResult!['icon'] as IconData, color: _analysisResult!['color'] as Color, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _analysisResult!['verdict'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _analysisResult!['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expected Fair Local Price: ${_analysisResult!['fairRange']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(_analysisResult!['advice'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Suggested Action: ${_analysisResult!['suggestedCounter']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '💬 What to say in Urdu: "${_analysisResult!['rebuttal']}"',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.purple.shade900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBargainCard(BargainItem item) {
    final color = _categoryColors[item.category] ?? AppTheme.primaryPurple;
    final icon = _categoryIcons[item.category] ?? Icons.info_outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.category, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceChip('Min (Fair Local)', 'PKR ${item.minPrice}', Colors.green.shade700),
                _buildPriceChip('Max (Acceptable)', 'PKR ${item.maxPrice}', Colors.deepOrange),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.tip, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Test Quote Action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calculate_outlined, size: 16),
                label: const Text('Test a Vendor Quote on this Item'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPurple,
                  side: const BorderSide(color: AppTheme.primaryPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => _openCalculatorForItem(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label, String price, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(price, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
