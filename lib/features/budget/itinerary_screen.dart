import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/currency_provider.dart';
import '../../core/pdf_service.dart';
import '../../core/theme.dart';
import '../../core/weather_service.dart';
import 'smart_packing_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int travelers;

  const ItineraryScreen({
    super.key,
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
  late double _perPersonBudget;
  late double _dailyBudgetCap;

  @override
  void initState() {
    super.initState();
    _perPersonBudget = widget.travelers > 0
        ? widget.budget / widget.travelers
        : widget.budget;
        
    final days = widget.endDate.difference(widget.startDate).inDays.abs() + 1;
    final dayCount = days > 0 ? days : 1;
    _dailyBudgetCap = _perPersonBudget / dayCount;

    WidgetsBinding.instance.addPostFrameCallback((_) => _showBudgetDialog());
  }

  void _showBudgetDialog() {
    final controller =
        TextEditingController(text: _perPersonBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Total Trip Budget/Person',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Activities within your budget will be highlighted. Over-budget items will be flagged.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                hintText: 'e.g. 5000',
                labelText: 'Per Person Budget (PKR)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                if (controller.text.isEmpty) {
                  throw const FormatException("Budget cannot be empty.");
                }
                final text = controller.text.replaceAll(RegExp(r'[^0-9.]'), '');
                final val = double.tryParse(text);
                
                if (val == null) {
                  throw const FormatException("Please enter a valid numeric budget.");
                }
                if (val < 1000) {
                  throw const FormatException("Budget cannot be lower than PKR 1000.");
                }
                if (val.isInfinite || val.isNaN || val > 1000000000) {
                  throw const FormatException("Invalid or unrealistic budget amount.");
                }
                
                setState(() {
                  _perPersonBudget = val;
                  final days = widget.endDate.difference(widget.startDate).inDays.abs() + 1;
                  final dayCount = days > 0 ? days : 1;
                  _dailyBudgetCap = _perPersonBudget / dayCount;
                });
                Navigator.pop(ctx);
              } on FormatException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("An error occurred while updating the budget.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getActivitiesForDay(int day) {
    final d = widget.destination;
    final allDays = <List<Map<String, dynamic>>>[
      // Day 1 – Arrival
      [
        {'time': '09:00 AM', 'period': 'Morning',   'title': 'Arrival & Check-in',        'desc': "Arrive at $d and settle into your accommodation comfortably.",          'icon': Icons.hotel_outlined,             'color': Colors.blue,        'cost': 1500.0},
        {'time': '02:00 PM', 'period': 'Afternoon', 'title': 'City Orientation Walk',     'desc': "Stroll through the main streets and get a feel for $d.",                'icon': Icons.directions_walk_outlined,   'color': Colors.orange,      'cost': 0.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Welcome Dinner',            'desc': "Enjoy your first authentic meal at a top-rated local spot in $d.",      'icon': Icons.restaurant_outlined,        'color': Colors.green,       'cost': 2000.0},
      ],
      // Day 2 – Culture & Heritage
      [
        {'time': '08:30 AM', 'period': 'Morning',   'title': 'Heritage Museum Tour',      'desc': "Explore the rich cultural history of $d at the local museum.",          'icon': Icons.museum_outlined,            'color': Colors.brown,       'cost': 800.0},
        {'time': '12:30 PM', 'period': 'Afternoon', 'title': 'Old Town Bazaar',           'desc': "Browse handmade crafts and spices at the traditional bazaar.",           'icon': Icons.storefront_outlined,        'color': Colors.purple,      'cost': 2000.0},
        {'time': '06:30 PM', 'period': 'Evening',   'title': 'Sunset Viewpoint',          'desc': "Watch the golden-hour skyline from the most iconic overlook in $d.",    'icon': Icons.wb_twilight_outlined,       'color': Colors.deepOrange,  'cost': 500.0},
      ],
      // Day 3 – Adventure & Nature
      [
        {'time': '07:00 AM', 'period': 'Morning',   'title': 'Early Morning Trek',        'desc': "Hit the trails at dawn for breathtaking views around $d.",              'icon': Icons.hiking_outlined,            'color': Colors.green,       'cost': 3000.0},
        {'time': '01:00 PM', 'period': 'Afternoon', 'title': 'Lakeside Picnic',           'desc': "Relax at a scenic waterfront near $d with a packed lunch.",             'icon': Icons.water_outlined,             'color': Colors.teal,        'cost': 1000.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Bonfire & Stargazing',      'desc': "Unwind around a bonfire and enjoy the clear night sky near $d.",        'icon': Icons.local_fire_department,      'color': Colors.red,         'cost': 500.0},
      ],
      // Day 4 – Local Life
      [
        {'time': '09:00 AM', 'period': 'Morning',   'title': 'Village Community Visit',   'desc': "Meet locals and experience authentic village culture near $d.",          'icon': Icons.people_outline,             'color': Colors.indigo,      'cost': 600.0},
        {'time': '12:00 PM', 'period': 'Afternoon', 'title': 'Street Food Trail',         'desc': "Sample the best street foods on a self-guided culinary walk in $d.",    'icon': Icons.fastfood_outlined,          'color': Colors.amber,       'cost': 1500.0},
        {'time': '06:00 PM', 'period': 'Evening',   'title': 'Cultural Show',             'desc': "Attend a local music or dance performance in the city center of $d.",   'icon': Icons.theater_comedy_outlined,    'color': Colors.pinkAccent,  'cost': 1200.0},
      ],
      // Day 5 – Relaxation & Wellness
      [
        {'time': '09:30 AM', 'period': 'Morning',   'title': 'Spa & Wellness Session',    'desc': "Treat yourself to a traditional massage and wellness therapy in $d.",   'icon': Icons.self_improvement,           'color': Colors.cyan,        'cost': 2500.0},
        {'time': '01:00 PM', 'period': 'Afternoon', 'title': 'Photography Walk',          'desc': "Capture the hidden scenic corners of $d with your camera.",             'icon': Icons.camera_alt_outlined,        'color': Colors.blueGrey,    'cost': 0.0},
        {'time': '07:30 PM', 'period': 'Evening',   'title': 'Rooftop Dinner',            'desc': "Dine under the stars at a rooftop restaurant in $d.",                   'icon': Icons.dinner_dining,              'color': Colors.deepPurple,  'cost': 3500.0},
      ],
      // Day 6 – Excursion Day
      [
        {'time': '07:30 AM', 'period': 'Morning',   'title': 'Day Trip Excursion',        'desc': "Head out to a nearby natural wonder or landmark around $d.",             'icon': Icons.directions_car_outlined,    'color': Colors.teal,        'cost': 4000.0},
        {'time': '01:30 PM', 'period': 'Afternoon', 'title': 'Lunch at Scenic Spot',      'desc': "Enjoy a meal with panoramic views far from the city of $d.",            'icon': Icons.lunch_dining,               'color': Colors.orange,      'cost': 1800.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Night Market Stroll',       'desc': "Browse the lively night market stalls back in $d.",                     'icon': Icons.nightlife_outlined,         'color': Colors.purple,      'cost': 1000.0},
      ],
      // Day 7 – Souvenir & Farewell Prep
      [
        {'time': '09:00 AM', 'period': 'Morning',   'title': 'Souvenir Shopping',         'desc': "Pick up gifts and keepsakes from the local shops of $d.",               'icon': Icons.shopping_cart_outlined,     'color': Colors.green,       'cost': 2000.0},
        {'time': '12:00 PM', 'period': 'Afternoon', 'title': 'Leisure & Rest',            'desc': "Relax and recharge at your accommodation in $d.",                       'icon': Icons.luggage_outlined,           'color': Colors.blueGrey,    'cost': 0.0},
        {'time': '06:00 PM', 'period': 'Evening',   'title': 'Farewell Celebration',      'desc': "Toast to an unforgettable trip at the best restaurant in $d.",          'icon': Icons.celebration_outlined,       'color': Colors.red,         'cost': 3500.0},
      ],
      // Day 8 – Water & Outdoor Activities
      [
        {'time': '08:00 AM', 'period': 'Morning',   'title': 'Boat Ride / River Cruise',  'desc': "Experience $d from the water on a scenic morning boat ride.",           'icon': Icons.rowing_outlined,            'color': Colors.blue,        'cost': 2500.0},
        {'time': '01:00 PM', 'period': 'Afternoon', 'title': 'Fishing or Kayaking',       'desc': "Try a water sport activity at the riverside near $d.",                  'icon': Icons.waves_outlined,             'color': Colors.teal,        'cost': 3000.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Seafood / BBQ Dinner',      'desc': "Savour fresh grilled seafood or BBQ at a riverside spot in $d.",        'icon': Icons.outdoor_grill_outlined,     'color': Colors.deepOrange,  'cost': 2500.0},
      ],
      // Day 9 – Spiritual & Historical
      [
        {'time': '08:30 AM', 'period': 'Morning',   'title': 'Shrine or Fort Visit',      'desc': "Explore the ancient shrine or fort that defines the history of $d.",    'icon': Icons.fort_outlined,              'color': Colors.brown,       'cost': 700.0},
        {'time': '12:00 PM', 'period': 'Afternoon', 'title': 'Historical Library Walk',   'desc': "Visit the archive or library district in the heart of $d.",             'icon': Icons.chrome_reader_mode_outlined,'color': Colors.indigo,      'cost': 300.0},
        {'time': '06:30 PM', 'period': 'Evening',   'title': 'Candlelit Heritage Dinner', 'desc': "Dine in a restored heritage building by candlelight near $d.",          'icon': Icons.local_dining_outlined,      'color': Colors.amber,       'cost': 3000.0},
      ],
      // Day 10 – Art & Creativity
      [
        {'time': '09:00 AM', 'period': 'Morning',   'title': 'Art Gallery Tour',          'desc': "Discover local paintings and sculptures at galleries in $d.",           'icon': Icons.palette_outlined,           'color': Colors.pinkAccent,  'cost': 600.0},
        {'time': '01:30 PM', 'period': 'Afternoon', 'title': 'Craft Workshop',            'desc': "Join a hands-on pottery, weaving, or painting class in $d.",            'icon': Icons.draw_outlined,              'color': Colors.purple,      'cost': 1800.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Live Music Evening',        'desc': "Enjoy live folk or jazz music at a cozy venue in $d.",                  'icon': Icons.music_note_outlined,        'color': Colors.deepPurple,  'cost': 1000.0},
      ],
      // Day 11 – Food & Cooking
      [
        {'time': '09:00 AM', 'period': 'Morning',   'title': 'Local Farm or Orchard Visit','desc': "Visit a farm close to $d and pick fresh produce for the day.",          'icon': Icons.grass_outlined,             'color': Colors.lightGreen,  'cost': 800.0},
        {'time': '12:00 PM', 'period': 'Afternoon', 'title': 'Cooking Class',             'desc': "Learn to cook traditional dishes of the $d region with a local chef.",  'icon': Icons.soup_kitchen_outlined,      'color': Colors.orange,      'cost': 2000.0},
        {'time': '07:30 PM', 'period': 'Evening',   'title': 'Progressive Dinner Trail',  'desc': "Visit three restaurants in $d for starters, mains, and dessert.",       'icon': Icons.restaurant_menu_outlined,   'color': Colors.green,       'cost': 3500.0},
      ],
      // Day 12 – Sports & Fitness
      [
        {'time': '07:00 AM', 'period': 'Morning',   'title': 'Cycling Tour',              'desc': "Rent a bike and cycle through the scenic routes around $d.",             'icon': Icons.directions_bike_outlined,   'color': Colors.cyan,        'cost': 1500.0},
        {'time': '12:30 PM', 'period': 'Afternoon', 'title': 'Rock Climbing or Rappelling','desc': "Try adventure climbing at a local guided spot near $d.",                'icon': Icons.terrain_outlined,           'color': Colors.brown,       'cost': 3500.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Sports Lounge & Dinner',    'desc': "Wind down at a sports-themed lounge restaurant in $d.",                 'icon': Icons.sports_bar_outlined,        'color': Colors.blue,        'cost': 2000.0},
      ],
      // Day 13 – Wildlife & Forest
      [
        {'time': '06:30 AM', 'period': 'Morning',   'title': 'Bird Watching at Dawn',     'desc': "Spot rare migratory birds at a nature reserve near $d.",                'icon': Icons.flutter_dash,               'color': Colors.lightGreen,  'cost': 500.0},
        {'time': '11:00 AM', 'period': 'Afternoon', 'title': 'Forest Nature Walk',        'desc': "Guided walk through the forest trails exploring flora near $d.",        'icon': Icons.forest_outlined,            'color': Colors.green,       'cost': 1200.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Campfire Storytelling',     'desc': "Gather around a campfire for stories and music near $d.",               'icon': Icons.local_fire_department,      'color': Colors.red,         'cost': 700.0},
      ],
      // Day 14 – Volunteer & Community
      [
        {'time': '09:00 AM', 'period': 'Morning',   'title': 'Community Volunteering',    'desc': "Give back by joining a local community project in $d.",                 'icon': Icons.volunteer_activism_outlined, 'color': Colors.teal,       'cost': 0.0},
        {'time': '01:00 PM', 'period': 'Afternoon', 'title': 'Charity Market Visit',      'desc': "Support local artisans at the charity craft fair near $d.",             'icon': Icons.handshake_outlined,         'color': Colors.indigo,      'cost': 1000.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Community Feast',           'desc': "Share a communal meal with locals as a heartfelt send-off in $d.",      'icon': Icons.people_alt_outlined,        'color': Colors.amber,       'cost': 1500.0},
      ],
      // Day 15 – Grand Finale
      [
        {'time': '09:00 AM', 'period': 'Morning',   'title': 'Final Landmark Visit',      'desc': "Revisit your favorite spot one last time and soak it all in at $d.",    'icon': Icons.location_on_outlined,       'color': Colors.deepPurple,  'cost': 500.0},
        {'time': '12:30 PM', 'period': 'Afternoon', 'title': 'Memorial Photo Session',    'desc': "Capture group photos at the best backdrops $d has to offer.",           'icon': Icons.photo_camera_outlined,      'color': Colors.blueGrey,    'cost': 0.0},
        {'time': '07:00 PM', 'period': 'Evening',   'title': 'Grand Closing Banquet',     'desc': "Celebrate the entire journey with a lavish banquet dinner in $d.",      'icon': Icons.celebration_outlined,       'color': Colors.red,         'cost': 5000.0},
      ],
    ];

    if (day < allDays.length) return allDays[day];

    final themes = ['Exploration', 'Leisure', 'Adventure', 'Culture', 'Relaxation', 'Shopping', 'Nature'];
    final theme = themes[day % themes.length];
    return [
      {'time': '09:00 AM', 'period': 'Morning',   'title': "Day ${day + 1} – $theme",   'desc': "Discover new experiences in $d on day ${day + 1}.",        'icon': Icons.map_outlined,          'color': Colors.indigo,  'cost': 2000.0},
      {'time': '01:00 PM', 'period': 'Afternoon', 'title': 'Midday Activities',          'desc': "Explore local attractions and enjoy the surroundings of $d.", 'icon': Icons.explore_outlined,      'color': Colors.teal,    'cost': 1200.0},
      {'time': '07:00 PM', 'period': 'Evening',   'title': 'Evening Dining',             'desc': "Try a new restaurant and enjoy the atmosphere of $d.",       'icon': Icons.local_dining_outlined, 'color': Colors.orange,  'cost': 1800.0},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.endDate.difference(widget.startDate).inDays.abs() + 1;
    final dayCount = days > 0 ? days : 1;
    final activities = _getActivitiesForDay(_selectedDay);
    final currency = context.watch<CurrencyProvider>();

    // Compute used budget for this day
    double used = 0;
    for (final act in activities) {
      used += act['cost'] as double;
    }

    double runningTotal = 0;
    final List<Widget> activityWidgets = [];
    for (int i = 0; i < activities.length; i++) {
      final act = activities[i];
      final cost = act['cost'] as double;
      runningTotal += cost;
      final isItemOverBudget = runningTotal > _dailyBudgetCap && cost > 0;
      final overage = isItemOverBudget ? (runningTotal - _dailyBudgetCap) : 0.0;

      activityWidgets.add(
        _buildTimelineSlot(
          act['period'] as String,
          act['time'] as String,
          act['title'] as String,
          act['desc'] as String,
          act['icon'] as IconData,
          act['color'] as Color,
          cost,
          currency,
          isOverBudget: isItemOverBudget,
          overage: overage,
          isLast: i == activities.length - 1,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Trip to ${widget.destination}'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          // Currency selector
          _buildCurrencySelector(context, currency),
          // Edit budget
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Change Budget',
            onPressed: _showBudgetDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(dayCount),
          _buildBudgetSummaryBar(currency, used),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ...activityWidgets,
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(activities),
    );
  }

  // ── Budget Summary Bar ───────────────────────────────────────────────────
  Widget _buildBudgetSummaryBar(CurrencyProvider currency, double used) {
    final withinBudget = used <= _dailyBudgetCap;
    final budgetLabel = currency.formatPrice(_dailyBudgetCap);
    final usedLabel = used > 0 ? currency.formatPrice(used) : 'Rs. 0';

    return Container(
      color: withinBudget ? Colors.green.shade50 : Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(
            withinBudget ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            color: withinBudget ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Daily limit: $budgetLabel',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: withinBudget ? Colors.green[800] : Colors.red[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'Used: $usedLabel',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: withinBudget ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  // ── Currency Selector ────────────────────────────────────────────────────
  Widget _buildCurrencySelector(BuildContext context, CurrencyProvider currency) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currency.selectedCurrency,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.currency_exchange, size: 18, color: Colors.white70),
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
          underline: const SizedBox(),
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

  // ── Action Buttons ───────────────────────────────────────────────────────
  Widget _buildActionButtons(List<Map<String, dynamic>> activities) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Save Button
            _actionBtn(
              flex: 1,
              color: _isSaved ? Colors.green : Colors.grey[200]!,
              onTap: () {
                setState(() => _isSaved = !_isSaved);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(_isSaved ? 'Itinerary saved!' : 'Removed from saved'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: _isSaved ? Colors.green : Colors.grey[800],
                ));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSaved ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                    color: _isSaved ? Colors.white : Colors.grey[700],
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isSaved ? 'Saved' : 'Save',
                    style: GoogleFonts.poppins(
                      color: _isSaved ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Download PDF Button
            _actionBtn(
              flex: 2,
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF9B51E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Generating Itinerary PDF...'),
                    behavior: SnackBarBehavior.floating,
                  ));
                  await PDFService.generateItineraryPDF(
                    destination: widget.destination,
                    activities: activities,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Download PDF',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Share -> Smart Packing Button
            _actionBtn(
              flex: 2,
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Analyzing location and local weather...'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                ));
                final weatherCondition = await WeatherService.getCurrentWeatherCondition(widget.destination);
                
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SmartPackingScreen(
                        destination: widget.destination,
                        duration: '${widget.endDate.difference(widget.startDate).inDays.abs() + 1} days',
                        weather: weatherCondition,
                      ),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.backpack_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Smart Packing',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required int flex,
    Color? color,
    Gradient? gradient,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: gradient == null ? color : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: gradient != null
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 3))]
                : [],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Day Selector ─────────────────────────────────────────────────────────
  Widget _buildDaySelector(int dayCount) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dayCount,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDay;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 58,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPurple : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppTheme.primaryPurple.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Day', style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(
                    '${index + 1}',
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Timeline Slot ─────────────────────────────────────────────────────────
  Widget _buildTimelineSlot(
    String timeOfDay,
    String time,
    String title,
    String description,
    IconData icon,
    Color color,
    double cost,
    CurrencyProvider currency, {
    bool isOverBudget = false,
    double overage = 0.0,
    bool isLast = false,
  }) {

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isOverBudget ? Colors.grey[300] : color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isOverBudget ? Colors.grey[500] : Colors.white, size: 20),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(timeOfDay,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isOverBudget ? Colors.grey : color)),
                      const Spacer(),
                      Text(time,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isOverBudget ? Colors.grey[50] : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: isOverBudget
                          ? Border.all(color: Colors.red.shade200, width: 1)
                          : null,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(title,
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isOverBudget ? Colors.grey[600] : Colors.black)),
                            ),
                            if (isOverBudget)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  'Over Budget',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700]),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(description,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isOverBudget ? Colors.grey[400] : Colors.grey[600])),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.currency_exchange,
                                size: 13,
                                color: isOverBudget ? Colors.red : Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              cost > 0 ? currency.formatPrice(cost) : 'Free',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isOverBudget ? Colors.red : Colors.green),
                            ),
                            if (isOverBudget) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${currency.formatPrice(overage)} over)',
                                style: GoogleFonts.poppins(
                                    fontSize: 10, color: Colors.red[400]),
                              ),
                            ],
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
