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
import '../../core/sos_service.dart';
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
                      if (selectedDuration.contains('1 day')) minBudget = 1500;
                      else if (selectedDuration.contains('2–3')) minBudget = 4000;
                      else if (selectedDuration.contains('4–5')) minBudget = 7000;
                      else if (selectedDuration.contains('7 days')) minBudget = 10000;
                      else minBudget = 15000;

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            await SOSService.triggerSOS();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to trigger SOS: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.sos_outlined, color: Colors.white),
        label: const Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumHeader(context),
            const SizedBox(height: 30),
            _buildExploreServices(context),
            const SizedBox(height: 30),
            _buildEcoTrackerBanner(context),
            const SizedBox(height: 30),
            _buildRecentTrips(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      'Ready to explore?',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                   Consumer<CurrencyProvider>(
                    builder: (context, currencyProvider, child) {
                      return InkWell(
                        onTap: () => _showCurrencyPicker(context, currencyProvider),
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.currency_exchange, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                currencyProvider.selectedCurrency,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _handleQuickSwitch,
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.swap_horiz_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TripPlannerScreen()),
            ),
            icon: const Icon(Icons.add_circle_outline, size: 24),
            label: const Text('Plan New Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryPurple,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 12),
          // Surprise Me Button
          GestureDetector(
            onTap: () => _showSurpriseMeSheet(context),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      '✨ Surprise Me — AI Trip Suggester',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis,
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

  void _showCurrencyPicker(BuildContext context, CurrencyProvider currencyProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Currency',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...currencyProvider.currencies.map((currency) {
                final isSelected = currencyProvider.selectedCurrency == currency;
                return ListTile(
                  leading: Text(
                    isSelected ? '✓' : '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  title: Text(currency, style: GoogleFonts.poppins()),
                  onTap: () {
                    currencyProvider.setCurrency(currency);
                    Navigator.pop(context);
                  },
                  trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryPurple) : null,
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EcoTrackerScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carbon Footprint Tracker',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Travel green and earn Eco-Points!',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreServices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Services',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildServiceTile(context, 'Hotels', Icons.hotel_rounded, AppTheme.hotelColor, AppTheme.hotelBg, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HotelScreen()))),
              _buildServiceTile(context, 'Restaurants', Icons.restaurant_rounded, AppTheme.foodColor, AppTheme.foodBg, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RestaurantScreen()))),
              _buildServiceTile(context, 'Transport', Icons.directions_bus_rounded, AppTheme.transportColor, AppTheme.transportBg, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransportScreen()))),
              _buildServiceTile(context, 'Attractions', Icons.location_on_rounded, AppTheme.attractionColor, AppTheme.attractionBg, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttractionsScreen()))),
              _buildServiceTile(context, 'Safar Lingo', Icons.language_rounded, Colors.teal, Colors.teal[50]!, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LingoScreen()))),
              _buildServiceTile(context, 'Local Guides', Icons.person_pin_rounded, Colors.orange, Colors.orange[50]!, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuidesScreen()))),
              _buildServiceTile(context, 'Bargain Engine', Icons.price_check_rounded, Colors.green, Colors.green[50]!, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BargainScreen()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, String title, IconData icon, Color color, Color bgColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Recent Trips',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(Icons.map_outlined, color: Colors.grey.withValues(alpha: 0.4), size: 40),
              const SizedBox(height: 12),
              Text(
                'No trips planned yet',
                style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Your upcoming adventures will appear here.',
                style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, String title, String duration, String price) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.attractionBg, shape: BoxShape.circle),
                child: const Icon(Icons.location_on, color: AppTheme.attractionColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceProviderBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            const Text(
              'Are you a service provider?',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Join our platform and reach thousands of travelers across Pakistan.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3F51B5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Register Your Business'),
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
                      Text(r['bestTime'] ?? '',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 12)),
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
