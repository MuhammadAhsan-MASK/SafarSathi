import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/gemini_service.dart';
import '../budget/trip_planner_screen.dart';
import '../hotels/hotel_screen.dart';
import '../restaurants/restaurant_screen.dart';
import '../transport/transport_screen.dart';
import '../attractions/attractions_screen.dart';
import '../lingo/lingo_screen.dart';
import '../auth/role_selection_screen.dart';
import '../news/widgets/live_travel_news_section.dart';
import '../eco_tracker/eco_tracker_screen.dart';
import '../guides/guides_screen.dart';
import '../bargain/bargain_screen.dart';

import 'package:provider/provider.dart';
import '../../core/currency_provider.dart';
import '../auth/user_role_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSwitching = false;

  // ── Surprise Me ───────────────────────────────────────────────────────────
  void _showSurpriseMeSheet(BuildContext context) {
    String selectedVibe = 'Adventure';
    String selectedDuration = 'Weekend (2–3 days)';
    final budgetController = TextEditingController(text: '15000');

    final vibes = [
      ('Adventure', '🏔️'),
      ('Cultural', '🕌'),
      ('Relaxation', '🌿'),
      ('Food Tour', '🍜'),
      ('Wildlife', '🦅'),
      ('Road Trip', '🚗'),
    ];
    final durations = [
      'Day Trip (1 day)',
      'Weekend (2–3 days)',
      'Short Trip (4–5 days)',
      'Week (7 days)',
      'Extended (10+ days)',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          minChildSize: 0.5,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.all(24),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Surprise Me!',
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('AI-powered trip suggestion just for you',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Budget
                Text('Your Total Budget (PKR)',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 8),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryPurple),
                    hintText: 'e.g. 20000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                ),
                const SizedBox(height: 24),
                // Trip Vibe
                Text('Trip Vibe',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: vibes.map((v) {
                    final isSelected = selectedVibe == v.$1;
                    return GestureDetector(
                      onTap: () => setSheet(() => selectedVibe = v.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryPurple : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected ? [
                            BoxShadow(color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                                blurRadius: 8, offset: const Offset(0, 4))
                          ] : [],
                        ),
                        child: Text('${v.$2} ${v.$1}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Duration
                Text('Duration',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: durations.map((d) {
                    final isSelected = selectedDuration == d;
                    return GestureDetector(
                      onTap: () => setSheet(() => selectedDuration = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00C853) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected ? [
                            BoxShadow(color: const Color(0xFF00C853).withValues(alpha: 0.3),
                                blurRadius: 8, offset: const Offset(0, 4))
                          ] : [],
                        ),
                        child: Text(d,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                // Generate Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final parsedText = budgetController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                      final budget = double.tryParse(parsedText) ?? 15000;
                      
                      int minBudget = 5000;
                      if (selectedDuration.contains('1 day')) {
                        minBudget = 1500;
                      } else if (selectedDuration.contains('2–3')) {
                        minBudget = 4000;
                      } else if (selectedDuration.contains('4–5')) {
                        minBudget = 7000;
                      } else if (selectedDuration.contains('7 days')) {
                        minBudget = 10000;
                      } else {
                        minBudget = 15000;
                      }

                      if (budget < minBudget) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Budget too low for $selectedDuration. Minimum realistic budget is PKR $minBudget.')),
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      _showSurpriseMeResult(context, budget, selectedVibe, selectedDuration);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      shadowColor: AppTheme.primaryPurple.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text('Generate My Trip!',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSurpriseMeResult(
      BuildContext context, double budget, String vibe, String duration) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => _SurpriseMeResultSheet(
        budget: budget, vibe: vibe, duration: duration),
    );
  }

  void _handleQuickSwitch() async {
    final roleService = UserRoleService();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Traveler Mode'),
        content: const Text('Do you want to switch to Service Provider mode?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
            child: const Text('Switch Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) setState(() => _isSwitching = true);
      try {
        await roleService.updateUserRole('Service Provider');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to switch: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSwitching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSwitching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumHeader(context),
            const SizedBox(height: 20),
            _buildExploreServices(context),
            const SizedBox(height: 10),
            const LiveTravelNewsSection(),
            const SizedBox(height: 14),
            _buildFeaturedDestinations(context),
            const SizedBox(height: 24),
            _buildEcoTrackerBanner(context),
            const SizedBox(height: 24),
            _buildRecentTrips(context),
            const SizedBox(height: 24),
            _buildServiceProviderBanner(context),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, bottom: 28, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar with Greeting & Action Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Greeting (Flexible so it takes remaining space safely)
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
                      ),
                      child: const Icon(Icons.explore_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Assalam o Alaikum 🇵🇰',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withAlpha(220),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Explore Pakistan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Action badges
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Currency Selector
                  Consumer<CurrencyProvider>(
                    builder: (context, currencyProvider, child) {
                      return InkWell(
                        onTap: () => _showCurrencyPicker(context, currencyProvider),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.currency_exchange, color: Colors.white, size: 13),
                              const SizedBox(width: 3),
                              Text(
                                currencyProvider.selectedCurrency,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  // Switch role
                  InkWell(
                    onTap: _handleQuickSwitch,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Search and City Chips
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF5E17EB), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Where in Pakistan are you traveling?',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Hunza',
                      'Skardu',
                      'Swat',
                      'Lahore',
                      'Murree',
                      'Karachi',
                      'Gwadar',
                    ].map((city) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttractionsScreen(initialCity: city),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F1FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              city,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5E17EB),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Dual Action Buttons: AI Trip Planner & Surprise Me
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TripPlannerScreen()),
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5E17EB).withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_location_alt_rounded, color: Color(0xFF5E17EB), size: 16),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Plan Trip',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: const Color(0xFF1E2022),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _showSurpriseMeSheet(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5252), Color(0xFFFF9100)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withAlpha(60),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.casino_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Surprise Me!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreServices(BuildContext context) {
    final services = [
      {'title': 'Hotels', 'icon': Icons.hotel_rounded, 'color': AppTheme.hotelColor, 'bg': AppTheme.hotelBg, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HotelScreen()))},
      {'title': 'Dining', 'icon': Icons.restaurant_rounded, 'color': AppTheme.foodColor, 'bg': AppTheme.foodBg, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantScreen()))},
      {'title': 'Transport', 'icon': Icons.directions_bus_rounded, 'color': AppTheme.transportColor, 'bg': AppTheme.transportBg, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()))},
      {'title': 'Attractions', 'icon': Icons.location_on_rounded, 'color': AppTheme.attractionColor, 'bg': AppTheme.attractionBg, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttractionsScreen()))},
      {'title': 'Safar Lingo', 'icon': Icons.translate_rounded, 'color': Colors.teal.shade700, 'bg': Colors.teal.shade50, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LingoScreen()))},
      {'title': 'Guides', 'icon': Icons.person_pin_circle_rounded, 'color': Colors.deepOrange.shade600, 'bg': Colors.orange.shade50, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidesScreen()))},
      {'title': 'Bargain', 'icon': Icons.price_check_rounded, 'color': Colors.green.shade700, 'bg': Colors.green.shade50, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BargainScreen()))},
      {'title': 'Eco-Tracker', 'icon': Icons.eco_rounded, 'color': const Color(0xFF00897B), 'bg': const Color(0xFFE0F2F1), 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EcoTrackerScreen()))},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Services',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2429),
                ),
              ),
              Text(
                'All-in-One Travel',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final s = services[index];
              return _buildServiceTile(
                context,
                s['title'] as String,
                s['icon'] as IconData,
                s['color'] as Color,
                s['bg'] as Color,
                s['onTap'] as VoidCallback,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, String title, IconData icon, Color color, Color bgColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFF0F6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedDestinations(BuildContext context) {
    final destinations = [
      {
        'name': 'Hunza Valley',
        'city': 'Hunza',
        'province': 'Gilgit-Baltistan',
        'tag': 'Mountain Paradise',
        'image': 'https://images.unsplash.com/photo-1596484552834-6a58f850e0a1?w=800',
        'price': 'From PKR 15,000',
      },
      {
        'name': 'Skardu',
        'city': 'Skardu',
        'province': 'Baltistan',
        'tag': 'Gateway to K2',
        'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
        'price': 'From PKR 20,000',
      },
      {
        'name': 'Swat Valley',
        'city': 'Swat',
        'province': 'Khyber Pakhtunkhwa',
        'tag': 'Switzerland of East',
        'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
        'price': 'From PKR 10,000',
      },
      {
        'name': 'Lahore',
        'city': 'Lahore',
        'province': 'Punjab',
        'tag': 'Culture & Food Capital',
        'image': 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=800',
        'price': 'From PKR 5,000',
      },
      {
        'name': 'Murree Hills',
        'city': 'Murree',
        'province': 'Punjab / Hill Station',
        'tag': 'Pines & Snow Retreat',
        'image': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800',
        'price': 'From PKR 6,000',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Destinations',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2429),
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttractionsScreen()),
                ),
                child: Text(
                  'Explore All →',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5E17EB),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 185,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final d = destinations[index];
              return Container(
                width: 210,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(d['image']!),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttractionsScreen(initialCity: d['city']),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(210),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(60),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              d['tag']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            d['name']!,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${d['province']} • ${d['price']}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withAlpha(210),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCurrencyPicker(BuildContext context, CurrencyProvider currencyProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Preferred Currency',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ...currencyProvider.currencies.map((currency) {
                final isSelected = currencyProvider.selectedCurrency == currency;
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: isSelected ? const Color(0xFFF4F1FD) : null,
                  leading: Text(
                    isSelected ? '✓' : '•',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF5E17EB) : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  title: Text(
                    currency,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF5E17EB) : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    currencyProvider.setCurrency(currency);
                    Navigator.pop(context);
                  },
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF5E17EB)) : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEcoTrackerBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EcoTrackerScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withAlpha(50),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eco-Friendly Traveler',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track carbon footprint & earn green badges across Pakistan.',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTrips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Your Travel Itineraries',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2429),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(22),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEFF0F6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F1FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.luggage_rounded, color: Color(0xFF5E17EB), size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                'No Active Itinerary',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Use the AI Trip Planner to create a personalized day-by-day budget itinerary.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TripPlannerScreen()),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create Itinerary'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceProviderBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Partner with SastaSafar',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'List your Hotel, Restaurant, or Transport fleet.',
                        style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: const Text('Register Business Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Surprise Me Result Sheet ─────────────────────────────────────────────────
class _SurpriseMeResultSheet extends StatefulWidget {
  final double budget;
  final String vibe;
  final String duration;

  const _SurpriseMeResultSheet({
    required this.budget,
    required this.vibe,
    required this.duration,
  });

  @override
  State<_SurpriseMeResultSheet> createState() => _SurpriseMeResultSheetState();
}

class _SurpriseMeResultSheetState extends State<_SurpriseMeResultSheet>
    with SingleTickerProviderStateMixin {
  Map<String, String>? _result;
  bool _loading = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _fetchSuggestion();
  }

  Future<void> _fetchSuggestion() async {
    final result = await GeminiService.surpriseMe(
      budget: widget.budget,
      vibe: widget.vibe,
      duration: widget.duration,
    );
    if (mounted) {
      setState(() {
        _result = result;
        _loading = false;
      });
      _animCtrl.forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: _loading ? _buildLoading(sc) : _buildResult(sc),
      ),
    );
  }

  Widget _buildLoading(ScrollController sc) {
    return ListView(
      controller: sc,
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              ),
              const SizedBox(height: 20),
              Text('AI is crafting your perfect trip...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Analysing ${widget.vibe} trips within PKR ${widget.budget.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult(ScrollController sc) {
    final r = _result!;
    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView(
        controller: sc,
        padding: const EdgeInsets.all(20),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Hero Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('AI Recommendation',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(r['destination'] ?? '',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(r['tagline'] ?? '',
                    style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          r['bestTime'] ?? '',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Why this trip
          _sectionCard(
            icon: Icons.psychology_outlined,
            iconColor: AppTheme.primaryPurple,
            title: 'Why this trip?',
            content: r['why'] ?? '',
          ),
          const SizedBox(height: 14),
          // Highlights
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded,
                        color: Color(0xFFFFD93D), size: 20),
                    const SizedBox(width: 8),
                    Text('Top Highlights',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 14),
                _highlightRow('1', r['highlight1'] ?? ''),
                const SizedBox(height: 10),
                _highlightRow('2', r['highlight2'] ?? ''),
                const SizedBox(height: 10),
                _highlightRow('3', r['highlight3'] ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Accommodation
          _sectionCard(
            icon: Icons.hotel_outlined,
            iconColor: Colors.blue,
            title: 'Where to Stay',
            content: r['accommodation'] ?? '',
          ),
          const SizedBox(height: 14),
          // Pro Tip
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD93D), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Local Pro Tip',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: const Color(0xFFE65100))),
                      const SizedBox(height: 4),
                      Text(r['tip'] ?? '',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.brown[700])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Budget badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI estimates this trip fits within your PKR ${widget.budget.toStringAsFixed(0)} budget for ${widget.duration}!',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Re-open planner sheet for another suggestion
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text('Try Again',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryPurple,
                    side: const BorderSide(color: AppTheme.primaryPurple),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text('Got it!',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shadowColor: AppTheme.primaryPurple.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sectionCard(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String content}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(content,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey[700], height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightRow(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
          child: Center(
            child: Text(num,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800])),
        ),
      ],
    );
  }
}
