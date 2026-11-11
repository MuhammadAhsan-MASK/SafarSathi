import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'itinerary_screen.dart';
import 'split_bill_screen.dart';
import 'services/budget_matcher_service.dart';
import '../hotels/models/hotel_model.dart';
import '../restaurants/models/restaurant_model.dart';
import '../transport/models/transport_model.dart';
import '../attractions/models/attraction_model.dart';
import '../hotels/hotel_detail_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';
import '../transport/transport_detail_screen.dart';

class BudgetAnalysisScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final int travelers;

  const BudgetAnalysisScreen({
    super.key,
    this.origin = 'Karachi',
    required this.destination,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.travelers,
  });

  @override
  State<BudgetAnalysisScreen> createState() => _BudgetAnalysisScreenState();
}

class _BudgetAnalysisScreenState extends State<BudgetAnalysisScreen> {
  final BudgetMatcherService _matcherService = BudgetMatcherService();

  late Future<List<TransportOption>> _transportFuture;
  late Future<List<Hotel>> _hotelFuture;
  late Future<List<Restaurant>> _restaurantFuture;
  late Future<List<Attraction>> _attractionFuture;

  late double _maxNightlyHotelBudget;
  late double _maxMealBudget;
  late double _maxTransportBudget;
  late double _maxActivityBudget;
  late int _dayCount;

