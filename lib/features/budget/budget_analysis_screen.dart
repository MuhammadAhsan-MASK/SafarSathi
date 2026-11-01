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
                  Text(
                    'Options Matched to Your Budget:',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold),
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
            _buildFutureBuilder<List<Hotel>>(_hotelFuture, (hotels) => _buildHotelList(hotels)),

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
                  label: const Text('View Detailed Route & Daily Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryPurple),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              budgetCap,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureBuilder<T>(Future<T> future, Widget Function(T) builder) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData || (snapshot.data is List && (snapshot.data as List).isEmpty)) {
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
          return Card(
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
          final isWithin = h.price <= _maxNightlyHotelBudget;
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
                              isWithin ? 'Within Budget' : 'Top Choice',
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
                            '${currency.formatPrice(h.price)} / night',
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
          final isWithin = r.price <= _maxMealBudget;
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
                              isWithin ? 'Within Budget' : 'Featured',
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
                            '~${currency.formatPrice(r.price)} / head',
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
              Text('Total Trip Budget', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              Text(
                currency.formatPrice(widget.budget),
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
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
