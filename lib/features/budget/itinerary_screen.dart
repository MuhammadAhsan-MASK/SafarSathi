import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/currency_provider.dart';
import '../../core/pdf_service.dart';
import '../../core/theme.dart';
import 'smart_packing_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int travelers;

  const ItineraryScreen({
    super.key,
    this.origin = 'Karachi',
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.budget = 50000,
    this.travelers = 1,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDay = 0;
  bool _isSaved = false;
  late double _totalTripBudget;
  late int _dayCount;
  late Map<int, double> _dayBudgets;

  @override
  void initState() {
    super.initState();
    _totalTripBudget = widget.budget > 0 ? widget.budget : 50000;
    final diff = widget.endDate.difference(widget.startDate).inDays.abs() + 1;
    _dayCount = diff > 0 ? diff : 1;

    // Initialize each day with an equal share of the total budget
    _dayBudgets = {};
    final defaultPerDay = _totalTripBudget / _dayCount;
    for (int i = 0; i < _dayCount; i++) {
      _dayBudgets[i] = defaultPerDay;
    }
  }

  // ── Wallet Math ─────────────────────────────────────────────────────────────
  /// Returns the sum of budgets allocated to previous days (< currentDayIndex)
  double _getSpentEarlier(int currentDayIndex) {
    double sum = 0;
    for (int i = 0; i < currentDayIndex; i++) {
      sum += _dayBudgets[i] ?? 0;
    }
    return sum;
  }

  /// Returns remaining wallet for current day and all subsequent days
  double _getRemainingWallet(int currentDayIndex) {
    final spentEarlier = _getSpentEarlier(currentDayIndex);
    final remaining = _totalTripBudget - spentEarlier;
    return remaining > 0 ? remaining : 0;
  }

  /// Returns remaining wallet strictly for days AFTER the current day
  double _getRemainingWalletForFutureDays(int currentDayIndex) {
    double spentThroughCurrent = 0;
    for (int i = 0; i <= currentDayIndex; i++) {
      spentThroughCurrent += _dayBudgets[i] ?? 0;
    }
    final remaining = _totalTripBudget - spentThroughCurrent;
    return remaining > 0 ? remaining : 0;
  }

  void _setDayBudget(int dayIndex, double newAmount) {
    final remainingWallet = _getRemainingWallet(dayIndex);
    if (newAmount > remainingWallet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot exceed remaining trip wallet of ${Provider.of<CurrencyProvider>(context, listen: false).formatPrice(remainingWallet)}!',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _dayBudgets[dayIndex] = newAmount;

      // Rebalance future days if any exist
      final futureDaysCount = _dayCount - (dayIndex + 1);
      if (futureDaysCount > 0) {
        final remainingForFuture = _totalTripBudget - _getSpentEarlier(dayIndex + 1);
        final safeShare = remainingForFuture > 0 ? remainingForFuture / futureDaysCount : 0.0;
        for (int i = dayIndex + 1; i < _dayCount; i++) {
          _dayBudgets[i] = safeShare;
        }
      }
    });
  }

  void _showSetDayBudgetDialog(int dayIndex) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final currentDayBudget = _dayBudgets[dayIndex] ?? (_totalTripBudget / _dayCount);
    final maxAvailable = _getRemainingWallet(dayIndex);
    final controller = TextEditingController(text: currentDayBudget.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppTheme.primaryPurple),
                  const SizedBox(width: 8),
                  Text('Set Day ${dayIndex + 1} Budget', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Total: ${currency.formatPrice(_totalTripBudget)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Available for Day ${dayIndex + 1} & remaining days: ${currency.formatPrice(maxAvailable)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Day ${dayIndex + 1} Spending Limit',
                        prefixText: 'PKR ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        helperText: 'Max available: ${currency.formatPrice(maxAvailable)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Quick Allocation Presets:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('25%'),
                          onPressed: () {
                            final val = (maxAvailable * 0.25).clamp(1000, maxAvailable);
                            controller.text = val.toStringAsFixed(0);
                            setDialogState(() {});
                          },
                        ),
                        ActionChip(
                          label: const Text('50%'),
                          onPressed: () {
                            final val = (maxAvailable * 0.50).clamp(1000, maxAvailable);
                            controller.text = val.toStringAsFixed(0);
                            setDialogState(() {});
                          },
                        ),
                        ActionChip(
                          label: const Text('Equal Split'),
                          onPressed: () {
                            final futureDaysCount = _dayCount - dayIndex;
                            final val = maxAvailable / (futureDaysCount > 0 ? futureDaysCount : 1);
                            controller.text = val.toStringAsFixed(0);
                            setDialogState(() {});
                          },
                        ),
                        ActionChip(
                          label: const Text('Max Available'),
                          onPressed: () {
                            controller.text = maxAvailable.toStringAsFixed(0);
                            setDialogState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final entered = double.tryParse(controller.text.replaceAll(RegExp(r'[^0-9.]'), ''));
                    if (entered == null || entered <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount.')),
                      );
                      return;
                    }
                    if (entered > maxAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cannot allocate more than ${currency.formatPrice(maxAvailable)}')),
                      );
                      return;
                    }
                    _setDayBudget(dayIndex, entered);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Budget'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openMap(String query) async {
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  // ── Genuine Activity Data Generator Based on City & Budget ──────────────────
  List<Map<String, dynamic>> _getCuratedActivitiesForDay(int dayIndex, double dayBudget) {
    final dest = widget.destination.trim();
    final dLower = dest.toLowerCase();
    final orig = widget.origin.isNotEmpty && widget.origin != 'Origin' ? widget.origin : 'Karachi';

    // Tier 1: Budget (< 3,500), Tier 2: Moderate (3,500 - 10,000), Tier 3: Luxury (> 10,000)
    final isBudget = dayBudget < 3500;
    final isLuxury = dayBudget >= 10000;

    if (dLower.contains('islamabad') || dLower.contains('isb') || dLower.contains('rawalpindi')) {
      if (dayIndex == 0) {
        return [
          {
            'period': 'Morning',
            'time': '09:00 AM',
            'title': 'Arrival & Faisal Mosque Serenity',
            'place': 'Faisal Mosque, Shah Faisal Ave, Islamabad',
            'desc': 'Arrive from $orig and head to Faisal Mosque, the iconic landmark of Islamabad nestled at the foothills of Margalla.',
            'cost': isBudget ? 0.0 : (isLuxury ? 1000.0 : 300.0),
            'tag': 'Heritage & Spiritual',
            'icon': Icons.mosque,
            'color': Colors.blue,
            'mapQuery': 'Faisal Mosque Islamabad',
          },
          {
            'period': 'Afternoon',
            'time': '01:30 PM',
            'title': isBudget ? 'Savour Foods Pulao & Daman-e-Koh' : (isLuxury ? 'Monal Restaurant Panoramic Buffet' : 'Saidpur Village Des Pardes Lunch'),
            'place': isBudget ? 'Savour Foods, Blue Area, Islamabad' : (isLuxury ? 'Monal, Pir Sohawa Road, Islamabad' : 'Des Pardes, Saidpur Village, Islamabad'),
            'desc': isBudget
                ? 'Indulge in Islamabad famous traditional chicken pulao with shami kabab, followed by a breezy viewpoint visit to Daman-e-Koh.'
                : (isLuxury
                    ? 'Drive up Margalla ridge to Monal Restaurant for a luxurious buffet feast with 360-degree views overlooking the entire federal capital.'
                    : 'Explore the historic 500-year-old Saidpur village and enjoy a clay-pot handi lunch at Des Pardes with Margalla views.'),
            'cost': isBudget ? 600.0 : (isLuxury ? 4500.0 : 2200.0),
            'tag': 'Authentic Dining',
            'icon': Icons.restaurant,
            'color': Colors.deepOrange,
            'mapQuery': isBudget ? 'Savour Foods Blue Area Islamabad' : (isLuxury ? 'Monal Restaurant Islamabad' : 'Des Pardes Saidpur Village Islamabad'),
          },
          {
            'period': 'Evening',
            'time': '07:00 PM',
            'title': isBudget ? 'Rawal Lake Sunset Promenade' : (isLuxury ? 'Islamabad Serena Dawat Dinner' : 'Centaurus Mall & F-7 Jinnah Super'),
            'place': isBudget ? 'Lake View Park, Rawal Lake, Islamabad' : (isLuxury ? 'Serena Hotel, Khayaban-e-Suhrawardy, Islamabad' : 'F-7 Markaz Jinnah Super, Islamabad'),
            'desc': isBudget
                ? 'Walk along Rawal Lake promenade at dusk, enjoy fresh roasted corn on the cob, and take in the cool evening breeze.'
                : (isLuxury
                    ? 'Fine dining at Serena Hotel Dawat Restaurant featuring live sitar music, gourmet Pakistani cuisine, and royal hospitality.'
                    : 'Stroll around Jinnah Super Market, browse handicrafts, and sip Kashmiri chai or specialty coffee at Street 1 Cafe.'),
            'cost': isBudget ? 200.0 : (isLuxury ? 6000.0 : 2500.0),
            'tag': 'Evening Leisure',
            'icon': Icons.wb_twilight,
            'color': Colors.purple,
            'mapQuery': isBudget ? 'Lake View Park Islamabad' : (isLuxury ? 'Islamabad Serena Hotel' : 'Jinnah Super Market F-7 Islamabad'),
          },
        ];
      } else if (dayIndex == 1) {
        return [
          {
            'period': 'Morning',
            'time': '08:30 AM',
            'title': 'Pakistan Monument & Lok Virsa Museum',
            'place': 'Shakarparian Hills, Islamabad',
            'desc': 'Discover Pakistan four provinces culture at Lok Virsa Folk Heritage Museum and marvel at the petal architecture of Pakistan Monument.',
            'cost': isBudget ? 150.0 : (isLuxury ? 2500.0 : 800.0),
            'tag': 'Culture & History',
            'icon': Icons.museum_outlined,
            'color': Colors.brown,
            'mapQuery': 'Pakistan Monument Shakarparian Islamabad',
          },
          {
            'period': 'Afternoon',
            'time': '01:00 PM',
            'title': isBudget ? 'Melody Food Market & Rose Garden' : (isLuxury ? 'La Montana Mountain Terrace Lunch' : 'Howdy F-7 Charcoal Burgers & Fries'),
            'place': isBudget ? 'Melody Food Street, G-6, Islamabad' : (isLuxury ? 'La Montana, Margalla Hills, Islamabad' : 'Howdy, F-7 Markaz, Islamabad'),
            'desc': isBudget
                ? 'Taste authentic seekh kababs at Melody Food Park and stroll through the blooming Rose & Jasmine Garden.'
                : (isLuxury
                    ? 'Mountain ridge dining at La Montana with steaks and grilled platters overlooking the pine trees.'
                    : 'Western casual gourmet lunch in F-7 followed by shopping for artisan souvenirs.'),
            'cost': isBudget ? 750.0 : (isLuxury ? 4000.0 : 1800.0),
            'tag': 'Gastronomy',
            'icon': Icons.fastfood_outlined,
            'color': Colors.amber.shade800,
            'mapQuery': isBudget ? 'Melody Food Street G-6 Islamabad' : (isLuxury ? 'La Montana Margalla Hills Islamabad' : 'Howdy F-7 Islamabad'),
          },
          {
            'period': 'Evening',
            'time': '06:30 PM',
            'title': 'Margalla Ridge Sunset & Stargazing',
            'place': 'Pir Sohawa Viewpoint, Margalla Ridge, Islamabad',
            'desc': 'Watch the golden sunset over the Margalla Hills. Enjoy hot karak chai as the city lights up like a sea of diamonds.',
            'cost': isBudget ? 300.0 : (isLuxury ? 3500.0 : 1200.0),
            'tag': 'Scenic Sunset',
            'icon': Icons.nightlight_outlined,
            'color': Colors.indigo,
            'mapQuery': 'Pir Sohawa Viewpoint Islamabad',
          },
        ];
      } else {
        return [
          {
            'period': 'Morning',
            'time': '09:00 AM',
            'title': 'Margalla Hills Trail 3 or Trail 5 Hike',
            'place': 'Trail 3 Margalla Hills, E-7, Islamabad',
            'desc': 'Crisp morning hike through scenic green trails with wild bird song, reaching the scenic mid-ridge rest stop.',
            'cost': 0.0,
            'tag': 'Adventure & Nature',
            'icon': Icons.hiking,
            'color': Colors.green,
            'mapQuery': 'Trail 3 Margalla Hills Islamabad',
          },
          {
            'period': 'Afternoon',
            'time': '01:30 PM',
            'title': 'Golra Sharif Heritage Railway Museum',
            'place': 'Golra Sharif Railway Station, Islamabad',
            'desc': 'Step back to the 1880s colonial railway era, exploring steam locomotives, royal saloons, and historical instruments.',
            'cost': isBudget ? 100.0 : (isLuxury ? 2000.0 : 600.0),
            'tag': 'Historic Excursion',
            'icon': Icons.train,
            'color': Colors.teal,
            'mapQuery': 'Golra Sharif Railway Museum Islamabad',
          },
          {
            'period': 'Evening',
            'time': '07:30 PM',
            'title': isBudget ? 'Karachi Company G-9 Street Feast' : (isLuxury ? 'Marriott Jason Steakhouse Farewell' : 'Kabul Restaurant Afghani Tikka'),
            'place': isBudget ? 'G-9 Markaz Karachi Company, Islamabad' : (isLuxury ? 'Islamabad Marriott Hotel' : 'Kabul Restaurant, F-7 Markaz, Islamabad'),
            'desc': isBudget
                ? 'Sample traditional chapli kababs and hot roghni naan at vibrant Karachi Company food stalls.'
                : (isLuxury
                    ? 'A lavish farewell dinner at Islamabad Marriott featuring prime aged cuts and live piano entertainment.'
                    : 'Feast on succulent Afghani mutton boti, dambukht, and fresh green kahwah at Kabul Restaurant.'),
            'cost': isBudget ? 700.0 : (isLuxury ? 6500.0 : 2500.0),
            'tag': 'Farewell Feast',
            'icon': Icons.dinner_dining,
            'color': Colors.redAccent,
            'mapQuery': isBudget ? 'Karachi Company G-9 Islamabad' : (isLuxury ? 'Islamabad Marriott Hotel' : 'Kabul Restaurant F-7 Islamabad'),
          },
        ];
      }
    }

    // Karachi City Curated Itinerary
    if (dLower.contains('karachi') || dLower.contains('khi')) {
      if (dayIndex == 0) {
        return [
          {
            'period': 'Morning',
            'time': '09:00 AM',
            'title': 'Mazar-e-Quaid Homage & Gardens',
            'place': 'M.A Jinnah Road, Karachi',
            'desc': 'Visit the serene white marble mausoleum of Quaid-e-Azam Muhammad Ali Jinnah and witness the guard changing ceremony.',
            'cost': 50.0,
            'tag': 'National Heritage',
            'icon': Icons.account_balance,
            'color': Colors.green,
            'mapQuery': 'Mazar e Quaid Karachi',
          },
          {
            'period': 'Afternoon',
            'time': '01:30 PM',
            'title': isBudget ? 'Burns Road Legendary Waheed Kabab' : (isLuxury ? 'Kolachi Do Darya Oceanfront Seafood' : 'Student Biryani Saddar Authentic Lunch'),
            'place': isBudget ? 'Burns Road Food Street, Karachi' : (isLuxury ? 'Kolachi, Phase 8 Do Darya, Karachi' : 'Student Biryani, Saddar, Karachi'),
            'desc': isBudget
                ? 'Melt-in-mouth fry kabab and dhaga kabab at Karachi original culinary heart, Burns Road.'
                : (isLuxury
                    ? 'Dine directly above the crashing Arabian Sea waves with grilled red snapper and Peshawari karahi.'
                    : 'Classic Karachi beef/chicken biryani with raita, followed by fresh rabri.'),
            'cost': isBudget ? 600.0 : (isLuxury ? 4500.0 : 1800.0),
            'tag': 'Iconic Food',
            'icon': Icons.restaurant,
            'color': Colors.deepOrange,
            'mapQuery': isBudget ? 'Waheed Kabab Burns Road Karachi' : (isLuxury ? 'Kolachi Do Darya Karachi' : 'Student Biryani Saddar Karachi'),
          },
          {
            'period': 'Evening',
            'time': '06:30 PM',
            'title': isBudget ? 'Clifton Sea View Camel Ride & Sunset' : (isLuxury ? 'Port Grand Private Harbor Cruise' : 'Port Grand Boardwalk Walk & Street Food'),
            'place': 'Sea View Clifton / Port Grand, Karachi',
            'desc': 'Feel the Arabian Sea breeze, watch the sun sink into the ocean, and enjoy spiced corn and beachside camel rides.',
            'cost': isBudget ? 400.0 : (isLuxury ? 5000.0 : 1500.0),
            'tag': 'Coastal Sunset',
            'icon': Icons.waves,
            'color': Colors.blue,
            'mapQuery': 'Sea View Clifton Karachi',
          },
        ];
      }
    }

    // Lahore City Curated Itinerary
    if (dLower.contains('lahore') || dLower.contains('lhr')) {
      if (dayIndex == 0) {
        return [
          {
            'period': 'Morning',
            'time': '09:00 AM',
            'title': 'Badshahi Mosque & Shahi Qila Tour',
            'place': 'Walled City, Lahore',
            'desc': 'Walk through the grand red sandstone Badshahi Mosque and the Sheesh Mahal (Palace of Mirrors) inside Lahore Fort.',
            'cost': isBudget ? 100.0 : (isLuxury ? 2500.0 : 600.0),
            'tag': 'Mughal Heritage',
            'icon': Icons.fort_outlined,
            'color': Colors.brown,
            'mapQuery': 'Badshahi Mosque Lahore',
          },
          {
            'period': 'Afternoon',
            'time': '01:30 PM',
            'title': isBudget ? 'Anarkali Bazaar Chaat & Street Food' : (isLuxury ? 'Haveli Rooftop Fort Road Feast' : 'Waris Nihari / Phaddi Paye Lunch'),
            'place': isBudget ? 'Anarkali Bazaar, Lahore' : (isLuxury ? 'Haveli Restaurant, Fort Road, Lahore' : 'Abkari Road, New Anarkali, Lahore'),
            'desc': isBudget
                ? 'Sample spicy dahi bhallay, fruit chaat, and kulfi while browsing traditional juttis in historic Anarkali.'
                : (isLuxury
                    ? 'Breathtaking rooftop dining directly facing Badshahi Mosque illuminated at golden hour.'
                    : 'Rich, slow-cooked beef nihari with ginger, chilies, and hot tandoori naan.'),
            'cost': isBudget ? 500.0 : (isLuxury ? 4200.0 : 1600.0),
            'tag': 'Royal Dining',
            'icon': Icons.restaurant,
            'color': Colors.deepOrange,
            'mapQuery': isBudget ? 'Anarkali Bazaar Lahore' : (isLuxury ? 'Haveli Restaurant Fort Road Lahore' : 'Waris Nihari Lahore'),
          },
          {
            'period': 'Evening',
            'time': '07:00 PM',
            'title': 'Greater Iqbal Park & Dancing Fountains',
            'place': 'Minar-e-Pakistan, Greater Iqbal Park, Lahore',
            'desc': 'Stroll through the lit gardens of Greater Iqbal Park, see Minar-e-Pakistan illuminated, and enjoy fresh malai lassi.',
            'cost': isBudget ? 200.0 : (isLuxury ? 3000.0 : 1000.0),
            'tag': 'Heritage Night',
            'icon': Icons.wb_twilight,
            'color': Colors.purple,
            'mapQuery': 'Greater Iqbal Park Lahore',
          },
        ];
      }
    }

    // Default Fallback Generator for all other cities (Hunza, Skardu, Swat, Murree, Peshawar, Quetta, Multan)
    final dayNumber = dayIndex + 1;
    return [
      {
        'period': 'Morning',
        'time': '09:00 AM',
        'title': 'Day $dayNumber Landmark & Heritage Sight',
        'place': '$dest Cultural Center',
        'desc': 'Discover the premier scenic and historical wonders of $dest on Day $dayNumber.',
        'cost': isBudget ? 200.0 : (isLuxury ? 2500.0 : 800.0),
        'tag': 'Sightseeing',
        'icon': Icons.explore_outlined,
        'color': Colors.blue,
        'mapQuery': '$dest Attractions Pakistan',
      },
      {
        'period': 'Afternoon',
        'time': '01:30 PM',
        'title': isBudget ? 'Local Bazaar Food Trail' : (isLuxury ? 'Premium Scenic Dining' : 'Traditional Restaurant Lunch'),
        'place': '$dest City Center',
        'desc': 'Enjoy the rich regional culinary flavors of $dest matching your selected Day $dayNumber budget.',
        'cost': isBudget ? 600.0 : (isLuxury ? 4000.0 : 1800.0),
        'tag': 'Gastronomy',
        'icon': Icons.restaurant,
        'color': Colors.deepOrange,
        'mapQuery': '$dest Restaurants Pakistan',
      },
      {
        'period': 'Evening',
        'time': '07:00 PM',
        'title': 'Sunset Viewpoint & Night Promenade',
        'place': '$dest Overlook',
        'desc': 'Watch the dusk settle over $dest, browse local handicrafts, and relax after an eventful day.',
        'cost': isBudget ? 300.0 : (isLuxury ? 3500.0 : 1200.0),
        'tag': 'Leisure & Sunset',
        'icon': Icons.wb_twilight,
        'color': Colors.purple,
        'mapQuery': '$dest Pakistan',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final currentDayBudget = _dayBudgets[_selectedDay] ?? (_totalTripBudget / _dayCount);
    final activities = _getCuratedActivitiesForDay(_selectedDay, currentDayBudget);

    // Activity costs
    double totalActivityCost = 0;
    for (var a in activities) {
      totalActivityCost += (a['cost'] as num).toDouble();
    }

    final isUnderBudget = totalActivityCost <= currentDayBudget;
    final remainingForFuture = _getRemainingWalletForFutureDays(_selectedDay);
    final futureDaysCount = _dayCount - (_selectedDay + 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.origin} → ${widget.destination}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '$_dayCount Days • ${widget.travelers} Traveler${widget.travelers > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          _buildCurrencySelector(context, currency),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Adjust Day Budget',
            onPressed: () => _showSetDayBudgetDialog(_selectedDay),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Day Selector Carousel
          _buildDaySelector(currency),

          // 2. Dynamic Trip Wallet & Day Spending Engine Card
          _buildWalletEngineCard(currency, currentDayBudget, remainingForFuture, futureDaysCount),

          // 3. Day Activity Cost Comparison Badge
          _buildActivityBudgetComparison(currency, totalActivityCost, currentDayBudget, isUnderBudget),

          // 4. Timeline Activities List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 80),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return _buildActivityTimelineCard(activities[index], currency, index == activities.length - 1);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(activities),
    );
  }

  // ── 1. Day Selector Carousel ────────────────────────────────────────────────
  Widget _buildDaySelector(CurrencyProvider currency) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 62,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _dayCount,
          itemBuilder: (context, index) {
            final isSelected = _selectedDay == index;
            final dayDate = widget.startDate.add(Duration(days: index));
            final allocated = _dayBudgets[index] ?? (_totalTripBudget / _dayCount);

            return GestureDetector(
              onTap: () => setState(() => _selectedDay = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppTheme.primaryPurple, Color(0xFF8E24AA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Day ${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dayDate.day}/${dayDate.month} • ${currency.formatPrice(allocated)}',
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── 2. Dynamic Trip Wallet & Day Spending Engine Card ───────────────────────
  Widget _buildWalletEngineCard(
    CurrencyProvider currency,
    double currentDayBudget,
    double remainingForFuture,
    int futureDaysCount,
  ) {
    final spentEarlier = _getSpentEarlier(_selectedDay);
    final fractionUsedSoFar = (_totalTripBudget > 0) ? (spentEarlier / _totalTripBudget).clamp(0.0, 1.0) : 0.0;
    final fractionThisDay = (_totalTripBudget > 0) ? (currentDayBudget / _totalTripBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wallet, color: AppTheme.primaryPurple, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day ${_selectedDay + 1} Budget Allocation',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Trip Total: ${currency.formatPrice(_totalTripBudget)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Change', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPurple,
                  side: const BorderSide(color: AppTheme.primaryPurple),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showSetDayBudgetDialog(_selectedDay),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Big Amount Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Willing to spend today:', style: TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currency.formatPrice(currentDayBudget),
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Remaining Trip Wallet:', style: TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        currency.formatPrice(remainingForFuture),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: remainingForFuture > 0 ? AppTheme.primaryPurple : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Multi-Segment Visual Budget Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  if (fractionUsedSoFar > 0)
                    Flexible(
                      flex: (fractionUsedSoFar * 100).toInt(),
                      child: Container(color: Colors.grey.shade400),
                    ),
                  Flexible(
                    flex: (fractionThisDay * 100).toInt().clamp(1, 100),
                    child: Container(color: Colors.green),
                  ),
                  if (1.0 - fractionUsedSoFar - fractionThisDay > 0)
                    Flexible(
                      flex: ((1.0 - fractionUsedSoFar - fractionThisDay) * 100).toInt().clamp(0, 100),
                      child: Container(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Smart Wallet Advisory
          Row(
            children: [
              Icon(
                futureDaysCount > 0 ? Icons.info_outline : Icons.flag_circle_outlined,
                size: 14,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  futureDaysCount > 0
                      ? 'You have ${currency.formatPrice(remainingForFuture)} left for the next $futureDaysCount day${futureDaysCount > 1 ? 's' : ''} (~${currency.formatPrice(remainingForFuture / futureDaysCount)}/day).'
                      : 'Final Day of trip! Remaining wallet: ${currency.formatPrice(remainingForFuture)}.',
                  style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 3. Day Activity Cost Comparison Badge ──────────────────────────────────
  Widget _buildActivityBudgetComparison(
    CurrencyProvider currency,
    double totalActivityCost,
    double currentDayBudget,
    bool isUnderBudget,
  ) {
    final diff = (currentDayBudget - totalActivityCost).abs();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isUnderBudget ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnderBudget ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isUnderBudget ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isUnderBudget ? Colors.green.shade700 : Colors.red.shade700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isUnderBudget
                  ? 'Activities estimate (${currency.formatPrice(totalActivityCost)}) is within Day ${_selectedDay + 1} budget! Save ${currency.formatPrice(diff)}.'
                  : 'Activities (${currency.formatPrice(totalActivityCost)}) exceed day limit by ${currency.formatPrice(diff)}.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isUnderBudget ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Timeline Activity Card ──────────────────────────────────────────────
  Widget _buildActivityTimelineCard(
    Map<String, dynamic> act,
    CurrencyProvider currency,
    bool isLast,
  ) {
    final cost = (act['cost'] as num).toDouble();
    final isFree = cost == 0;
    final Color color = act['color'] as Color? ?? AppTheme.primaryPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Badge & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(act['icon'] as IconData? ?? Icons.star, size: 14, color: color),
                      const SizedBox(width: 6),
                      Text(
                        '${act['period']} • ${act['time']}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isFree ? Colors.green.shade50 : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isFree ? Colors.green.shade200 : Colors.purple.shade200),
                  ),
                  child: Text(
                    isFree ? 'FREE' : currency.formatPrice(cost),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isFree ? Colors.green.shade800 : Colors.purple.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              act['title'] as String,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),

            // Location with pin
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    act['place'] as String? ?? widget.destination,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              act['desc'] as String,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.35),
            ),
            const SizedBox(height: 12),

            // Action row: Category Tag + Map Shortcut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    act['tag'] as String? ?? 'Experience',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.map_outlined, size: 15),
                  label: const Text('View on Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () {
                    final rawQuery = act['mapQuery'] as String? ?? '${act['title']}, ${widget.destination}';
                    final query = rawQuery.contains('Pakistan') ? rawQuery : '$rawQuery, Pakistan';
                    _openMap(query);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Action Bar ───────────────────────────────────────────────────────
  Widget _buildBottomActionBar(List<Map<String, dynamic>> activities) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bookmark / Save
            IconButton(
              icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, color: _isSaved ? Colors.green : Colors.grey[700]),
              tooltip: 'Save Route',
              onPressed: () {
                setState(() => _isSaved = !_isSaved);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isSaved ? 'Trip route saved to favorites!' : 'Removed from saved'),
                    backgroundColor: _isSaved ? Colors.green : Colors.grey[800],
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            // Packing Checklist Shortcut
            IconButton(
              icon: const Icon(Icons.checklist, color: AppTheme.primaryPurple),
              tooltip: 'Packing Checklist',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SmartPackingScreen(
                    destination: widget.destination,
                    duration: '$_dayCount days',
                    weather: 'Seasonal',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Download PDF Itinerary Button
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('Export Itinerary PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Generating Itinerary PDF...'), behavior: SnackBarBehavior.floating),
                    );
                    await PDFService.generateItineraryPDF(
                      destination: widget.destination,
                      activities: activities,
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context, CurrencyProvider currency) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currency.selectedCurrency,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.currency_exchange, size: 18, color: Colors.white70),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
          items: currency.currencies
              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.black87))))
              .toList(),
          onChanged: (val) {
            if (val != null) currency.setCurrency(val);
          },
        ),
      ),
    );
  }
}