  @override
  void initState() {
    super.initState();
    final days = widget.endDate.difference(widget.startDate).inDays.abs() + 1;
    _dayCount = days > 0 ? days : 1;

    // Budget math
    // 20% Transport, 40% Hotels, 25% Food, 15% Activities
    _maxTransportBudget = (widget.budget * 0.20) / widget.travelers;
    _maxNightlyHotelBudget = (widget.budget * 0.40) / _dayCount;
    _maxMealBudget = (widget.budget * 0.25) / (_dayCount * 3 * widget.travelers);
    _maxActivityBudget = (widget.budget * 0.15) / (_dayCount * widget.travelers);

    _transportFuture = _matcherService.getAffordableTransport(
      origin: widget.origin,
      destination: widget.destination,
      maxFare: _maxTransportBudget,
    );
    _hotelFuture = _matcherService.getAffordableHotels(widget.destination, _maxNightlyHotelBudget);
    _restaurantFuture = _matcherService.getAffordableRestaurants(widget.destination, _maxMealBudget);
    _attractionFuture = _matcherService.getAffordableAttractions(widget.destination, _maxActivityBudget);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Budget Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHealthScoreCard(),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCostSummary(currency),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Options Matched to Your Budget:',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 1. Transport Options
            _buildSectionHeader(
              'Transport (${widget.origin} → ${widget.destination})',
              '< ${currency.formatPrice(_maxTransportBudget)} /person',
              Icons.directions_bus,
            ),
            _buildFutureBuilder<List<TransportOption>>(_transportFuture, (transports) => _buildTransportList(transports)),

            const SizedBox(height: 18),

            // 2. Hotels
            _buildSectionHeader(
              'Hotels in ${widget.destination}',
              '< ${currency.formatPrice(_maxNightlyHotelBudget)} /night',
              Icons.hotel,
            ),
            _buildFutureBuilder<List<Hotel>>(
              _hotelFuture,
              (hotels) => _buildHotelList(hotels),
              emptyBuilder: () => _buildNoBudgetHotelsCard(currency),
            ),

            const SizedBox(height: 18),

            // 3. Restaurants
            _buildSectionHeader(
              'Restaurants & Dining',
              '< ${currency.formatPrice(_maxMealBudget)} /meal',
              Icons.restaurant,
            ),
            _buildFutureBuilder<List<Restaurant>>(_restaurantFuture, (restaurants) => _buildRestaurantList(restaurants)),

            const SizedBox(height: 18),

            // 4. Attractions & Activities
            _buildSectionHeader(
              'Attractions & Sightseeing',
              'Entry fees within budget',
              Icons.attractions,
            ),
            _buildFutureBuilder<List<Attraction>>(_attractionFuture, (attractions) => _buildAttractionList(attractions)),

            const SizedBox(height: 32),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.route_outlined, size: 22),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('View Detailed Route & Daily Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItineraryScreen(
                        origin: widget.origin,
                        destination: widget.destination,
                        startDate: widget.startDate,
                        endDate: widget.endDate,
                        budget: widget.budget,
                        travelers: widget.travelers,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.group_outlined, size: 20),
                  label: const Text('Split Bill / Group Expense Tracker', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplitBillScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryOrange,
                    side: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String budgetCap, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: AppTheme.primaryPurple),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
            ),
            child: Text(
              budgetCap,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF047857)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureBuilder<T>(
    Future<T> future,
    Widget Function(T) builder, {
    Widget Function()? emptyBuilder,
  }) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData || (snapshot.data is List && (snapshot.data as List).isEmpty)) {
          if (emptyBuilder != null) {
            return emptyBuilder();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "No options within exact cap. Showing best-value alternatives in destination.",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return builder(snapshot.data as T);
      },
    );
  }

  List<String> _getSuggestedBudgetStayAreas(String destination) {
    final lower = destination.toLowerCase();
    if (lower.contains('hunza')) {
      return ['Aliabad Bazaar', 'Ganish Village', 'Altit Side Streets', 'Gulmit Homestays'];
    } else if (lower.contains('skardu')) {
      return ['Skardu Main Bazaar', 'Hussainabad', 'Satellite Town', 'Old Skardu Road'];
    } else if (lower.contains('murree')) {
      return ['Lower Bazaar', 'Jhika Gali', 'Kashmir Point Side Lanes', 'Sunny Bank'];
    } else if (lower.contains('swat') || lower.contains('kalam')) {
      return ['Mingora Side Streets', 'Fizagat', 'Bahrain Riverbank', 'Utror Homestays'];
    } else if (lower.contains('naran') || lower.contains('kaghan')) {
      return ['Kaghan Town', 'Paras Rest Houses', 'Battakundi', 'Shogran Lower Village'];
    } else if (lower.contains('islamabad') || lower.contains('rawalpindi')) {
      return ['G-9 / G-10 Markaz Rooms', 'Bahria Town Apartments', 'Saddar (Rawalpindi)', 'F-10 Airbnbs'];
    } else if (lower.contains('lahore')) {
      return ['Johar Town Airbnbs', 'Gulberg Side Lanes', 'Model Town', 'Lakshmi Chowk Hostels'];
    } else if (lower.contains('karachi')) {
      return ['Clifton Block 2/8 Airbnbs', 'PECHS Guesthouses', 'Gulshan-e-Iqbal', 'Bahadurabad'];
    } else if (lower.contains('multan')) {
      return ['Bosan Road Guesthouses', 'Gulgasht Colony', 'Cantt Side Streets', 'Nishtar Road'];
    } else if (lower.contains('bahawalpur')) {
      return ['Model Town A/B', 'University Chowk', 'Fareed Gate Side Streets', 'Satellite Town'];
    } else if (lower.contains('peshawar')) {
      return ['University Town', 'Saddar Bazaar Guesthouses', 'Hayatabad Phase 1/2'];
    } else if (lower.contains('quetta')) {
      return ['Jinnah Road', 'Satellite Town', 'Samungli Road Guesthouses'];
    } else if (lower.contains('gwadar')) {
      return ['Airport Road Guesthouses', 'Marine Drive Backlanes', 'Main Bazaar Rooms'];
    } else if (lower.contains('chitral') || lower.contains('neelum') || lower.contains('kumrat') || lower.contains('gilgit')) {
      return ['Main Bazaar Rest Houses', 'Local Village Homestays', 'Riverbank Guesthouses'];
    }
    return ['Main City Bazaar Side Streets', 'Local Homestays & Airbnbs', 'Bus Terminal Guesthouses'];
  }

  Widget _buildNoBudgetHotelsCard(CurrencyProvider currency) {
    final areas = _getSuggestedBudgetStayAreas(widget.destination);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
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
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_work_rounded, color: Color(0xFFD97706), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No Hotels Available Within Budget',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'According to your budget (< ${currency.formatPrice(_maxNightlyHotelBudget)}/night), there are no listed hotels available in ${widget.destination}. You can try local Airbnb rooms, homestays, or small budget hotels nearby.',
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF78350F), height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(
            'SUGGESTED AFFORDABLE AREAS IN ${widget.destination.toUpperCase()}:',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB45309),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: areas.map((area) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      area,
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF78350F)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final query = Uri.encodeComponent('${widget.destination}, Pakistan');
                    _launchUrl('https://www.airbnb.com/s/$query/homes');
                  },
                  icon: const Icon(Icons.travel_explore_rounded, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Search Local Airbnbs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB45309),
                    side: const BorderSide(color: Color(0xFFD97706)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Adjust Budget', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportList(List<TransportOption> options) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final t = options[index];
          final isWithin = t.fare <= _maxTransportBudget;
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TransportDetailScreen(option: t)),
            ),
            borderRadius: BorderRadius.circular(14),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Container(
                width: 195,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
                          child: Icon(t.icon, color: AppTheme.primaryPurple, size: 18),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isWithin ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isWithin ? 'Within Budget' : 'Alternative',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isWithin ? Colors.green.shade800 : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.type,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      t.route,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      currency.formatPrice(t.fare),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotelList(List<Hotel> hotels) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final h = hotels[index];
          final positivePrices = h.typePrices.values.where((v) => v > 0).toList();
          final effectivePrice = positivePrices.isNotEmpty
              ? positivePrices.reduce((a, b) => a < b ? a : b)
              : (h.price > 0 ? h.price : 3500.0);
          final isWithin = effectivePrice <= _maxNightlyHotelBudget;
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: h))),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: SizedBox(
                width: 165,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        if (h.imageUrl != null && h.imageUrl!.isNotEmpty)
                          Image.network(
                            h.imageUrl!,
                            height: 105,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 105, color: Colors.grey[200], child: const Icon(Icons.hotel)),
                          )
                        else
                          Container(height: 105, color: Colors.grey[300], child: const Icon(Icons.image)),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isWithin ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isWithin ? 'Within Budget' : 'Alternative',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${currency.formatPrice(effectivePrice)} / night',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantList(List<Restaurant> rests) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: rests.length,
        itemBuilder: (context, index) {
          final r = rests[index];
          final effectivePrice = r.typePrices.isNotEmpty
              ? r.typePrices.values.reduce((a, b) => a < b ? a : b)
              : (r.price > 0 ? r.price : 600.0);
          final isWithin = effectivePrice <= _maxMealBudget;
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r))),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: SizedBox(
                width: 165,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        if (r.imageUrl != null && r.imageUrl!.isNotEmpty)
                          Image.network(
                            r.imageUrl!,
                            height: 105,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 105, color: Colors.grey[200], child: const Icon(Icons.restaurant)),
                          )
                        else
                          Container(height: 105, color: Colors.grey[300], child: const Icon(Icons.restaurant)),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isWithin ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isWithin ? 'Within Budget' : 'Alternative',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '~${currency.formatPrice(effectivePrice)} / meal',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttractionList(List<Attraction> attractions) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: attractions.length,
        itemBuilder: (context, index) {
          final a = attractions[index];
          final isFree = a.fee == 0;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: SizedBox(
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      if (a.imageUrl != null && a.imageUrl!.isNotEmpty)
                        Image.network(
                          a.imageUrl!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(height: 100, color: Colors.purple.shade50, child: const Icon(Icons.location_on)),
                        )
                      else
                        Container(height: 100, color: Colors.purple.shade50, child: const Icon(Icons.location_on)),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            a.type,
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFree ? 'FREE ENTRY' : 'Ticket: ${currency.formatPrice(a.fee)}',
                          style: TextStyle(
                            color: isFree ? Colors.green.shade700 : Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 26,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.map_outlined, size: 12),
                            label: const Text('Map', style: TextStyle(fontSize: 10)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.attractionColor,
                              side: const BorderSide(color: AppTheme.attractionColor),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {
                              if (a.mapUrl != null && a.mapUrl!.isNotEmpty) {
                                _launchUrl(a.mapUrl!);
                              } else {
                                final q = Uri.encodeComponent('${a.name}, ${a.location ?? a.city}, Pakistan');
                                _launchUrl('https://www.google.com/maps/search/?api=1&query=$q');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: 0.90,
                  strokeWidth: 9,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('90%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('Healthy', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Feasibility: Excellent',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.destination} trip for ${widget.travelers} traveler${widget.travelers > 1 ? 's' : ''} over $_dayCount day${_dayCount > 1 ? 's' : ''}. All categories matched below.',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary(CurrencyProvider currency) {
    final transportTotal = widget.budget * 0.20;
    final hotelTotal = widget.budget * 0.40;
    final foodTotal = widget.budget * 0.25;
    final activityTotal = widget.budget * 0.15;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total Trip Budget',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  currency.formatPrice(widget.budget),
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category Allocation Breakdown Chips
          Row(
            children: [
              _buildAllocationPill('🚗 Transport 20%', currency.formatPrice(transportTotal), Colors.blue),
              const SizedBox(width: 6),
              _buildAllocationPill('🏨 Stay 40%', currency.formatPrice(hotelTotal), Colors.indigo),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildAllocationPill('🍽️ Food 25%', currency.formatPrice(foodTotal), Colors.deepOrange),
              const SizedBox(width: 6),
              _buildAllocationPill('🎟️ Activities 15%', currency.formatPrice(activityTotal), Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationPill(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
